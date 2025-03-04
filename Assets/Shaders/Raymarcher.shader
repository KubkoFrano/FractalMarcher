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

            uniform int _iterations;
            uniform float _scale;

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
                return abs(length(p) - s);
            }

            float distanceEstimator(float3 p){
                p.xy = p.xy % 1.0 - float3(0.5, 0.5, 0.5); // instance on xy-plane
                return length(p)-0.3;             // sphere DE
            }

            float DE(float3 z)
            {
	            float3 a1 = float3(1,1,1);
	            float3 a2 = float3(-1,-1,1);
	            float3 a3 = float3(1,-1,-1);
	            float3 a4 = float3(-1,1,-1);
	            float3 c;
	            int n = 0;
	            float dist, d;
	            while (n < _iterations) {
		             c = a1; dist = length(z-a1);
	                 d = length(z-a2); if (d < dist) { c = a2; dist=d; }
		             d = length(z-a3); if (d < dist) { c = a3; dist=d; }
		             d = length(z-a4); if (d < dist) { c = a4; dist=d; }
		            z = _scale*z-c*(_scale-1.0);
		            n++;
	            }

	            return length(z) * pow(_scale, float(-n));
            }

            fixed4 raymarch(float3 ro, float3 rd){
                float t = 0;
                int steps;
                for (steps = 0; steps < _maxSteps; steps++){
                    float3 p = ro + rd * t;
                    float d = DE(p);
                    t += d;
                    if (d < _minDistance) break;
                }

                return 1.0 - float(steps) / float(_maxSteps);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 rayDirection = normalize(i.ray.xyz);
                float3 rayOrigin = _WorldSpaceCameraPos;
                fixed4 result = raymarch(rayOrigin, rayDirection);

                return result;
            }
            ENDCG
        }
    }
}
