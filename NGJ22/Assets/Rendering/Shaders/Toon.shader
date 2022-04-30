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
		[Toggle(AMBIENT)]_Ambient("Ambient", Float) = 1

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
            
			#pragma shader_feature_local VERTEX_COLOR
			#pragma shader_feature_local DIFFUSE
			#pragma shader_feature_local EMISSION
			#pragma shader_feature_local RIM
			#pragma shader_feature_local LIGHT_AFFECTS_RIM
			#pragma shader_feature_local SPECULAR
			#pragma shader_feature_local AMBIENT
            
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
#if defined(_MAIN_LIGHT_SHADOWS) && defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD1;
#endif
				float3 worldNormal : NORMAL;
#if RIM || SPECULAR
				float3 viewDir : TEXCOORD2;
#endif
				float3 worldPos : TEXCOORD3;
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
#if defined(_MAIN_LIGHT_SHADOWS)
	#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				o.shadowCoord = GetShadowCoord(vertexInput);
	#endif
#endif

#if RIM ||SPECULAR
				o.viewDir = _WorldSpaceCameraPos - vertexInput.positionWS.xyz; 
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
            	
#if defined(_MAIN_LIGHT_SHADOWS) && defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
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
#if defined(_MAIN_LIGHT_SHADOWS)
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
#if AMBIENT
				float3 ambient = SampleSH(worldNormal);
#else
            	float3 ambient = 1;
#endif
            	
            	float4 col = float4(ambient * baseCol, baseCol.a);
            	float4 colRef = col;

#ifdef _ADDITIONAL_LIGHTS
				int additionalLightsCount = GetAdditionalLightsCount();
                for (int l = 0; l < additionalLightsCount; ++l)
                {
                    Light light = GetAdditionalLight(l, i.worldPos);

					float atten = light.distanceAttenuation * light.shadowAttenuation;
#if defined(_ADDITIONAL_LIGHT_SHADOWS)
                	float addShadow = AdditionalLightRealtimeShadow(l, i.worldPos, normalize(light.direction));
#else
                	float addShadow = 1; 
#endif
					float addNDotL = max(0, dot(worldNormal, light.direction)) * atten * addShadow;
					float add = smoothstep(_DiffuseMin, _DiffuseMax, addNDotL);
                	
                    col.rgb += add * light.color * colRef.rgb;
					
#if SPECULAR
					halfVector = normalize(i.viewDir.xyz + light.direction.xyz);
					NDotH = saturate(dot(worldNormal,halfVector));
					float addSpec = SafePositivePow(NDotH, _SpecularPower) ;
					col.rgb += smoothstep(_SpecularMin, _SpecularMax, addSpec) * light.color * _SpecularScale * addShadow;

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