float3 Hatching(half3 sampleA, half3 sampleB, half intensity)
{
	half3 overbright = max(0, intensity - 1.0);

	half3 weightsA = saturate((intensity * 6.0) + half3(-0, -1, -2));
	half3 weightsB = saturate((intensity * 6.0) + half3(-3, -4, -5));

	weightsA.xy -= weightsA.yz;
	weightsA.z -= weightsB.x;
	weightsB.xy -= weightsB.yz;

	sampleA = sampleA * weightsA;
	sampleB = sampleB * weightsB;

	half3 hatching = overbright + sampleA.r +
		sampleA.g + sampleA.b +
		sampleB.r + sampleB.g +
		sampleB.b;

	return hatching;
}