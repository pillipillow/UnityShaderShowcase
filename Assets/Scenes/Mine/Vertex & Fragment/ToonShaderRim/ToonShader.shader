Shader "Mine/Toon Shader/Rim Light"
{
	Properties
	{
		[Header(Base Parameters)]
		_Colour("Colour Tint",Color) = (0,0,0,0)
		_MainTex("Texture", 2D) = "white" {}

		[Header(Light Parameters)]
		_LightAmount("Light Intensity", Float) = 1
		_SpecularTint("Specular tint", Color) = (0,0,0,0)
		

		[Header(Cel Shading Parameters)]
		_ShadowTint("Shadow Colour", Color) = (1,1,1,1)
		[IntRange]_StepAmount("Shadow Steps", Range(1, 16)) = 2
		_StepWidth("Step Size", Range(0.01, 1)) = 0.25
		_SpecSmoothness("Specular Size", Range(0, 1)) = 0
		_SpecularFalloff("Specular Falloff", Range(0, 2)) = 1

		[Header(Rimlight Parameters)]
		_RimExtrusion("Rim Outline Size", Range(0,0.05)) = 1
		
	}

	Subshader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

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

			#include "CelShading.cginc"

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

			#include "CelShading.cginc"

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

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			Cull front

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 
			#pragma target 3.0

			#include "Rimlight.cginc"

			ENDCG
		}
		
	}
}
