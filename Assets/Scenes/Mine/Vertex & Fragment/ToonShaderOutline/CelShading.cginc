#if !defined(LIGHTING_INCLUDED)
#define LIGHTING_INCLUDED

#include "UnityStandardBRDF.cginc"
#include "AutoLight.cginc"

float4 _Colour;
sampler2D _MainTex;
float4 _MainTex_ST;

float _LightAmount;
float _SpecSmoothness;
float4 _SpecularTint;

float4 _ShadowTint;
int _StepAmount;
float _StepWidth;
float _SpecularSize;
float _SpecularFalloff;


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
	float3 lightDir;
	#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
		lightDir = normalize(_WorldSpaceLightPos0 - i.worldPos);
	#else
		lightDir = _WorldSpaceLightPos0;
	#endif
	float nDotL = dot(i.normal, lightDir);
	nDotL = nDotL / _StepWidth;
	float ligthIntensity = floor(nDotL);

	float nDotLChange = fwidth(nDotL);
	float ligthSmoothing = smoothstep(0,nDotLChange,nDotL);
	ligthIntensity += ligthSmoothing;

	ligthIntensity = ligthIntensity / _StepAmount;
	ligthIntensity = saturate(ligthIntensity);

	//Atten
	UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
	#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
		float attenChange = fwidth(atten) * 0.01;
		float shadowAtten = smoothstep(0.05 - attenChange, 0.05 + attenChange, atten);
	#else
		float attenChange = fwidth(atten) * 0.5;
		float shadowAtten = smoothstep(0.5 - attenChange, 0.5 + attenChange, atten);
	#endif
	
	float4 diffuse = ligthIntensity * shadowAtten * _LightColor0;

	#if defined(FORWARD_BASE_PASS)
		diffuse += float4(max(0, ShadeSH9(float4(i.normal, 1))),1);
	#endif

	//Specular
	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
	
	float3 reflectionDirection = reflect(lightDir, i.normal);
	float towardsReflection = dot(viewDir, -reflectionDirection);
	float specularFalloff = dot(viewDir, i.normal);
	specularFalloff = pow(specularFalloff, _SpecularFalloff);
	towardsReflection = towardsReflection * specularFalloff;
	
	float specChange = fwidth(towardsReflection);
	float specSmoothing = smoothstep(1 - _SpecSmoothness, 1 - _SpecSmoothness + specChange, towardsReflection);
	specSmoothing *= shadowAtten;

	//Texture
	float2 main_uv = TRANSFORM_TEX(i.uv, _MainTex);
	fixed4 albedo = tex2D(_MainTex, main_uv) * _Colour;
	diffuse *= albedo;

	float4 specColour = specSmoothing * _SpecularTint;

	float4 shadowColor = albedo * _ShadowTint;
	float4 result = (diffuse + shadowColor) + specColour;
	
	return result;
}
#endif