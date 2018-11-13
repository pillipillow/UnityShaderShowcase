Shader "Mine/ToonRamp"
{
	Properties
	{
		[Header(Base Parameters)]
		_Colour("Colour Tint",Color) = (0,0,0,0)
		_MainTex("Texture", 2D) = "white" {}

		[Header(Ramp Parameters)]
		_RampTex("Ramp Texture",2D) = "white" {}
		_LightAmount("Light Intensity", Float) = 0
	}

		Subshader
		{
			Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

			//Diffuse Shader
			Pass
			{
				Tags {"LightMode" = "ForwardBase"}
				Cull off

				CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag 
				#pragma target 3.0

				#pragma multi_compile _ SHADOWS_SCREEN
				#define FORWARD_BASE_PASS

				#include "ToonRamp.cginc"

				ENDCG
			}

			Pass
			{
				Tags {"LightMode" = "ForwardAdd"}
				Blend One One 
				ZWrite Off

				CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag 
				#pragma target 3.0

				#pragma multi_compile_fwdadd_fullshadows

				#include "ToonRamp.cginc"

				ENDCG
			}

			Pass
			{
				Tags {"LightMode" = "ShadowCaster"}

				CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag 
				#pragma target 3.0

				#pragma multi_compile_shadowcaster

				#include "Shadow.cginc"

				ENDCG
			}
		}
}
