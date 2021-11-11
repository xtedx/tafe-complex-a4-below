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
        
        //teddy: water flow map
        [NoScaleOffset] _FlowMap ("Flow (RG)", 2D) = "black" {}
        [NoScaleOffset] _FlowMapA ("Flow (RG), Alpha (A)", 2D) = "black" {}


    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        ///teddy: this where we declare variables to use in surf function
        ///usually to use the properties exposed in inspectore, declared above in Properties{} 
        sampler2D _MainTex, _FlowMap, _FlowMapA;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float2 FlowUV(float2 uv, float time)
        {
            return uv + time;
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

        /// this is like the main function, to display on the surface
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            surf_teddy_flow(IN, o);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
