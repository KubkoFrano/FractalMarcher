Shader "Raymarcher"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            uniform float4x4 _CamFrustum, _CamToWorld;
            uniform int _maxSteps;
            uniform float _minDistance;
            uniform float4 _sphere1;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ray : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                half index = v.vertex.z;
                v.vertex.z = 0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.ray = _CamFrustum[(int)index].xyz;

                o.ray /= abs(o.ray.z);

                o.ray = mul(_CamToWorld, o.ray);

                return o;
            }

            float sdSphere(float3 p, float s){
                return length(p) - s;
            }

            float distanceEstimator(float3 p){
                float sphere1 = sdSphere(p - _sphere1.xyz, _sphere1.w);
                return sphere1;
            }

            fixed4 raymarch(float3 ro, float3 rd){
                float t = 0;
                int steps;
                for (steps = 0; steps < _maxSteps; steps++){
                    float3 p = ro + rd * t;
                    float d = distanceEstimator(p);
                    t += d;
                    if (d < _minDistance) break;
                }

                return 1.0 - float(steps) / float(_maxSteps);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 rayDirection = normalize(i.ray.xyz);
                float3 rayOrigin = _WorldSpaceCameraPos;
                fixed4 result = fixed4(raymarch(rayOrigin, rayDirection));

                return result;
            }
            ENDCG
        }
    }
}
