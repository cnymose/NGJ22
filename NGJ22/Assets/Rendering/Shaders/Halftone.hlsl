inline float GetHalftone(float halftoneSample, float scale, float mapMin, float mapMax) 
{
    halftoneSample = lerp(mapMin, mapMax, halftoneSample);
    float halftoneChange = fwidth(halftoneSample) * 0.5;
    return smoothstep(halftoneSample - halftoneChange, halftoneSample + halftoneChange, scale);
}