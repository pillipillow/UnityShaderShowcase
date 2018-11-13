Shader "Mine/DiffuseShader"
{
	Properties
	{
		[Header(Base Parameters)]
		_Colour("Colour Tint",Color) = (0,0,0,0)
		_MainTex("Texture", 2D) = "white" {}

		[Header(Light Parameters)]
		_SpecularTint("Specular tint", Color) = (0,0,0,0)
		_Smoothness("Specular Size", Range(0.1, 1)) = 0
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

				#include "StandardLight.cginc"

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

				#include "StandardLight.cginc"

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
