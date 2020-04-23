Shader "Mine/02c - Toon Ramp/02cb - Rim Light"
{
	Properties
	{
		[Header(Base Parameters)]
		_Colour("Colour Tint",Color) = (0,0,0,0)
		_MainTex("Texture", 2D) = "white" {}

		[Header(Ramp Parameters)]
		_RampTex("Ramp Texture",2D) = "white" {}
		_LightAmount("Light Intensity", Float) = 0

		[Header(Rimlight Parameters)]
		_RimExtrusion("Rim Outline Size", Range(0,0.05)) = 1

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

		//Shadows
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

		//Rim
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
