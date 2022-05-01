Shader "PostProcessing/VolumetricLightScattering"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white"{}
		_LightColor("Light Color", Color) = (1,1,1,1)
		_Samples("Samples", Int) = 1
		_Radius("Radius", Range(0,5)) = 0.5
		_Decay("Decay", Range(0,1.5)) = 1
		_Density("Density", Range(0.5,10)) = 1
		_Weight("Weight", Float) = 1
    }
    SubShader
    {
        Cull Off
		ZWrite Off 
		ZTest Always
		
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "../Shaders/Depth.hlsl"
            
            sampler2D _MainTex;
			float _Samples;
			float _Radius;
			float _Decay;
			float _Density;
			float _Weight;
			float _Exposure;
			uniform float _LightPosX;
			uniform float _LightPosY;
			uniform float3 _LightColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
            	o.vertex = vertexInput.positionCS;
                o.uv = v.uv;
                return o;
            }


			half N21(half2 p)
			{
				p = frac(p*half2(225.54, 221.73));
				p += dot(p, p + 121.25);
				return frac(p.x * p.y);
			}

            half4 frag (v2f i) : SV_Target
            { 
				float2 texCoord = i.uv;
				// Calculate vector from pixel to light source in screen space.    
				float2 deltaTexCoord = texCoord - float2(_LightPosX, _LightPosY) / _ScreenParams.xy;  
				float lightDist = length(float2(deltaTexCoord.x * (_ScreenParams.x / _ScreenParams.y), deltaTexCoord.y));
				// Divide by number of samples and scale by control factor.   
				deltaTexCoord /= _Samples * _Density;   
				// Store initial sample.    
				float3 color = tex2D(_MainTex , texCoord);
				// Set up illumination decay factor.    
				float illuminationDecay = 1.0f;   
				float light = 0;
				// Evaluate summation from Equation 3 NUM_SAMPLES iterations.    
				for (int i = 0; i < _Samples; i++)   
				{     
					// Step sample location along ray.     
					texCoord -= deltaTexCoord + (deltaTexCoord * N21(texCoord));     
					// Retrieve sample at new location.
					float depth = (SampleLinearDepth(texCoord) / _ProjectionParams.z);
					float sampleCol = depth;
					// Apply sample attenuation scale/decay factors.     
					sampleCol *= illuminationDecay * _Weight;    
					// Accumulate combined color.     
					light += sampleCol;
					// Update exponential decay factor.     
					illuminationDecay *= _Decay;   
				}
			
				color += saturate((lerp(light, 0, lightDist / _Radius)  * _LightColor.rgb) / _Samples);
				//Output final color with a further scale control factor.    
				//return fixed4( deltaTexCoord, 1, 1);
				return half4( color , 1);
		
            }
            ENDHLSL
        }
    }
}
