shader_type canvas_item;

uniform bool paused = false;
uniform vec2 wave1Direction;
uniform float wave1Speed;
uniform vec2 wave2Direction;
uniform float wave2Speed;
uniform float waveIntensity : hint_range(0.0, 1.0, 0.001) = 0.1;
uniform float waveScale = 1;
uniform vec4 bgColor : source_color = vec4(0, 0, 1, 1);
uniform vec4 waveColor : source_color = vec4(1, 1, 1, 1);
uniform sampler2D waveNoise : filter_nearest, repeat_enable;
uniform float time = 0.0;

void fragment(){
	
	vec2 water1UV = (UV * waveScale) + (-wave1Direction * time * wave1Speed);
	vec2 water2UV = (UV * waveScale) + (-wave2Direction * time * wave2Speed);
	
	
	float noiseAlpha = texture(waveNoise, water1UV).r + texture(waveNoise, water2UV).r;
	float waveAlpha = (noiseAlpha > 2.0 - (waveIntensity * 2.0)) ? 1.0 : 0.0;
	COLOR.rgb = mix(bgColor, waveColor, waveAlpha).rgb;
	
}
