#version 140
#define PROCESSING_COLOR_SHADER

uniform float iGlobalTime;
uniform vec3 iResolution;
uniform vec4 iMouse;
out vec4 fragColor;
uniform float pan;
uniform float light;
uniform float swivel;
uniform float wideSpeed;

//-------------------------------

// Using IÃ±igo QuÃ­lez's distance functions from: http://iquilezles.org/www/articles/distfunctions/distfunctions.htm

float sdBox( vec3 p, vec3 b ) {
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdCross(in vec3 p)
{
  float da = sdBox(p.xyz,vec3(4.0,0.0,1.0));
  float db = sdBox(p.yzx,vec3(1.0,2.0,2.0));
  float dc = sdBox(p.zxy,vec3(0.5,1.0,sin(iGlobalTime*4.4)+2.5));
  return min(da,min(db,dc));
}

float opRep(vec3 p, vec3 c) {
    vec3 q = mod(p,c)-0.5*c;
    return sdCross(q);
}

float trace(vec3 o, vec3 r) {
    float t = 0.0;
    for (int i = 0; i < 32; i++) {
    	vec3 p = o + r * t;
        float d = opRep(p, vec3(6.0, 6.0, 6.0));
        t += d * 1.0;
    }
    return t;
}

mat2 rotation(float theta) {
    return mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
}

void main() {
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    vec3 r = normalize(vec3(uv, wideSpeed));
    r.xz *= rotation(sin(iGlobalTime) * pan);
    r.xy *= rotation(cos(iGlobalTime) * swivel);
    vec3 o = vec3(0.0, iGlobalTime, iGlobalTime * 10.0);
    float t = trace(o, r);
    float fog = 1.0 / (1.0 + t * t * light);
    vec3 fc = vec3(1.0-fog);
	gl_FragColor = vec4(fc ,1.0);
}
