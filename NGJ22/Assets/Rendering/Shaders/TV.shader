Shader "NGJ22/TV"
{
    Properties 
	{
		_MainTex("Texture", 2D) = "white" {}
		_Shift("Color Shift", Range(0,1)) = 0
		_ShiftFrequency("Color Shift Frequency", Float) = 1
		_ScanAmount("Scan Amount", Float) = 30
		_ScanSpeed("Scan Speed", Float) = 1
		_ScanSize("Scan Size", Float) = 1
		_ScanDistort("Scan Distort", Range(0,0.1)) = 0
		_ScanColorAdd("Scan Color Add", Range(-1,1)) = 0
		[Toggle(WHITE_NOISE)] _WhiteNoise("White Noise", Float) = 0
		_WhiteNoiseSteps("White Noise Steps", Float) = 100
		
		_Add("Add", Float) = 0
	}
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }
		
		Pass
		{
			Cull Back
		
			HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma vertex vert
            #pragma fragment frag
			#pragma shader_feature_local WHITE_NOISE

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			sampler2D _MainTex;
			float _Shift;
			float _ShiftFrequency;
			float _ScanAmount;
			float _ScanSpeed;
			float _ScanSize;
			float _ScanDistort;
			float _ScanColorAdd;
			float _WhiteNoiseSteps;
			float _Add;
			
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

			float random( float2 p )
			{
				return frac(sin(dot(p.xy,float2(_Time.y,65.115)))*2773.8856);
			}
			
			half4 frag (v2f i) : SV_Target
            {
				float scan = sin((i.uv.y  * _ScanAmount) + _Time.y * _ScanSpeed);
            	scan = (scan + 1) / 2 - abs(sin((i.uv.x + _Time.y * i.uv.y))) * 0.02;
            	scan = step(_ScanSize, scan);
				float2 uv = i.uv + float2(scan * _ScanDistort, 0);

            	#if WHITE_NOISE
            		float2 noiseUV = round(uv * _WhiteNoiseSteps) / _WhiteNoiseSteps;
            		float4 col = random(noiseUV);
            	#else
					float4 col = tex2D(_MainTex, uv);
            		float4 colShiftPositive = tex2D(_MainTex, uv + _Shift);
            		float4 colShiftNegative = tex2D(_MainTex, uv - _Shift);
            		col.r = colShiftPositive.r;
            		col.b = colShiftNegative.b;
            	#endif
            	
            	col += scan * _ScanColorAdd;
            	col += _Add;
            	return col;
			}
			ENDHLSL
		}
	}
	Fallback "Universal Render Pipeline/Lit"
}