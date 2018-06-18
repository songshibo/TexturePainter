#include "Lighting.cginc"

// Painter Function

bool ExistPointInTriangle(float3 p, float3 t1, float3 t2, float3 t3)
{
    const float TOLERANCE = 1 - 0.1;

    float3 a = normalize(cross(t1 - t3, p - t1));
    float3 b = normalize(cross(t2 - t1, p - t2));
    float3 c = normalize(cross(t3 - t2, p - t3));

    float d_ab =dot(a, b);
    float d_bc =dot(b, c);

    if (TOLERANCE < d_ab && TOLERANCE < d_bc) {
        return true;
    }
    return false;
}

bool IsPaintRange(float2 mainUV, float2 paintUV, float brushScale)
{
    float3 p = float3(mainUV, 0);
    float3 v1 = float3(float2(-brushScale, brushScale) + paintUV, 0);
    float3 v2 = float3(float2(-brushScale, -brushScale) + paintUV, 0);
    float3 v3 = float3(float2(brushScale, -brushScale) + paintUV, 0);
    float3 v4 = float3(float2(brushScale, brushScale) + paintUV, 0);
    return ExistPointInTriangle(p, v1, v2, v3) || ExistPointInTriangle(p, v1, v3, v4);
}

float2 CalcBrushUV(float2 mainUV, float2 paintUV, float brushScale) {
#if UNITY_UV_STARTS_AT_TOP
    return (mainUV - paintUV) / brushScale * 0.5 + 0.5;
#else
    return (paintUV - mainUV) / brushScale * 0.5 + 0.5;
#endif
}



float4 ColorBlend(float4 targetColor, float4 originColor, float blend)
{
    //return originColor * (1 - blend * targetColor.a) + targetColor * targetColor.a * blend;
    return lerp(originColor, targetColor, blend);
}

float4 ColorBlendUseControl(float4 mainColor, float4 brushColor, float4 controlColor)
{
    return ColorBlend(controlColor, mainColor, brushColor.a);
}

float4 ColorBlendUseNeutral(float4 mainColor, float4 brushColor, float4 controlColor)
{
    return ColorBlend((brushColor+mainColor * controlColor.a)*0.5, mainColor, brushColor.a);
}



float4 NormalBlend(float4 targetNormal,float4 mainNormal, float blend, float brushAlpha)
{
	float4 normal = lerp(mainNormal, targetNormal, blend * brushAlpha);
#if defined(UNITY_NO_DXT5nm)
	return normal;
#else
	normal.w = normal.x;
	normal.xyz = normal.y;
	return normal;
#endif
}

float4 NormalBlendUseBrush(float4 mainNormal, float4 brushNormal, float blend, float brushAlpha)
{
    return NormalBlend(brushNormal, mainNormal, blend, brushAlpha);
}

float4 NormalBlendAdd(float4 mainNormal, float4 brushNormal, float blend, float brushAlpha)
{
    return NormalBlend((brushNormal + mainNormal), mainNormal, blend, brushAlpha);
}


float4 HeightBlend(float4 targetHeight, float4 mainHeight, float blend, float4 brushColor)
{
	return lerp(mainHeight, targetHeight, blend * brushColor.a);
}

float4 HeightBlendUseBrush(float4 mainHeight, float4 brushHeight, float blend, float4 brushColor) {
	return HeightBlend(brushHeight, mainHeight, blend, brushColor);
}

float4 HeightBlendAdd(float4 mainHeight, float4 brushHeight, float blend, float4 brushColor) {
	return HeightBlend((mainHeight + brushHeight), mainHeight, blend, brushColor);
}

float3 VertexBlendUseAlpha(float4 lay1, float4 lay2, float4 lay3, float4 controlColor, float weight)
{
    float3 blend;
    blend.r = lay1.a * controlColor.r;
    blend.g = lay2.a * controlColor.g;
    blend.b = lay3.a * controlColor.b;

    fixed maximum = max(blend.r, max(blend.g, blend.b));

    blend.r = max(blend.r - maximum + weight, 0);
    blend.g = max(blend.g - maximum + weight, 0);
    blend.b = max(blend.b - maximum + weight, 0);
    return blend/(blend.r + blend.g + blend.b);

}

float3 VertexBlendUseHeight(float d1, float d2, float d3, float4 controlColor, float weight)
{
    float3 blend;
    blend.r = d1 * controlColor.r;
    blend.g = d1 * controlColor.g;
    blend.b = d1 * controlColor.b;

    fixed maximum = max(blend.r, max(blend.g, blend.b));

    blend.r = max(blend.r - maximum + weight, 0);
    blend.g = max(blend.g - maximum + weight, 0);
    blend.b = max(blend.b - maximum + weight, 0);
    return blend/(blend.r + blend.g + blend.b);
}

