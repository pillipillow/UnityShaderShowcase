Shader "Solid Texture"
{
	Properties
	{
		_Colour("Main Colour",Color) = (0,0,0,0)
		_MainTex("Main Texture",2D) = "white" {} //Similar to DiffuseTexture
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}

		Pass
		{
			Cull off //Render both faces towards the viewer, doesn't affect the lighting however

			CGPROGRAM
			#include "UnityCG.cginc" 

			#pragma vertex vert 
			#pragma fragment frag 
			#pragma target 3.0
			
			float4 _Colour;
			sampler2D _MainTex;
			float4 _MainTex_ST; //store tiling and offset data

			struct appdata 
			{
				float4 vertex : POSITION; 
				float2 tex : TEXCOORD0; //Takes the texture coordinates
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0; //return texture coordinates
			};

			v2f vert(appdata v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.tex,_MainTex); //allow Tiling and offsetting
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET 
			{
				//return fixed4(i.uv.x, i.uv.y,0,1); //return the uv coordinates in colour channels
				fixed4 albedo = tex2D(_MainTex, i.uv) * _Colour;
				return albedo;
			}

			ENDCG
		}
	}

	Fallback "Diffuse Lambert"
}
