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

            uniform float _epsilonMin;
            uniform float _epsilonMax;

            uniform int _iterations;
            uniform float _power;

            uniform float4 _lights[6];
            uniform float4 _colors[6];

            uniform float4 _seed;
            uniform float _par;

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

            float4 MultiplyQuaternions(float4 a, float4 b)
            {
	            float real = a.w*b.w - dot(a.xyz, b.xyz);  
                float3 complex = (a.w*b.xyz + b.w*a.xyz + cross(a.xyz, b.xyz));
	            return float4(complex, real);
            }

            float DEJulia(float3 p, float4 seed)
            {
                // Set C to be a vector of constants determining julia set we use
	            float4 C = seed;
    
                // Set Z to be some form of input from the vector
	            float4 Z = float4(p.z, p.y, _par, p.x);
    
                // I'll be honest, I'm not entirely sure how the distance estimation works.
                // Calculate the derivative of Z. The Julia set we are using is Z^2 + C,
                // So this results in simply 2z
	            float4 dz = 2.0*Z + float4(1.0, 1.0, 1.0, 1.0);

                // Run the iterative loop for some number of iterations
	            for (int i = 0; i < 64; i++)
	            {
                    // Recalculate the derivative
		            dz = 2.0 * MultiplyQuaternions(Z, dz) + float4(1.0, 1.0, 1.0, 1.0);
        
                    // Rcacalculate Z
		            Z = MultiplyQuaternions(Z, Z) + C;
        
       	            // We rely on the magnitude of z being fairly large (the derivation includes
                    // A limit as it approaches infinity) so we're going to let it run for a bit longer
                    // after we know its going to explode. i.e. 1000 instead of the usual, like 8.
		            if (dot(Z, Z) > 1000.0)
		            {
			            break;
			            }
		            }
    
                // And this is where the witchcraft happens. Again, not sure how this works, but as
   	            // you can see, it does.
	            float d = 0.5*sqrt(dot(Z, Z) / dot(dz, dz))*log(dot(Z, Z)) / log(10.0);
	
                // Return the distance estimation.
                return d;

            }

            float epsilon(float d){
                return clamp(d / 550.0, _epsilonMin, _epsilonMax);
            }

            float3 calculateColor(float3 p, float3 n, float3 c){
                float3 result = float3(0.0, 0.0, 0.0);

                for (int i = 0; i < 6; i++){
                    float3 dir = normalize(p - _lights[i]);
                    float diff = max(0.0, dot(n, -dir));
                    result += _colors[i] * diff;
                }

                return result * c * 2;
            }

            fixed4 raymarch(float3 ro, float3 rd){
                float t = 0;
                int steps;

                for (steps = 0; steps < _maxSteps; steps++){
                    float3 p = ro + rd * t;
                    float d = DEJulia(p, _seed);
                    t += d;
                    if (d < epsilon(t)) break;
                }

                // calculate normal
                float3 p = ro + rd * t;

                float eps = epsilon(t);
                float3 n =  normalize(float3(
                    DE(p + float3(eps, 0, 0)) - DE(p - float3(eps, 0, 0)),
                    DE(p + float3(0, eps, 0)) - DE(p - float3(0, eps, 0)),
                    DE(p + float3(0, 0, eps)) - DE(p - float3(0, 0, eps))
                ));

                float gray = float(steps) / float(_maxSteps);

                // add lighting
                return fixed4(calculateColor(p, n, float3(gray, gray, gray)), 1.0);
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
