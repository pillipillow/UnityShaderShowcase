#if !defined(LIGHTING_INCLUDED)
#define LIGHTING_INCLUDED

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

float4 _Colour;
sampler2D _MainTex;
float4 _MainTex_ST;

float _Smoothness;
float _Metallic;

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

	SHADOW_COORDS(5)
};

v2f vert(appdata v)
{
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = v.tex;
	o.normal = UnityObjectToWorldNormal(v.normal);
	o.normal = normalize(o.normal);
	o.worldPos = mul(unity_ObjectToWorld, v.vertex);

	TRANSFER_SHADOW(o);

	return o;
}

//Light
UnityLight CreateLight(v2f i)
{
	UnityLight light;

	#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
		light.dir = normalize(_WorldSpaceLightPos0 - i.worldPos);
	#else
		light.dir = _WorldSpaceLightPos0;
	#endif

	UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

	light.color = _LightColor0 * atten;
	light.ndotl = DotClamped(i.normal, light.dir) ; //Lambert equation with saturation clamp
	return light;
}

UnityIndirect CreateIndirectLight(v2f i)
{
	UnityIndirect inDirectLight;
	inDirectLight.diffuse = 0;
	inDirectLight.specular = 0;

	#if defined(FORWARD_BASE_PASS)
		inDirectLight.diffuse += float4(max(0, ShadeSH9(float4(i.normal, 1))), 1);
	#endif

	return inDirectLight;
}

fixed4 frag(v2f i) : SV_TARGET
{
	//Specular
	i.normal = normalize(i.normal);
	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

	//Texture
	float2 main_uv = TRANSFORM_TEX(i.uv, _MainTex);
	fixed4 albedo = tex2D(_MainTex, main_uv) * _Colour;

	//Metallic
	float3 specularTint; // = albedo * _Metallic;
	float oneMinusReflectivity; // = 1 - _Metallic;
	//albedo *= oneMinusReflectivity;
	albedo = float4(DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity), 1);

	//From the "UnityPBSLighting.cginc"
	return UNITY_BRDF_PBS //BRDF = bidirectional reflectance distribution function
	(
		albedo, specularTint,
		oneMinusReflectivity, _Smoothness,
		i.normal, viewDir, //Specular
		CreateLight(i), CreateIndirectLight(i)
	);
}
#endif