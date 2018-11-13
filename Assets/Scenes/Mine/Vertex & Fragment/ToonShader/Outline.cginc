#include "UnityCG.cginc"

float _OutlineExtrusion;
float4 _OutlineColour;

sampler2D _OutlineTex;
float4 _OutlineTex_ST;
float _ScrollXSpeed;
float _ScrollYSpeed;
float _Angle;

struct appdata
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};

struct v2f
{
	float4 pos : SV_POSITION;
	float3 worldPos : TEXCOORD1;
};

v2f vert(appdata v)
{
	v2f o;
	float4 newPos = v.vertex;
	float3 normal = normalize(v.normal);

	newPos += float4(normal, 0) * _OutlineExtrusion;
	o.pos = UnityObjectToClipPos(newPos);

	//Panning/Scrolling the texture based on speed and time(given by UnityCG)
	fixed varX = _ScrollXSpeed * _Time;
	fixed varY = _ScrollYSpeed * _Time;

	o.worldPos = mul(unity_ObjectToWorld, v.vertex);
	o.worldPos = o.worldPos + float3(varX, varY, 0);

	return o;
}

fixed4 frag(v2f i) : SV_TARGET
{
	float2 main_uv = TRANSFORM_TEX(i.worldPos, _OutlineTex);
	fixed4 albedo = tex2D(_OutlineTex, main_uv);

	return _OutlineColour * albedo;
}