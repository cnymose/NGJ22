Shader "NGJ22/Toon Surface"
{
    Properties 
	{
		[Header(Base)]
		[Toggle(VERTEX_COLOR)] _VertexColor("Vertex Color", Float) = 0
		_Color("Color", Color) = (1,1,1,1)
		_OutlineWidth("Outline Width", Float) = 2
		[HDR]_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_MainTex("Texture", 2D) = "white" {}

		[Space]
		[Header(Halftone)]
		[Toggle(HALFTONE)] _Halftone("Halftone", Float) = 0
		[Toggle(HALFTONE_TRIPLANAR)] _HalftoneTriplanr("Halftone Triplanar", Float) = 0
		_HalftoneMin("Halftone Min", Range(0,1)) = 0
		_HalftoneMax("Halftone Max", Range(0,1)) = 1
		_HalftoneDiffuseLower("Halftone Diffuse Lower", Range(-1,1)) = 0
		_HalftoneDiffuseUpper("Halftone Diffuse Upper", Range(-1,1)) = 1
		_HalftoneAdditiveLower("Halftone Additive Lower", Range(0,1)) = 0
		_HalftoneAdditiveUpper("Halftone Additive Upper", Range(0,1)) = 1
		_HalftoneScale("Halftone Scale", Float) = 1
		_HalftoneTexture("Halftone Texture", 2D) = "white"{}

		[Space]
		[Header(Emission)]
		[Toggle(EMISSION)] _Emission("Emission", Float) = 0
		_EmissionTex("Emission Texture", 2D) = "white"{}
		[HDR] _EmissionColor("Emission Color", Color) = (0,0,0,1)

		[Space]
		[Header(Lighting)]
		[Toggle(DIFFUSE)] _Diffuse("Diffuse Lighting", Float) = 1
		_DiffuseMin("Diffuse Min", Range(0,1)) = 0
		_DiffuseMax("Diffuse Max", Range(0,1)) = 1

		[Space]
		[Header(Rim Lighting)]
		[Toggle(RIM)] _Rim("Rim Lighting", Float) = 0
		[Toggle(LIGHT_AFFECTS_RIM)] _LightAffectsRim("Light Affects Rim", Float) = 0
		[HDR] _RimColor("Rim Color", Color) = (1,1,1,1)
		_RimMin("Rim Min", Range(0,1)) = 0
		_RimMax("Rim Max", Range(0,1)) = 1
		_RimPower("Rim Power", Range(0,16)) = 2
		_RimScale("Rim Scale", Float) = 1

		[Toggle(HALFTONE_RIM)] _HalftoneRim("Halftone Rim", Float) = 0
		_HalftoneScaleRim("Halftone Scale Rim", Float) = 64
		_HalftonePatternRim("Halftone Pattern Rim", 2D) = "white"{}
		_HalftoneRimMin("Halftone Rim Min", Range(0, 1)) = 0
		_HalftoneRimMax("Halftone Rim Max", Range(0, 1)) = 1
		_HalftoneRimPower("Halftone Rim Power", Range(0, 16)) = 1
		_HalftoneRimColor("Halftone Rim Color", Color) = (1,1,1,1)
		
		[Space]
		[Header(Specular Lighting)]
		[Toggle(SPECULAR)] _Specular("Specular Lighting", Float) = 0
		_SpecularPower("Specular Power", Range(0,128)) = 2
		_SpecularScale("Specular Scale", Float) = 1
		_SpecularMin ("Specular Min", Range(0,1)) = 0
		_SpecularMax ("Specular Max", Range(0,1)) = 1

		[Space]
		[Header(Render Settings)]
		[Enum(UnityEngine.Rendering.CompareFunction)] _CompareFunction("Compare Function", Float) = 4
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", Float) = 2
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend Src", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend Dst", Float) = 0
		[Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 1
		
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }
		
		Pass
		{
			Cull Front
		
			HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma vertex vert
            #pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			float _OutlineWidth;
			float4 _OutlineColor;
		
			struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
            };
		
            struct v2f
            {
                float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD1;
            };
		
			v2f vert (appdata v)
            {
                v2f o;
				VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal);
				float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, normalInput.normalWS);
				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				float4 clipPos = vertexInput.positionCS;
				float2 offset = (normalize(clipNormal.xy) / _ScreenParams.xy) * _OutlineWidth * clipPos.w * 2;
				clipPos.xy += offset;
				o.pos = clipPos;
				o.worldPos = vertexInput.positionWS;
				return o;
			}
			half4 frag (v2f i) : SV_Target
            {
				return _OutlineColor; 
			}
			ENDHLSL
		}

        Pass
        {
			Tags{"LightMode" = "UniversalForward"}
			Blend [_BlendSrc] [_BlendDst]
			Cull [_CullMode]
			ZTest [_CompareFunction]
			ZWrite [_ZWrite]

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

			#pragma shader_feature_local HALFTONE_SAMPLE_ALPHA
			#pragma shader_feature_local VERTEX_COLOR
			#pragma shader_feature_local DIFFUSE
			#pragma shader_feature_local EMISSION
			#pragma shader_feature_local RIM
			#pragma shader_feature_local HALFTONE_RIM
			#pragma shader_feature_local HALFTONE
			#pragma shader_feature_local HALFTONE_TRIPLANAR
			#pragma shader_feature_local LIGHT_AFFECTS_RIM
			#pragma shader_feature_local SPECULAR

			#include "../Shaders/Hatching.hlsl"
			#include "../Shaders/Halftone.hlsl" 
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
				float4 color : COLOR;
#if MAIN_LIGHT_SHADOWS && defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD1;
#endif
				float3 worldNormal : NORMAL;
#if RIM || SPECULAR
				float3 viewDir : TEXCOORD2;
#endif
				float3 worldPos : TEXCOORD3;
#if HALFTONE_RIM && !HALFTONE_TRIPLANAR
				float4 halftoneRimScreenPos : TEXCOORD4;
#endif
#if HALFTONE && !HALFTONE_TRIPLANAR
				float4 halftoneScreenPos : TEXCOORD5;
#endif
				float4 screenPos : TEXCOORD6;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Color;
			float _Steps;

            sampler2D _EmissionTex;
			float4 _EmissionColor;

			float _DiffuseMin;
			float _DiffuseMax;
			float _DiffuseContrast;
#if SPECULAR
			float _SpecularPower;
			float _SpecularScale;
			float _SpecularMin;
			float _SpecularMax;
#endif
#if RIM
			float _RimMin;
			float _RimMax;
			float _RimPower;
			float _RimScale;
	#if !RIM_USES_LIGHTCOLOR
			float4 _RimColor;
	#endif
	#if HALFTONE_RIM
			TEXTURE2D(_HalftonePatternRim);
			SAMPLER(sampler_HalftonePatternRim);
			float _HalftoneScaleRim;
			float4 _HalftoneRimColor;
			float _HalftoneRimMin;
			float _HalftoneRimMax;
			float _HalftoneRimPower;
	#endif
#endif
#if HALFTONE
			TEXTURE2D(_HalftoneTexture);
			SAMPLER(sampler_HalftoneTexture);
			float _HalftoneScale;
			float _HalftoneMin;
			float _HalftoneMax;
			float _HalftoneDiffuseLower;
			float _HalftoneDiffuseUpper;			
			float _HalftoneAdditiveLower;
			float _HalftoneAdditiveUpper;

#endif
			inline half TriplanarMappingSingle(Texture2D tex, SamplerState texSampler, float3 weights, float3 worldPos, float scale)
			{
				float2 xUV = worldPos.zy / scale;
				float2 yUV = worldPos.xz / scale;
				float2 zUV = worldPos.xy / scale;

				half sampleX = SAMPLE_TEXTURE2D(tex, texSampler, xUV).r;
				half sampleY = SAMPLE_TEXTURE2D(tex, texSampler, yUV).r;
				half sampleZ = SAMPLE_TEXTURE2D(tex, texSampler, zUV).r;

				return sampleX * weights.x + sampleY * weights.y + sampleZ * weights.z;
			}

			inline half3 TriplanarWeights(float3 normal)
			{
				half3 blend = pow(abs(normal), 4);
				blend = normalize(max(blend, 0.0001));
				return blend / dot(blend, float3(1, 1, 1));
			}
#if HALFTONE_RIM || HALFTONE
			float4 DistanceBasedScreenPos(float4 clipPos, float scale) 
			{
				float screenAspect = _ScreenParams.x / _ScreenParams.y;
				float4 screenPos = ComputeScreenPos(clipPos);
				screenPos.x *= screenAspect;
				float4 clipPivot = mul(UNITY_MATRIX_MVP, float4(0, 0, 0, 1));
				float4 screenPivot = ComputeScreenPos(clipPivot);
				screenPivot.x *= screenAspect;
				float4 worldPivot = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
				screenPos = (((screenPos / screenPos.w) * scale - (screenPivot / screenPivot.w) * scale)) * length(_WorldSpaceCameraPos.xyz - worldPivot.xyz);
				return screenPos;
			}
#endif
			float GetDiffuse(float NDotL)
			{
				//float diff = (NDotL - 0.5) * _DiffuseContrast + 0.5;
				//diff = round(diff * _Steps) / _Steps;
				float diff = smoothstep(_DiffuseMin, _DiffuseMax, NDotL);
				return diff;
			}


            v2f vert (appdata v)
            {
                v2f o;
				o.color = _Color;
#if VERTEX_COLOR
				o.color *= v.color;
#endif
				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal);

				o.worldNormal = normalInput.normalWS;
                o.pos = vertexInput.positionCS;
				o.worldPos = vertexInput.positionWS;
#ifdef MAIN_LIGHT_SHADOWS
	#if REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
				o.shadowCoord = GetShadowCoord(vertexInput);
	#endif
#endif

#if RIM ||SPECULAR
				o.viewDir = _WorldSpaceCameraPos - vertexInput.positionWS.xyz; 
#endif
#if HALFTONE_RIM && !HALFTONE_TRIPLANAR
				o.halftoneRimScreenPos = DistanceBasedScreenPos(o.pos, _HalftoneScaleRim);
#endif
#if HALFTONE && !HALFTONE_TRIPLANAR
				o.halftoneScreenPos = DistanceBasedScreenPos(o.pos, _HalftoneScale);
#endif
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.screenPos = ComputeScreenPos(o.pos);
				o.screenPos.x *= _ScreenParams.x / _ScreenParams.y;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 baseCol = tex2D(_MainTex, i.uv) * i.color;
				float3 worldNormal = normalize(i.worldNormal);

#if HALFTONE_TRIPLANAR
				half3 triplanarWeights = TriplanarWeights(worldNormal);
#endif

#if MAIN_LIGHT_SHADOWS && defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				Light mainLight = GetMainLight(i.shadowCoord);
#else
				Light mainLight = GetMainLight();
#endif
#if RIM || SPECULAR
				float3 viewDir = normalize(i.viewDir);
#endif
				float lightVal = 0;
				float3 lightDir = normalize(mainLight.direction);
				float NDotLRaw = dot(worldNormal, lightDir);
				float NDotL = max(0, NDotLRaw);
				float shadowAtten = 1;
#if MAIN_LIGHT_SHADOWS
		#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					shadowAtten = mainLight.shadowAttenuation;
		#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					shadowAtten = MainLightRealtimeShadow(TransformWorldToShadowCoord(i.worldPos));
		#endif
#endif

				NDotL *= shadowAtten;
				float diff = GetDiffuse(NDotL);				

#if SPECULAR
				float3 halfVector = normalize(i.viewDir.xyz + mainLight.direction.xyz);
				float NDotH = saturate(dot(worldNormal,halfVector));
				float spec = SafePositivePow(NDotH, _SpecularPower);
            	spec = smoothstep(_SpecularMin, _SpecularMax, spec);
				lightVal += spec * _SpecularScale * diff;
#endif

#if RIM
				float NDotV = 1 - max(0, dot(worldNormal, viewDir));
				float rim = SafePositivePow(NDotV, _RimPower);
				float LDotV = max(0, dot(-viewDir, lightDir));
				float look = (0.4 + 0.6 * LDotV);
				rim *= look * _RimScale;
				rim = smoothstep(_RimMin, _RimMax, rim);

				lightVal += rim;
#endif


#if HALFTONE_RIM
				float halftoneSampleRim = 0;
#if HALFTONE_TRIPLANAR
				halftoneSampleRim = TriplanarMappingSingle(_HalftonePatternRim, sampler_HalftonePatternRim, triplanarWeights, i.worldPos, _HalftoneScaleRim);
#else
				halftoneSampleRim = 1 - SAMPLE_TEXTURE2D(_HalftonePatternRim, sampler_HalftonePatternRim, i.halftoneRimScreenPos.xy).a;
#endif
				float rimHalftoneBase = SafePositivePow(NDotV, _HalftoneRimPower);
				float rimHalftoneA = diff * (rim + GetHalftone(halftoneSampleRim, rim + rimHalftoneBase, _HalftoneRimMin, _HalftoneRimMax));
				//float rimHalftoneB = diff * (rim + GetHalftone(halftoneSampleRim, rim + rimHalftoneBase * 0.4, _HalftoneRimMin, _HalftoneRimMax + .2));
				baseCol.rgb = lerp(baseCol.rgb, _HalftoneRimColor.rgb, rimHalftoneA);
#endif
				float3 ambient = SampleSH(worldNormal);
				float4 col = float4(baseCol.rgb * (0.4 + diff * 0.6) * (ambient + mainLight.color.rgb), baseCol.a);


				col.rgb += lightVal * (ambient + mainLight.color.rgb) * shadowAtten;

#if HALFTONE
				float halftoneSample;

	#if HALFTONE_TRIPLANAR
				halftoneSample = TriplanarMappingSingle(_HalftoneTexture, sampler_HalftoneTexture, triplanarWeights, i.worldPos, _HalftoneScale);
	#else
				halftoneSample = SAMPLE_TEXTURE2D(_HalftoneTexture, sampler_HalftoneTexture, i.halftoneScreenPos.xy).r;
	#endif
				halftoneSample = lerp(_HalftoneMin, _HalftoneMax, halftoneSample);
				halftoneSample *= 1 - saturate(i.screenPos.w / 12.5);
				float  halftoneValue = lerp(0, halftoneSample ,(smoothstep(_HalftoneDiffuseLower, _HalftoneDiffuseUpper, NDotLRaw - (1 - shadowAtten))));
				col.rgb *= min(1, 0.2 + lerp(halftoneValue, 0.8, smoothstep(0, 1, diff)));
				
				//float halftoneChange = fwidth(halftoneValue) * 0.5;
				//diff = smoothstep(halftoneValue - halftoneChange, halftoneValue + halftoneChange, diff);
#endif

#ifdef _ADDITIONAL_LIGHTS
				int additionalLightsCount = GetAdditionalLightsCount();
                for (int l = 0; l < additionalLightsCount; ++l)
                {
                    Light light = GetAdditionalLight(l, i.worldPos);

					float atten = light.distanceAttenuation * light.shadowAttenuation;
					float addNDotL = max(0, dot(worldNormal, light.direction)) * atten;
                	float add = smoothstep(_DiffuseMin, _DiffuseMax, addNDotL);

#if HALFTONE
					float addHalftone = lerp(halftoneSample, 1 ,(smoothstep(_HalftoneAdditiveLower, _HalftoneAdditiveUpper, addNDotL)));
					addNDotL *= addHalftone;
#endif
					
                    col.rgb += add * baseCol.rgb  * light.color;
					
#if SPECULAR
					halfVector = normalize(i.viewDir.xyz + light.direction.xyz);
					NDotH = saturate(dot(worldNormal,halfVector));
					float addSpec = SafePositivePow(NDotH, _SpecularPower) * atten;
					col.rgb += addSpec * light.color;

#endif
#if RIM
					float addLDotV = max(0, dot(-viewDir, light.direction));
					float addRim = rim * atten * (0.5 + addLDotV * 0.5);
					col.rgb += addRim * light.color;
#endif
                }
#endif

#if EMISSION
				col.rgb += _EmissionColor.rgb * tex2D(_EmissionTex, i.uv).rgb;
#endif

				return  col;
            }
            ENDHLSL
        }

		Pass{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

			
			float3 _LightDirection;
			
			struct Attributes
			{
			    float4 positionOS   : POSITION;
			    float3 normalOS     : NORMAL;
			};
			
			struct Varyings
			{
			    float4 positionCS   : SV_POSITION;
			};
			
			float4 GetShadowPositionHClip(Attributes input)
			{
			    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
			    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
			    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
			
			#if UNITY_REVERSED_Z
			    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
			#else
			    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
			#endif
			
				return positionCS;
			}
			
			Varyings ShadowPassVertex(Attributes input)
			{
			    Varyings output;			
			    output.positionCS = GetShadowPositionHClip(input);
			    return output;
			}
			
			half4 ShadowPassFragment(Varyings input) : SV_TARGET
			{
			    return 0;
			}

			ENDHLSL
		}

		Pass
		{
		Name "DepthOnly"
		Tags { "LightMode" = "DepthOnly" }

		ZWrite On
		ColorMask 0

		HLSLPROGRAM
		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x gles

		#pragma vertex DepthOnlyVertex
		#pragma fragment DepthOnlyFragment

		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

		struct Attributes
		{
		    float4 position     : POSITION;
		};
		
		struct Varyings
		{
		    float4 positionCS   : SV_POSITION;
		};
		
		Varyings DepthOnlyVertex(Attributes input)
		{
		    Varyings output = (Varyings)0;
		    output.positionCS = TransformObjectToHClip(input.position.xyz);
		    return output;
		}
		
		half4 DepthOnlyFragment(Varyings input) : SV_TARGET
		{
			return 0;
		}

		ENDHLSL
		}
	}
	Fallback "Universal Render Pipeline/Lit"
}