Shader "Custom/Astrophage"
{
    Properties
    {
        _AlphaPower ("Alpha Power", Range(0.1, 5)) = 1.0
        _AlphaMin ("Alpha Min Threshold", Range(0,1)) = 0.0
        _AlphaMax ("Alpha Max Threshold", Range(0,1)) = 1.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile _ UNITY_SINGLE_PASS_STEREO

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            float _AlphaPower;
            float _AlphaMin;
            float _AlphaMax;

            v2f vert (appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float2 uv = i.uv;

                #if defined(UNITY_SINGLE_PASS_STEREO)
                    uv = UnityStereoTransformScreenSpaceTex(uv);
                #endif

                float2 centered = uv * 2.0 - 1.0;

                centered.x *= _ScreenParams.x /2. / _ScreenParams.y;

                float d = length(centered);

                float r = acos(saturate(d));
                float3 col = float3(r, 0.0, 0.0);

                float luminance = dot(col, float3(0.299, 0.587, 0.114));

                float alpha = smoothstep(_AlphaMin, _AlphaMax, luminance);
                alpha = pow(alpha, _AlphaPower);

                return float4(col, alpha);
            }
            ENDCG
        }
    }
}