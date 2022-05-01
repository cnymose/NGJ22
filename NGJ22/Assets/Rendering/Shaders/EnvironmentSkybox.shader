Shader "NGJ22/Environment Skybox"
{
	Properties
	{
		[HDR]_NoiseColorA("Noise Color A", Color) = (1,1,1,1)
		[HDR]_NoiseColorB("Noise Color B", Color) = (1,1,1,1)
		_EnvironmentGradient("Gradient", 2D) = "black"
		_NoiseTextureA("Noise Texture A", 2D) = "black"
		_NoiseTextureB("Noise Texture B", 2D) = "black"
		_NoiseRangeA("NoiseRange A", Vector) = (0,1,0,0)
		_NoiseRangeB("NoiseRange B", Vector) = (0,1,0,0)
		_NoiseAnimationSpeedA("NoiseAnimationSpeed A", Float) = 1
		_NoiseAnimationSpeedB("NoiseAnimationSpeed B", Float) = 1
	}

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            
			#include "../Shaders/Environment/Environment.hlsl"       

            struct appdata
            {
                float4 vertex   : POSITION;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos  : SV_POSITION;
				float3 worldPos : TEXCOORD0;
            };            

			TEXTURE2D(_NoiseTextureA);
			float4 _NoiseTextureA_ST;
			TEXTURE2D(_NoiseTextureB);
			float4 _NoiseTextureB_ST;
			SAMPLER(sampler_NoiseTextureA);
			SAMPLER(sampler_NoiseTextureB);

			float3 _NoiseColorA;
			float3 _NoiseColorB;

			float2 _NoiseRangeA;
			float2 _NoiseRangeB;
			float _NoiseAnimationSpeedA;
			float _NoiseAnimationSpeedB;

			inline float2 RadialCoords(float3 a_coords)
			{
				float3 a_coords_n = normalize(a_coords);
				float lon = atan2(a_coords_n.z, a_coords_n.x);
				float lat = acos(a_coords_n.y);
				float2 sphereCoords = float2(lon, lat) * (1.0 / PI);
				return float2(sphereCoords.x * 0.5 + 0.5, 1 - sphereCoords.y);
			}

            v2f vert(appdata v)
            {
                v2f o;
				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                o.pos = vertexInput.positionCS;
				float3 worldPos = normalize(vertexInput.positionWS);
				o.worldPos = worldPos;
                return o;
            }

            // The fragment shader definition.            
            float4 frag(v2f i) : SV_Target
            {
				float2 uv = RadialCoords(i.worldPos);
				float noiseA = SAMPLE_TEXTURE2D(_NoiseTextureA, sampler_NoiseTextureA, uv * _NoiseTextureA_ST.xy + _NoiseTextureA_ST.zw + float2(_Time.x * _NoiseAnimationSpeedA, 0)).r;
				noiseA = smoothstep(_NoiseRangeA.x, _NoiseRangeA.y, noiseA);
				float noiseB = SAMPLE_TEXTURE2D(_NoiseTextureB, sampler_NoiseTextureB, uv * _NoiseTextureB_ST.xy + _NoiseTextureB_ST.zw + float2(_Time.x * _NoiseAnimationSpeedB, 0)).r;
				noiseB = smoothstep(_NoiseRangeB.x, _NoiseRangeB.y, noiseB);
				float noise = saturate(noiseA + noiseB) * smoothstep(0.3, 0.7, uv.y);
				float3 noiseColor = noiseA * _NoiseColorA + noiseB * _NoiseColorB;
				float3 environmentColor = GetSunColor(i.worldPos).rgb + GetEnvironmentColor(i.worldPos * 100000).rgb;
				return float4(lerp(environmentColor, environmentColor * noiseColor, noise),1);
            }
            ENDHLSL
        }
    }
}