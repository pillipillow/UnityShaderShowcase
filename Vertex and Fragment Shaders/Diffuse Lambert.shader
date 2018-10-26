Shader "Diffuse Lambert"
{
	Properties
	{
		_Colour("Main Colour",Color) = (0,0,0,0)
		_MainTex("Main Texture",2D) = "white" {}

		_LightAmount("Light Intensity", Float) = 0
	}

	SubShader
	{
		Tags
		{ "RenderType" = "Opaque" "Queue" = "Geometry" }

		Pass
		{
			Tags { "LightMode" = "ForwardBase"} 
			Cull off

			CGPROGRAM
			#include "UnityCG.cginc" 
			#include "AutoLight.cginc" 

			#pragma vertex vert 
			#pragma fragment frag 

			#pragma multi_compile_fwdbase

			float4 _Colour;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _LightColor0; //Directional light colour from AutoLight
			float _LightAmount;

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
				
				LIGHTING_COORDS(1, 2) 
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.tex;
				
				float3 worldNormal = mul(unity_ObjectToWorld, v.normal); //Getting the world normal for the Lambert model
				o.normal = normalize(worldNormal);

				TRANSFER_VERTEX_TO_FRAGMENT(o); 

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				//Light
				half3 lightDir = normalize(_WorldSpaceLightPos0); //Get the Directional light's direction
				half4 nDotL = dot(i.normal, lightDir) * 0.5 + 0.5; //Lambert equation with wrap
				float attenuation = LIGHT_ATTENUATION(i) * _LightAmount;

				float4 diffuse = _LightColor0 * (nDotL * attenuation);
				diffuse.rgb += ShadeSH9(float4(i.normal, 1)); //Add Illumination or Light probes for ambient lighting

				//Texture
				float2 main_uv = TRANSFORM_TEX(i.uv,_MainTex);
				fixed4 albedo = tex2D(_MainTex, i.uv) * _Colour;

				return albedo * diffuse;
			}

			ENDCG
		}
	}

		Fallback "Solid Texture"
}
