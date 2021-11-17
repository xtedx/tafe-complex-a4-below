Shader "Custom/water shader"
{
    ///teddy: this is where we expose variables to get values from inspector
    ///like [serializefield] in csharp
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        //teddy start {: water flow map
        [NoScaleOffset] _FlowMap ("Flow (RG), Noise (A)", 2D) = "black" {}
        [NoScaleOffset] _DerivHeightMap ("Deriv (RG), Height (A)", 2D) = "black" {}
        
        _UJump("U jump per phase", Range(-0.25, 0.25)) = 0.25
        _VJump("V jump per phase", Range(-0.25, 0.25)) = 0.25
        _Tiling ("Tiling", float) = 1
        _Speed ("Speed", float ) = 1
        _FlowStrength ("Flow Strength", float) = 1
        _FlowOffset("Flow Offset", float) = 0
        _HeightScale ("Height Scale", float) = 0.25
        _HeightScaleModulated ("Height Scale Modulated", float) = 0.75
        
        _WaterFogColor("Water Fog Color", Color) = (0,0,0,0)
        _WaterFogDensity ("Water Fog Density", Range(0,2)) = 0.1
        _RefractionStrength( "Refraction Strength", Range(0,1)) = 0.1
        //} teddy end
    }
    
    SubShader
    {
        //teddy: change this to transparent
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200
        
        //teddy start{
        GrabPass{"_WaterBackground"}
        //} teddy end
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        //#pragma surface surf Standard fullforwardshadows
        //teddy: make it transparent
        #pragma surface surf Standard alpha finalcolor:ResetAlpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        ///teddy: this where we declare variables to use in surf function
        ///usually to use the properties exposed in inspectore, declared above in Properties{} 
        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            //teddy:
            float4 screenPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        //teddy start {
        sampler2D _FlowMap, _DerivHeightMap, _CameraDepthTexture, _WaterBackgroud;
        fixed4 _WaterFogColor;
        float _UJump, _VJump, _Tiling, _Speed, _FlowStrength, _FlowOffset;
        float _HeightScale, _HeightScaleModulated;
        float _WaterFogDensity;
        float4 _CameraDepthTexture_TexelSize;
        float _RefractionStrength;
        //} teddy end

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        // teddy start {

        void ResetAlpha(Input IN, SurfaceOutputStandard o, inout fixed4 color)
        {
            color.a = 1;
        }

        //for above the water
        float2 AlignWithGrabTexel(float2 uv)
        {
            #if UNITY_UV_STARTS_AT_TOP
            if (_CameraDepthTexture_TexelSize.x < 0)
            {
                uv.y = 1 - uv.y;
            }
            #endif
            return (floor(uv * _CameraDepthTexture_TexelSize.zw) + 0.5) * abs(_CameraDepthTexture_TexelSize.xy);
        }
        
        float3 ColorBelowWater(float4 screenPos, float3 tangentSpaceNormal)
        {
            float2 uvOffsetReflection = tangentSpaceNormal.xy * _RefractionStrength;
            uvOffsetReflection *= _CameraDepthTexture_TexelSize.z * abs(_CameraDepthTexture_TexelSize.y);
            float2 uv = (screenPos.xy + uvOffsetReflection)/ screenPos.w;

            //check if above water
            uv = AlignWithGrabTexel(uv);
            
            //sample depth texture, convert to a linear number space
            float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,uv));
            //What is the depth of the surface
            float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);
            //work out the depth from the surface to the objects behind it
            float depthDifference = backgroundDepth - surfaceDepth;
            uvOffsetReflection *= saturate(depthDifference);
            uv = AlignWithGrabTexel((screenPos.xy + uvOffsetReflection) / screenPos.w);
            backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
            depthDifference = backgroundDepth - surfaceDepth;
            float3 backgroundColor = tex2D(_WaterBackgroud, uv).rgb;
            float fogFactor = exp2(-_WaterFogDensity * depthDifference);
            return lerp(_WaterFogColor, backgroundColor, fogFactor);
        }

        float3 UnpackDerivativeHeight (float4 textureData)
        {
            float3 dh = textureData.agb;
            dh.xy = dh.xy * 2 - 1;
            return dh;
        }
        
        float2 FlowUV(float2 uv, float time)
        {
            return uv + time;
        }

        float3 FlowUVW(float2 uv, float2 flowVector, float2 jump, float flowOffset, float tiling, float time, bool flowB)
        {
            float phaseOffset = flowB ? 0.5 : 0;
            //frac - returns the fractional portion of a scalar or each vector component.
            // resets out X back to 0 once it passes 1
            float progress = frac(time + phaseOffset);
            float3 uvw;
            //uvw.xy = uv - flowVector * progress + phaseOffset;
            uvw.xy = uv - flowVector * (progress + flowOffset);
            uvw.xy *= tiling;
            uvw.xy += (time - progress) * jump;
            
            
            //abs - returns absolute value of scalars and vectors.
            //if the number is negative, its positive instead
            //triangle wave
            uvw.z = 1 - abs(1 - 2 * progress);
            return uvw;
        }
        
        //teddy: this is the function to move the uv with time
        // float3 FlowUVW(float2 uv, float2 flowVector, float time)
        // {
        //     //return uv + time; normal
        //     //return uv - flowVector + time;
        //
        //     // resets the pattern to loop at time interval, x goes back to 0 after it passes 1
        //     float progress = frac(time);
        //     // return uv - flowVector * progress;
        //
        //     //triangle wave?? use it to make it go dark 
        //     float uvw;
        //     uvw.xy = uv - flowVector * progress;
        //     uvw.z = 1 - abs(1 - 2 * progress);
        //     return uvw;
        // }

        void surf_water (Input IN, inout SurfaceOutputStandard o)
        {
            //Shader compiler will optimise multiple samples into one single texture sample
            float4 flowSample = tex2D(_FlowMap, IN.uv_MainTex);
            float2 flowVector = flowSample.rg * 2 - 1;
            flowVector *= _FlowStrength;
            float noise = flowSample.a;
            float time = _Time.y * _Speed + noise;
            float2 jump = float2(_UJump, _VJump);
            
            float3 uvwA = FlowUVW(IN.uv_MainTex, flowVector, jump,_FlowOffset, _Tiling , time, false);
            float3 uvwB = FlowUVW(IN.uv_MainTex, flowVector, jump, _FlowOffset,  _Tiling , time, true);

            float finalHeightScale = flowSample.b * _HeightScaleModulated + _HeightScale;
            float3 dhA = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwA.xy)) * (uvwA.z  * finalHeightScale);
            float3 dhB = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwB.xy)) * (uvwB.z * finalHeightScale);
            o.Normal = normalize(float3(-(dhA.xy + dhB.xy),1));
            
            fixed4 texA = tex2D (_MainTex, uvwA.xy) * uvwA.z ;
            fixed4 texB = tex2D (_MainTex, uvwB.xy) * uvwB.z;
            //o.Albedo = half3(IN.uv_MainTex,0); 
            fixed4 c = (texA + texB) * _Color;
            
            o.Albedo = c.rgb;
            //o.Albedo = pow(dhA.z + dhB.z, 2.2);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            o.Emission = ColorBelowWater(IN.screenPos, o.Normal) * (1 - c.a);
            
        }
        
        void surf_teddy_flow (Input IN, inout SurfaceOutputStandard o)
        {
            float2 flowVector = tex2D(_FlowMap, IN.uv_MainTex).rg;
            float2 uv = FlowUV(IN.uv_MainTex, _SinTime);
            fixed4 c = tex2D (_MainTex, uv) * _Color;
            o.Albedo = c.rgb;
            o.Albedo = float3(flowVector,0);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        
        void surf_teddy_move (Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = FlowUV(IN.uv_MainTex, _SinTime);
            fixed4 c = tex2D (_MainTex, uv) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        
        //teddy's version of main, not working now
        // void surf_teddy (Input IN, inout SurfaceOutputStandard o)
        // {
        //     float3 flowSample = tex2D(_FlowMap, IN.uv_MainTex).rga;
        //     float2 flowVector = flowSample.rg * 2 - 1;
        //     float noise = flowSample.b;
        //     float time = _Time.y + noise;
        //
        //     float3 uvw = FlowUVW(IN.uv_MainTex, flowVector, _Time.y);
        //     
        //     fixed4 c = tex2D (_MainTex, uvw.xy) * uvw.z * _Color;
        //     o.Albedo = c.rgb;
        //     // Metallic and smoothness come from slider variables
        //     o.Metallic = _Metallic;
        //     o.Smoothness = _Glossiness;
        //     o.Alpha = c.a;
        // }
        
        ///teddy: the original surf function kept for reference
        void surf_original (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        // } teddy end
        /// this is like the main function, to display on the surface
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            surf_water(IN, o);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
