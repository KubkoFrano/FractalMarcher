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

            //Raymarch
            uniform int _maxSteps;

            //Lighting
            uniform float4 _lights[6];
            uniform float4 _colors[6];
            uniform float _colorMultiplier;

            //Epsilon
            uniform float _epsilonMin;
            uniform float _epsilonMax;

            //Julia
            uniform float4 _seed;
            uniform float _par;

            //Mandelbulb
            uniform int _iterations;
            uniform float _power;

            //Choose fractal
            uniform int _fractal;
            /*
                0 -> Mandelbulb
                1 -> Quaternion Julia Set
            */

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

            float DEMandel(float3 pos) {
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

            float DEJulia(float3 p)
            {
	            float4 C = _seed;
	            float4 Z = float4(p.z, p.y, _par, p.x);
    
	            float4 dz = 2.0*Z + float4(1.0, 1.0, 1.0, 1.0);

	            for (int i = 0; i < 64; i++)
	            {
		            dz = 2.0 * MultiplyQuaternions(Z, dz) + float4(1.0, 1.0, 1.0, 1.0);
		            Z = MultiplyQuaternions(Z, Z) + C;
        
		            if (dot(Z, Z) > 1000.0)
		            {
			            break;
			        }
		        }

	            float d = 0.5*sqrt(dot(Z, Z) / dot(dz, dz))*log(dot(Z, Z)) / log(10.0);
	
                return d;

            }

            float DEexp(float3 p){
    
                const float3 offs = float3(1, .75, .5); // Offset point.
                const float2 a = sin(float2(0, 1.57079632) + 1.57/2.);
                const float2x2 m = float2x2(a.y, -a.x, a);
                const float2 a2 = sin(float2(0, 1.57079632) + 1.57/4.0);
                const float2x2 m2 = float2x2(a2.y, -a2.x, a2);
    
                const float s = 5.; // Scale factor.
    
                const float sz = .0355; // Box size.
                #ifdef WIREFRAME
                const float ew = .015; // Wireframe box edge width.
                #endif
    
                float d = 1e5; // Distance.
    
    
                p  = abs(frac(p*.5)*2. - 1.); // Standard spacial repetition.
     
    
                float amp = 1./s; // Analogous to layer amplitude.
    
   
                // With only two iterations, you could unroll this for more speed,
                // but I'm leaving it this way for anyone who wants to try more
                // iterations.
                for(int i=0; i<2; i++){
        
                    // Rotating.
                    p.xy = mul(m, p.xy);
                    p.yz = mul(m2, p.yz);
        
                    p = abs(p);
                    //p = sqrt(p*p + .03);
                    //p = smin(p, -p, -.5); // Etc.
        
  		            // Folding about tetrahedral planes of symmetry... I think, or is it octahedral? 
                    // I should know this stuff, but topology was many years ago for me. In fact, 
                    // everything was years ago. :)
		            // Branchless equivalent to: if (p.x<p.y) p.xy = p.yx;
                    p.xy += step(p.x, p.y)*(p.yx - p.xy);
                    p.xz += step(p.x, p.z)*(p.zx - p.xz);
                    p.yz += step(p.y, p.z)*(p.zy - p.yz);
 
                    // Stretching about an offset.
		            p = p*s + offs*(1. - s);
        
		            // Branchless equivalent to:
                    // if( p.z < offs.z*(1. - s)*.5)  p.z -= offs.z*(1. - s);
                    p.z -= step(p.z, offs.z*(1. - s)*.5)*offs.z*(1. - s);
        
                    // Loosely speaking, construct an object, and combine it with
                    // the object from the previous iteration. The object and
                    // comparison are a cube and minimum, but all kinds of 
                    // combinations are possible.
                    p = abs(p);
                    float3 q = p*amp;
                    //d = min(d, max(max(p.x, p.y), p.z)*amp - .035);
        
                    // The object you draw is up to you. There are countless options.

                    //float3 qq = abs(q);
                    //float2 h = float2(.2,.1);
                    //float box =  max(qq.z-h.y,max(qq.x*0.866025+q.y*0.5,-q.y)-h.x*0.5);
                    //float box = max(max(q.x, q.y), q.z) - sz;
                    //box = min(box, max(max(q.y, q.z) - sz*.33, q.x - sz*1.1));
                    //float box = max(length(q.yz) - sz*1.2, q.x - sz);
                    float box = length(q) - sz; // A very spherical box. :)
                    #ifdef WIREFRAME
                    box = max(box, -(min(min(max(q.x, q.y), max(q.x, q.z)), max(q.y, q.z)) - sz + ew));
                    //box = max(box, -max(length(q.yz) - ew, q.x - sz - ew));
                    //box = max(box, -(max(length(q.yz - sz*.5) - ew*.35, q.x - sz - ew*.5)));
                    //box = max(box, -(max(q.y, q.z) - sz + ew));
                    #endif
                    // Vertices, of sorts.
                    //q = abs(q) - sz;
                    //box = min(box, length(q) - sz/3.);
                    d = min(d, box);
        
        
                    amp /= s; // Decrease the amplitude by the scaling factor.
        
                }
 
 	            return d; // Return the distance.
            }

            float epsilon(float d){
                return _epsilonMin;
                return clamp(d / 550.0, _epsilonMin, _epsilonMax);
            }

            float3 calculateColor(float3 p, float3 n, float3 c){
                float3 result = float3(0.0, 0.0, 0.0);

                for (int i = 0; i < 6; i++){
                    float3 dir = normalize(p - _lights[i]);
                    float diff = max(0.0, dot(n, -dir));
                    result += _colors[i] * diff;
                }

                return result * c * _colorMultiplier;
            }

            float DE(float3 p){
                if (_fractal == 0)
                    return DEMandel(p);
                else if (_fractal == 1)
                    return DEJulia(p);
                else
                    return 0.0;
            }

            fixed4 raymarch(float3 ro, float3 rd){
                float t = 0;
                int steps;

                for (steps = 0; steps < _maxSteps; steps++){
                    float3 p = ro + rd * t;
                    float d = DE(p);
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

                float gray = 1.0 - float(steps) / float(_maxSteps) * _colorMultiplier;

                // add lighting
                return fixed4(gray, gray, gray, 1.0);
                return fixed4(calculateColor(p, n, float3(gray, gray, gray)), 1.0);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 rayDirection = normalize(i.ray.xyz);
                float3 rayOrigin = _WorldSpaceCameraPos;
                fixed4 result = raymarch(rayOrigin, rayDirection, i.uv);

                return result;
            }
            ENDCG
        }
    }
}
