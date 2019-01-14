#if !defined(SHADOW_INCLUDED)
#define SHADOW_INCLUDED

#include "UnityCG.cginc"

struct appdata
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};

struct v2f
{
	V2F_SHADOW_CASTER;
};

v2f vert(appdata v)
{
	v2f o;
	TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

	return o;
}

fixed4 frag(v2f i) : SV_TARGET
{
	SHADOW_CASTER_FRAGMENT(i);
}

#endif