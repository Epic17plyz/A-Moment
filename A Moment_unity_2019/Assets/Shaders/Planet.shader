Shader "Custom/AutoLevels_Vivify_Stable"
{
    Properties
    {
        _MainTex ("Source", 2D) = "white" {}

        _Strength ("Effect Strength", Range(0,1)) = 1.0
        _Contrast ("Contrast Boost", Range(0.5, 1.5)) = 0.9
        _ClipBias ("Clip Bias", Range(0.0, 0.1)) = 0.02
    }

    SubShader
    {
        Tags { "Queue"="Overlay" }

        Pass
        {
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            float _Strength;
            float _Contrast;
            float _ClipBias;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // --- Sampling pattern ---
            static const float2 offsets[9] =
            {
                float2(0.0, 0.0),
                float2(0.25, 0.25),
                float2(-0.25, 0.25),
                float2(0.25, -0.25),
                float2(-0.25, -0.25),
                float2(0.5, 0.0),
                float2(-0.5, 0.0),
                float2(0.0, 0.5),
                float2(0.0, -0.5)
            };

            float luminance(float3 c)
            {
                return dot(c, float3(0.299, 0.587, 0.114));
            }

            float3 SampleMin(float2 uv)
            {
                float3 minC = float3(1,1,1);

                for (int i = 0; i < 9; i++)
                {
                    float2 suv = saturate(uv + offsets[i]); // FIXED
                    float3 c = tex2D(_MainTex, suv).rgb;
                    minC = min(minC, c);
                }

                return minC;
            }

            float3 SampleMax(float2 uv)
            {
                float3 maxC = float3(0,0,0);

                for (int i = 0; i < 9; i++)
                {
                    float2 suv = saturate(uv + offsets[i]); // FIXED
                    float3 c = tex2D(_MainTex, suv).rgb;
                    maxC = max(maxC, c);
                }

                return maxC;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                // VR-safe vertical flip
                #if UNITY_UV_STARTS_AT_TOP
                    if (_MainTex_TexelSize.y < 0)
                        uv.y = 1.0 - uv.y;
                #endif

                float3 col = tex2D(_MainTex, uv).rgb;

                // Estimate scene min/max
                float3 minC = SampleMin(uv);
                float3 maxC = SampleMax(uv);

                // Convert to luminance (FIXED color behavior)
                float minL = luminance(minC);
                float maxL = luminance(maxC);

                float range = max(maxL - minL, 1e-4);

                float l = luminance(col);
                float normalized = (l - minL) / range;

                // Apply normalization back to color
                float3 leveled = col * (normalized / max(l, 1e-4));

                // Clamp
                leveled = saturate(leveled);

                // Contrast shaping
                leveled = pow(leveled, _Contrast);

                // Clip bias (forces true black/white more often)
                leveled = smoothstep(_ClipBias, 1.0 - _ClipBias, leveled);

                // Blend
                float3 finalCol = lerp(col, leveled, _Strength);

                return float4(finalCol, 1.0);
            }

            ENDCG
        }
    }

    Fallback Off
}