#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

sampler2D _EnvironmentGradient;
uniform float3 _SunColor;
uniform float _SunSize;

float3 GetSunColor(float3 worldPos)
{
	Light mainLight = GetMainLight();
	float3 worldDir = normalize(worldPos);
	float3 diff = worldDir - normalize(mainLight.direction);
	float dist = length(diff);
	float sun = 1 - smoothstep(_SunSize - 0.01, _SunSize, dist);
	sun *= sun;
	return sun * _SunColor;
}

float4 GetEnvironmentColor(float3 worldPos)
{
	Light mainLight = GetMainLight();
	//Get main directional light in world pos
	float3 normalizedLightPos =-normalize(mainLight.direction);
	//Get the world pos relative to camera
	float3 normalizedCameraRelativePos = normalize(worldPos - _WorldSpaceCameraPos.xyz);
	float gradientSample = (dot(normalizedLightPos, normalizedCameraRelativePos) + 1) / 2;
	return tex2D(_EnvironmentGradient, float2(gradientSample.x, 0));
}