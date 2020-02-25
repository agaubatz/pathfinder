// Automatically generated from files in pathfinder/shaders/. Do not edit!
#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct spvDescriptorSetBuffer0
{
    texture2d<float> uStencilTexture [[id(0)]];
    sampler uStencilTextureSmplr [[id(1)]];
    texture2d<float> uPaintTexture [[id(2)]];
    sampler uPaintTextureSmplr [[id(3)]];
    constant float2* uFramebufferSize [[id(4)]];
    texture2d<float> uDest [[id(5)]];
    sampler uDestSmplr [[id(6)]];
    constant int3* uBlendHSL [[id(7)]];
};

struct main0_out
{
    float4 oFragColor [[color(0)]];
};

struct main0_in
{
    float2 vColorTexCoord [[user(locn0)]];
    float2 vMaskTexCoord [[user(locn1)]];
};

// Implementation of the GLSL mod() function, which is slightly different than Metal fmod()
template<typename Tx, typename Ty>
Tx mod(Tx x, Ty y)
{
    return x - y * floor(x / y);
}

float4 sampleSrcColor(thread texture2d<float> uStencilTexture, thread const sampler uStencilTextureSmplr, thread float2& vMaskTexCoord, thread texture2d<float> uPaintTexture, thread const sampler uPaintTextureSmplr, thread float2& vColorTexCoord)
{
    float coverage = uStencilTexture.sample(uStencilTextureSmplr, vMaskTexCoord).x;
    float4 srcRGBA = uPaintTexture.sample(uPaintTextureSmplr, vColorTexCoord);
    return float4(srcRGBA.xyz, srcRGBA.w * coverage);
}

float4 sampleDestColor(thread float4& gl_FragCoord, thread float2 uFramebufferSize, thread texture2d<float> uDest, thread const sampler uDestSmplr)
{
    float2 destTexCoord = gl_FragCoord.xy / uFramebufferSize;
    return uDest.sample(uDestSmplr, destTexCoord);
}

float3 convertRGBToHSL(thread const float3& rgb)
{
    float v = fast::max(rgb.y, rgb.z);
    float c = v - fast::min(rgb.y, rgb.z);
    float l = v - (0.5 * c);
    float3 tmp = float3(0.0);
    bool3 is_v = rgb == float3(v);
    if (is_v.x)
    {
        tmp = float3(0.0, rgb.yz);
    }
    else
    {
        if (is_v.y)
        {
            tmp = float3(2.0, rgb.zx);
        }
        else
        {
            if (is_v.z)
            {
                tmp = float3(4.0, rgb.xy);
            }
        }
    }
    float h = 1.0471975803375244140625 * (tmp.x + ((tmp.y - tmp.z) / c));
    float s = 0.0;
    if ((l > 0.0) && (l < 1.0))
    {
        s = (v - l) / fast::min(l, 1.0 - l);
    }
    return float3(h, s, l);
}

float3 convertHSLToRGB(thread const float3& hsl)
{
    float a = hsl.y * fast::min(hsl.z, 1.0 - hsl.z);
    float3 ks = mod(float3(0.0, 8.0, 4.0) + float3(hsl.x * 1.90985929965972900390625), float3(12.0));
    return hsl.zzz - (fast::clamp(fast::min(ks - float3(3.0), float3(9.0) - ks), float3(-1.0), float3(1.0)) * a);
}

float4 blendColors(thread const float4& destRGBA, thread const float4& srcRGBA, thread const float3& blendedRGB)
{
    return float4(((srcRGBA.xyz * (srcRGBA.w * (1.0 - destRGBA.w))) + (blendedRGB * (srcRGBA.w * destRGBA.w))) + (destRGBA.xyz * ((1.0 - srcRGBA.w) * destRGBA.w)), 1.0);
}

fragment main0_out main0(main0_in in [[stage_in]], constant spvDescriptorSetBuffer0& spvDescriptorSet0 [[buffer(0)]], float4 gl_FragCoord [[position]])
{
    main0_out out = {};
    float4 srcRGBA = sampleSrcColor(spvDescriptorSet0.uStencilTexture, spvDescriptorSet0.uStencilTextureSmplr, in.vMaskTexCoord, spvDescriptorSet0.uPaintTexture, spvDescriptorSet0.uPaintTextureSmplr, in.vColorTexCoord);
    float4 destRGBA = sampleDestColor(gl_FragCoord, (*spvDescriptorSet0.uFramebufferSize), spvDescriptorSet0.uDest, spvDescriptorSet0.uDestSmplr);
    float3 param = destRGBA.xyz;
    float3 destHSL = convertRGBToHSL(param);
    float3 param_1 = srcRGBA.xyz;
    float3 srcHSL = convertRGBToHSL(param_1);
    bool3 blendDest = (*spvDescriptorSet0.uBlendHSL) == int3(0);
    float _281;
    if (blendDest.x)
    {
        _281 = destHSL.x;
    }
    else
    {
        _281 = srcHSL.x;
    }
    float _292;
    if (blendDest.y)
    {
        _292 = destHSL.y;
    }
    else
    {
        _292 = srcHSL.y;
    }
    float _303;
    if (blendDest.z)
    {
        _303 = destHSL.z;
    }
    else
    {
        _303 = srcHSL.z;
    }
    float3 blendedHSL = float3(_281, _292, _303);
    float3 param_2 = blendedHSL;
    float3 blendedRGB = convertHSLToRGB(param_2);
    float4 param_3 = destRGBA;
    float4 param_4 = srcRGBA;
    float3 param_5 = blendedRGB;
    out.oFragColor = blendColors(param_3, param_4, param_5);
    return out;
}

