#if !defined(SHADOWPBS_INCLUDED)
#define SHADOWPBS_INCLUDED

#include "UnityCG.cginc"

struct appdata
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};

struct v2f
{
	float4 pos : SV_POSITION;
};

	#if defined(SHADOWS_CUBE)
	struct v2f_shadow
	{
		float4 pos : SV_POSITION;
		float3 lightVec : TEXCOORD0;
	};

	v2f_shadow vert(appdata v)
	{
		v2f_shadow o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.lightVec = mul(unity_ObjectToWorld, v.vertex) - _LightPositionRange;

		return o;
	}

	fixed frag(v2f_shadow i) : SV_TARGET
	{
		float depth = length(i.lightVec) + unity_LightShadowBias.x;
		depth *= _LightPositionRange.w;
		return UnityEncodeCubeShadowDepth(depth);
	}
	#else
	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityClipSpaceShadowCasterPos(v.vertex, v.normal); //Controlling Normal Bias
		o.pos = UnityApplyLinearShadowBias(o.pos); // Controlling Shadow Depth bias

		return o;
	}

	fixed frag(v2f i) : SV_TARGET
	{
		return 0;
	}
	#endif
#endif