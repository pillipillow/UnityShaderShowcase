#if !defined(LIGHTING_INCLUDED)
#define LIGHTING_INCLUDED

#include "UnityStandardBRDF.cginc"
#include "UnityStandardUtils.cginc"
#include "AutoLight.cginc"

float4 _Colour;
sampler2D _MainTex;
float4 _MainTex_ST;

/*sampler2D _HeightTex;
float4 _HeightTex_ST;
float4 _HeightTex_TexelSize;*/

sampler2D _NormalTex;
float4 _NormalTex_ST;

float _Smoothness;
float _Metallic;
float _BumpScale;

struct appdata
{
	float4 vertex : POSITION;
	float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
};

struct v2f
{
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : NORMAL;
	float3 worldPos : TEXCOORD1;
	float4 tangentTex : TEXCOORD2;

	#if defined(SHADOWS_SCREEN)
		SHADOW_COORDS(5)
	#endif
};

v2f vert(appdata v)
{
	v2f o;
	o.pos= UnityObjectToClipPos(v.vertex);
	o.uv = v.tex;
	o.normal = UnityObjectToWorldNormal(v.normal);
	o.normal = normalize(o.normal);
	o.worldPos = mul(unity_ObjectToWorld, v.vertex);
	o.tangentTex = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

	#if defined(SHADOWS_SCREEN)
		TRANSFER_SHADOW(o);
	#endif

	return o;
}

fixed4 frag(v2f i) : SV_TARGET
{
	/*//Height Map
	float2 height_uv = TRANSFORM_TEX(i.uv, _HeightTex);
	//Tangent to Normal
	//Normals along U
	float deltaU = float2(_HeightTex_TexelSize.x * 0.5, 0);
	float nU1 = tex2D(_HeightTex, height_uv - deltaU);
	float nU2 = tex2D(_HeightTex, height_uv + deltaU);
	//float3 normalU = float3(1, u2 - u1, 0);
	//Normals along V
	float deltaV = float2(0, _HeightTex_TexelSize.y * 0.5);
	float nV1 = tex2D(_HeightTex, height_uv - deltaV);
	float nV2 = tex2D(_HeightTex, height_uv + deltaV);
	//float3 normalV = float3(0, v2 - v1, 1);

	i.normal = float3((nU1 - nU2), 1, (nV1 - nV2)); //Cross product of U and V*/

	//Normal Map
	//DXT5nm format only stores the X and Y components of the normal. 
	//Z component is discarded. The Y component is stored in the G channel, 
	//as you might expect. However, the X component is stored in the A channel. The R and B channels are not used.
	float2 normal_uv = TRANSFORM_TEX(i.uv, _NormalTex);
	/*i.normal.xy = tex2D(_NormalTex, normal_uv).wy * 2 - 1;
	i.normal.xy *= _BumpScale;
	i.normal.z = sqrt(1 - saturate(dot(i.normal.xy, i.normal.xy)));*/

	float3 mainNormal = UnpackScaleNormal(tex2D(_NormalTex, normal_uv), _BumpScale);
	
	//Tangent Space
	//float3 tangentSpaceNormal = i.normal.xzy;
	float3 binormal = cross(i.normal, i.tangentTex) * (i.tangentTex.w * unity_WorldTransformParams.w);
	
	i.normal = normalize(
		mainNormal.x * i.tangentTex +
		mainNormal.y * binormal +
		mainNormal.z * i.normal
	);

	i.normal = normalize(i.normal);

	//Light	
	float3 lightDir;
	#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
		lightDir = normalize(_WorldSpaceLightPos0 - i.worldPos);
	#else
		lightDir = _WorldSpaceLightPos0;
	#endif
	
	half4 nDotL = DotClamped(i.normal, lightDir); //Lambert equation with saturation clamp
	UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

	float4 diffuse = nDotL * atten * _LightColor0;
	
	#if defined(FORWARD_BASE_PASS)
		diffuse += float4(max(0, ShadeSH9(float4(i.normal, 1))),1);
	#endif

	//Specular
	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
	float3 halfVector = normalize(lightDir + viewDir); //Blinn-Phong formula
	float nDotH = DotClamped(i.normal, halfVector);

	//Texture
	float2 main_uv = TRANSFORM_TEX(i.uv, _MainTex);
	fixed4 albedo = tex2D(_MainTex, main_uv) * _Colour;

	//Metallic
	float3 specularTint; // = albedo * _Metallic;
	float oneMinusReflectivity; // = 1 - _Metallic;
	//albedo *= oneMinusReflectivity;
	albedo = float4(DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity), 1);
	float3 spec = pow(nDotH, (1 - _Smoothness) * 100) * specularTint * _LightColor0;

	float4 result = float4(albedo * diffuse + spec,1);
	return result;
}
#endif