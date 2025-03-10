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

            float DEmandel(float3 pos, out float smoothIter) {
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

                smoothIter = float(i) + log(log(1.15)) / log(_power) - log(log(r)) / log(_power);
	            return 0.5*log(r)*r/dr;
            }

            fixed4 raymarch(float3 ro, float3 rd){
                float t = 0;
                float smoothIter = 0;
                int steps;

                for (steps = 0; steps < _maxSteps; steps++){
                    float3 p = ro + rd * t;
                    float d = DEmandel(p, smoothIter);
                    t += d;
                    if (d < _minDistance) break;
                }

                //Normalize for coloring
                float normalizedIter = smoothIter / float(_iterations);

                //Smooth gradient color blending
                float3 resultColor = lerp(_color1, _color2, normalizedIter);
                resultColor = lerp(resultColor, _color3, normalizedIter * normalizedIter);

                return fixed4(resultColor, 1.0);
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
