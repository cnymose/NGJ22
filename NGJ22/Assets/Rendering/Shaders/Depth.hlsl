#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

float SampleDepth(float2 uv)
{
#if UNITY_REVERSED_Z
	return SampleSceneDepth(uv);
#else
	return lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(uv));
#endif
}

inline float SampleLinearDepth(float2 uv)
{
	float depth = SampleDepth(uv);
	return LinearEyeDepth(depth, _ZBufferParams);
}