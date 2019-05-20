Shader "Mine/02b - PBRShader"
{
	Properties
	{
		[Header(Base Parameters)]
		_Colour("Colour Tint",Color) = (0,0,0,0)
		_MainTex("Texture", 2D) = "white" {}

		[Header(Light Parameters)]
		_NormalTex("Normals", 2D) = "bump" {}
		_Smoothness("Specular Size", Range(0, 1)) = 0
		[Gamma]_Metallic("Metallic", Range(0, 1)) = 0 
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

			#include "PhysicalBasedRender.cginc"

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

			#include "PhysicalBasedRender.cginc"

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

			#include "ShadowPBS.cginc"

			ENDCG
		}
	}
}