// Lighting function 4 v-f shader

float4x4 inverse(float4x4 input) {
    #define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
    
    float4x4 cofactors = float4x4(
         minor(_22_23_24, _32_33_34, _42_43_44), 
        -minor(_21_23_24, _31_33_34, _41_43_44),
         minor(_21_22_24, _31_32_34, _41_42_44),
        -minor(_21_22_23, _31_32_33, _41_42_43),
        
        -minor(_12_13_14, _32_33_34, _42_43_44),
         minor(_11_13_14, _31_33_34, _41_43_44),
        -minor(_11_12_14, _31_32_34, _41_42_44),
         minor(_11_12_13, _31_32_33, _41_42_43),
        
         minor(_12_13_14, _22_23_24, _42_43_44),
        -minor(_11_13_14, _21_23_24, _41_43_44),
         minor(_11_12_14, _21_22_24, _41_42_44),
        -minor(_11_12_13, _21_22_23, _41_42_43),
        
        -minor(_12_13_14, _22_23_24, _32_33_34),
         minor(_11_13_14, _21_23_24, _31_33_34),
        -minor(_11_12_14, _21_22_24, _31_32_34),
         minor(_11_12_13, _21_22_23, _31_32_33)
    );
    #undef minor
    return transpose(cofactors) / determinant(input);
}

float4 SampleTexture(sampler2D Tex, float2 uv)
{
#if SHADER_TARGET < 30
    return tex2D(Tex, uv);
#else
    return tex2Dlod(Tex, float4(uv, 0, 0));
#endif
}

float3 SampleTangentNormal(sampler2D normal, float2 uv, float _Bumpscale)
{
    fixed4 packednormal = tex2D(normal,uv);
    float3 tangentnormal = UnpackNormal(packednormal);
    tangentnormal.xy *= _Bumpscale;
    tangentnormal.z = sqrt(1.0 - saturate(dot(tangentnormal.xy,tangentnormal.xy)));

    return tangentnormal;
}

float4 SampleRamp(sampler2D Ramp, float3 normal, float3 lightDir)
{
    float halfLambert = dot(normal, lightDir) * 0.5 + 0.5;
    return tex2D(Ramp, float2(halfLambert, halfLambert));
}

float StepRampDiffuse(float3 normal, float3 lightDir, float step, float atten)
{
    float halfLambert = dot(normal, lightDir) * 0.5 + 0.5;
    float diff = smoothstep(0,1,halfLambert);
    return floor(diff * atten * step)/step;
}

float StepRampSpecular(float3 normal, float3 halfDir, float step, float atten, float gloss)
{
    float specular = max(0, dot(normal, halfDir));
    float toonSpec = pow(specular, gloss);
    return floor(toonSpec * atten * step)/step;
}

// vertex part

    // Use the result to multiply ObjectSpaceLightDir(vertex) & ObjectSpaceViewDir(vertex) to 
    // transform them into tangent space
float3x3 TangentRotationMatrixForObject(float3 normal, float4 tangent)
{
    float3 binormal = cross(normalize(normal), normalize(tangent.xyz)) * tangent.w;
    float3x3 rotation = float3x3(tangent.xyz, binormal, normal);
    return rotation;
}

    // Use the result to multiply WorldSpaceLightDir(vertex) & WorldSpaceViewDir(vertex) to 
    // transform them into tangent space
float3x3 TangentRotationMatrixForWorld(float3 normal, float4 tangent)
{
    float3 worldNormal = mul(unity_ObjectToWorld, normal);
    float3 worldTangent = mul(unity_ObjectToWorld, tangent.xyz);
    float3 worldBinormal = cross(worldNormal, worldTangent) * tangent.w;

    float4x4 TangentToWorld = float4x4(worldTangent.x, worldBinormal.x, worldNormal.x, 0.0,
                                       worldTangent.y, worldBinormal.y, worldNormal.y, 0.0,
                                       worldTangent.z, worldBinormal.z, worldNormal.z, 0.0,
                                       0.0, 0.0, 0.0, 1.0);
    float3x3 WorldToTagent = inverse(TangentToWorld);
    return WorldToTagent;
}

// fragment part

float3 DiffuseLambert(float3 color, float3 normal, float3 lightDir)
{
    return _LightColor0.rgb * color * max(0,dot(normal, lightDir));
}

float3 DiffuseHL(float3 color, float3 normal, float3 lightDir)
{
    return _LightColor0.rgb * color * (dot(normal, lightDir)*0.5f + 0.5f);
}