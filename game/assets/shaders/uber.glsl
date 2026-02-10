uniform float hueShift;
uniform float vignette;
uniform float desaturate;
uniform float aberration;
uniform float wobble;
uniform float time;

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
	vec2 uv = tc;

	// 5. Screen wobble — sine-based position offset, animated
	uv.x += sin(uv.y * 15.0 + time * 3.0) * wobble * 0.015;
	uv.y += cos(uv.x * 15.0 + time * 2.5) * wobble * 0.015;

	// 4. Chromatic aberration — split RGB channels
	float abOff = aberration * 0.008;
	float r = Texel(tex, uv + vec2(abOff, 0.0)).r;
	float g = Texel(tex, uv).g;
	float b = Texel(tex, uv - vec2(abOff, 0.0)).b;
	float a = Texel(tex, uv).a;
	vec4 pixel = vec4(r, g, b, a);

	// 1. Hue shift — rotate pixel colors
	vec3 hsv = rgb2hsv(pixel.rgb);
	hsv.x = fract(hsv.x + hueShift);
	pixel.rgb = hsv2rgb(hsv);

	// 3. Saturation drain — pull toward grayscale
	float grey = dot(pixel.rgb, vec3(0.299, 0.587, 0.114));
	pixel.rgb = mix(pixel.rgb, vec3(grey), desaturate);

	// 2. Vignette darkening — darken screen edges
	vec2 center = uv - 0.5;
	float dist = length(center);
	float vig = smoothstep(0.2, 0.8, dist) * vignette;
	pixel.rgb *= 1.0 - vig;

	return pixel * color;
}
