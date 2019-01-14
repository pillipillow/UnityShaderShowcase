Shader "Mine/01a - SolidTexture"
{
    Properties
    {
		[Header(Base Parameters)]
		_Colour("Colour Tint",Color) = (0,0,0,0)
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           
            #include "UnityCG.cginc"

			float4 _Colour;
			sampler2D _MainTex;
			float4 _MainTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 tex : TEXCOORD0;
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.tex;
                
				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//Texture
				float2 main_uv = TRANSFORM_TEX(i.uv, _MainTex);
				fixed4 albedo = tex2D(_MainTex, main_uv) * _Colour;

				return albedo;
            }
            ENDCG
        }
    }
}
