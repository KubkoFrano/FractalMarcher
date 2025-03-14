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
            uniform float _power;

            uniform float3 _color1, _color2, _color3;

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

            float DE(float3 pos) {
	            float3 z = pos;
	            float dr = 1.0;
	            float r = 0.0;
                int i = 0;
	            for (; i < _iterations ; i++) {
		            r = length(z);
		            if (r > 1.15) break;
		
		            // convert to polar coordinates
		            float theta = acos(z.z / r);
		            float phi = atan2(z.y, z.x);
		            dr =  pow(r, _power - 1.0) * _power*dr + 1.0;
		
		            // scale and rotate the point
		            float zr = pow(r, _power);
		            theta = theta  *_power;
		            phi = phi * _power;
		
		            // convert back to cartesian coordinates
		            z = zr * float3(sin(theta) * cos(phi), sin(phi) * sin(theta), cos(theta));
		            z+=pos;
	            }

	            return 0.5*log(r)*r/dr;
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

                float3 p = ro + rd * t;

                float eps = _minDistance;
                float3 n =  normalize(float3(
                    DE(p + float3(eps, 0, 0)) - DE(p - float3(eps, 0, 0)),
                    DE(p + float3(0, eps, 0)) - DE(p - float3(0, eps, 0)),
                    DE(p + float3(0, 0, eps)) - DE(p - float3(0, 0, eps))
                ));

                return fixed4(n, 1.0);
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
