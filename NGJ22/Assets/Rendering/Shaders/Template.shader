Shader "Hidden/Template"
{
    Properties 
	{
		_MainTex("Texture", 2D) = "white" {}
	}
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }
		
		Pass
		{
			HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma vertex vert
            #pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			sampler2D _MainTex;
		
			struct appdata
            {
                float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
            };
		
            struct v2f
            {
                float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
            };
		
			v2f vert (appdata v)
            {
                v2f o;
				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				o.pos = vertexInput.positionCS;
				o.uv = v.uv;
				
				return o;
			}
			half4 frag (v2f i) : SV_Target
            {
				float4 col = tex2D(_MainTex, i.uv);
				
            	return col;
			}
			ENDHLSL
		}
	}
	Fallback "Universal Render Pipeline/Lit"
}