#if !defined(LIGHTING_INCLUDED)
#define LIGHTING_INCLUDED

#include "UnityStandardBRDF.cginc"
#include "AutoLight.cginc"

float4 _Colour;
sampler2D _MainTex;
float4 _MainTex_ST;

float _Smoothness;
float4 _SpecularTint;

struct appdata
{
	float4 vertex : POSITION;
	float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
};

struct v2f
{
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : NORMAL;
	float3 worldPos : TEXCOORD1;

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

	#if defined(SHADOWS_SCREEN)
		TRANSFER_SHADOW(o);
	#endif

	return o;
}

fixed4 frag(v2f i) : SV_TARGET
{
	//Light
	i.normal = normalize(i.normal);
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
	float4 spec = pow(nDotH, (1 - _Smoothness) * 100) * _SpecularTint * _LightColor0;

	//Texture
	float2 main_uv = TRANSFORM_TEX(i.uv, _MainTex);
	fixed4 albedo = tex2D(_MainTex, main_uv) * _Colour;

	float4 result = (albedo * diffuse + spec);
	return result;
}
#endif