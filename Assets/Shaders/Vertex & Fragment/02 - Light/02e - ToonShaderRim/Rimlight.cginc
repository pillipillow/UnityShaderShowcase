#include "UnityCG.cginc"

float _RimExtrusion;
float3 _LightColor0;

struct appdata
{
	float4 vertex : POSITION; 
	float3 normal : NORMAL;
};

struct v2f
{
	float4 pos : SV_POSITION;
};

v2f vert(appdata v)
{
	v2f o;
	//Outline
	float4 newPos = v.vertex;
	float3 normal = normalize(v.normal);

	//Light
	float3 lightDir;
	#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
		lightDir = normalize(_WorldSpaceLightPos0 - i.worldPos);
	#else
		lightDir = _WorldSpaceLightPos0;
	#endif
	half4 nDotL = saturate(dot(normal, lightDir));

	newPos += float4(v.normal, 0) * nDotL * _RimExtrusion;

	o.pos = UnityObjectToClipPos(newPos);
	
	return o;
}

fixed4 frag(v2f i): SV_TARGET
{
	return  float4(_LightColor0,0.0) + float4(_LightColor0,0.0);
}