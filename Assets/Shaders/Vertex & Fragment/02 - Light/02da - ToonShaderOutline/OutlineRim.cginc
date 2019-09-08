#include "UnityCG.cginc"

float _RimOutlineExtrusion;
float4 _RimOutlineColour;

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

	newPos += float4(normal, 0) * _RimOutlineExtrusion;
	o.pos = UnityObjectToClipPos(newPos);
	
	return o;
}

fixed4 frag(v2f i): SV_TARGET
{
	return _RimOutlineColour;
}