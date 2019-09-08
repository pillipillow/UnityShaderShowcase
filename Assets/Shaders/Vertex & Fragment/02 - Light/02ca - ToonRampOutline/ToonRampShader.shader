Shader "Mine/Toon Ramp/02ca - Outline"
{
	Properties
	{
		[Header(Base Parameters)]
		_Colour("Colour Tint",Color) = (0,0,0,0)
		_MainTex("Texture", 2D) = "white" {}

		[Header(Ramp Parameters)]
		_RampTex("Ramp Texture",2D) = "white" {}
		_LightAmount("Light Intensity", Float) = 0

		[Header(Outline Parameters)]
		_OutlineExtrusion("Outline Size", Range(0,0.01)) = 1
		_OutlineColour("Outline Colour", Color) = (1,1,1,1)
		_OutlineTex("Texture", 2D) = "white" {}
		_ScrollXSpeed("Scroll X Speed", Float) = 0
		_ScrollYSpeed("Scroll Y Speed", Float) = 0
		_Angle("Angle", Range(-5.0,  5.0)) = 0.0

		[Header(Outline Rim Parameters)]
		_RimOutlineExtrusion("Rim Outline Size", Range(0,0.004)) = 1
		_RimOutlineColour("Rim Outline Colour", Color) = (1,1,1,1)
	}

	Subshader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

		//Diffuse Shader
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			Cull off
				
			Stencil // Writes to the stencil buffer
			{
				Ref 4
				Comp always
				Pass replace
				ZFail keep
			}

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

		//Outline
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			Cull off
			ZWrite on
			ZTest on

			Stencil //Reads the stencil buffer
			{
				Ref 4
				Comp notequal
				Fail keep
				Pass replace
			}

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 
			#pragma target 3.0

			#include "Outline.cginc"

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

			#include "OutlineRim.cginc"

			ENDCG
		}
	}
}
