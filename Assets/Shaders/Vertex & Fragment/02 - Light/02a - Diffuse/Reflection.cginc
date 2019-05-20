#if !defined(LIGHTING_INCLUDED)
#define LIGHTING_INCLUDED

#include "UnityStandardBRDF.cginc"
#include "UnityStandardUtils.cginc"
#include "AutoLight.cginc"

float4 _Colour;
sampler2D _MainTex;
float4 _MainTex_ST;

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

void InitializeFragmentNormal(inout v2f i)
{
	//Normal Map
	float2 normal_uv = TRANSFORM_TEX(i.uv, _NormalTex);
	float3 mainNormal = UnpackScaleNormal(tex2D(_NormalTex, normal_uv), _BumpScale);

	//Tangent Space
	float3 binormal = cross(i.normal, i.tangentTex) * (i.tangentTex.w * unity_WorldTransformParams.w);

	i.normal = normalize(
		mainNormal.x * i.tangentTex +
		mainNormal.y * binormal +
		mainNormal.z * i.normal
	);

	i.normal = normalize(i.normal);
}


fixed4 frag(v2f i) : SV_TARGET
{
	InitializeFragmentNormal(i);

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
	float3 specularTint;
	float oneMinusReflectivity;
	albedo = float4(DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity), 1);
	float3 spec = pow(nDotH, (1 - _Smoothness) * 100) * specularTint * _LightColor0;

	float3 reflectDir = reflect(-viewDir, i.normal);
	//Roughness
	float roughness = 1 - _Smoothness;
	roughness *= 1.7 - 0.7 * roughness;
	//Sample from the environment
	float4 envSample = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
	spec *= DecodeHDR(envSample, unity_SpecCube0_HDR);

	float4 result = float4(albedo * diffuse + spec,1);
	return result;
}
#endif