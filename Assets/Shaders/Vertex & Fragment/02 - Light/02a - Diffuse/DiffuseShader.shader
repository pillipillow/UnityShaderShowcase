Shader "Mine/02a - DiffuseShader"
{
	Properties
	{
		[Header(Base Parameters)]
		_Colour("Colour Tint",Color) = (0,0,0,0)
		_MainTex("Texture", 2D) = "white" {}
		_NormalTex("Normals", 2D) = "bump" {}

		[Header(Light Parameters)]
		//_SpecularTint("Specular tint", Color) = (0,0,0,0)
		_Smoothness("Smoothness", Range(0, 1)) = 0
		//Switch to MetallicLight.cginc
		[Gamma]_Metallic("Metallic", Range(0, 1)) = 0
		//For Bumpiness Parameter
		_BumpScale("Bump Scale", Float) = 1 
	}

		Subshader
		{
			Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

			
			Pass //Direct Light
			{
				Tags {"LightMode" = "ForwardBase"}
				Cull off

				CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag 
				#pragma target 3.0

				#pragma multi_compile _ SHADOWS_SCREEN
				#define FORWARD_BASE_PASS

				//Replace below with
				//StandardLight
				//Metallic
				//Bumpiness
				//Reflection
				#include "Reflection.cginc"

				ENDCG
			}

			Pass //Other Lights
			{
				Tags {"LightMode" = "ForwardAdd"}
				Blend One One 
				ZWrite Off

				CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag 
				#pragma target 3.0

				#pragma multi_compile_fwdadd_fullshadows

				//Replace below with
				//StandardLight
				//Metallic
				#include "Bumpiness.cginc"

				ENDCG
			}

			Pass //Shadows
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
