#pragma header

uniform float hue;
uniform float opacity; // 0.0 = aucun effet, 1.0 = teinte pleine

float random2d(vec2 n){
    return fract(sin(dot(n,vec2(12.9898,4.1414)))*43758.5453);
}

void main()
{
    vec4 outCol = flixel_texture2D(bitmap, openfl_TextureCoordv);

    float Cmax = max(outCol.x, max(outCol.y, outCol.z));
    float Cmin = min(outCol.x, min(outCol.y, outCol.z));
    float delta = Cmax - Cmin;

    float S = 0.;
    float V = Cmax;

    if(Cmax != 0.)
        S = delta / Cmax;

    float H = hue / 2. * 360.;

    float C = V * S;
    float X = C * (1. - abs(mod(H / 60., 2.) - 1.));
    float m = V - C;

    vec3 rgbP = vec3(0.);

    if(0. <= H && H < 60.)         rgbP = vec3(C, X, 0.);
    else if(60. <= H && H < 120.)  rgbP = vec3(X, C, 0.);
    else if(120. <= H && H < 180.) rgbP = vec3(0., C, X);
    else if(180. <= H && H < 240.) rgbP = vec3(0., X, C);
    else if(240. <= H && H < 300.) rgbP = vec3(X, 0., C);
    else                            rgbP = vec3(C, 0., X);

    vec3 tinted = vec3(rgbP.x + m, rgbP.y + m, rgbP.z + m);
    gl_FragColor = vec4(mix(outCol.rgb, tinted, opacity), outCol.a);
}