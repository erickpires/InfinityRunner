Shader "FakeRain/FakeRain2"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Diffuse Texture (RGB), Alpha Channel (A)", 2D) = "white" {}
		_NormalTex ("Normal Texture (RGB), Specular Texture (A)", 2D) = "white" {}
		// add multiply for light power
		_LightPower ("Power of light sources", Float) = 1
	}
	
	SubShader
	{
		
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		
		CGPROGRAM
		// changed keyword "Lambert" to my new lighting function "HalfLambert"
		#pragma surface RainSurface HalfLambert
		
		half4 _Color;
		sampler2D _MainTex;
		sampler2D _NormalTex;
		
		// same transform for floats
		half _LightPower;
		
		struct Input
		{
			float2 uv_MainTex;
		};
		

		
		// helping function, takes two vectors and calculates the dot product
		half halfDot(half3 a, half3 b)
		{
			// calmping from (-1 to 1) to (0 to 1), much smoother shading to 
			// dot(vector1,vector2); tells you how two vectors directed to each other, dot self gives range -1 to 1
			// normalize(): reduce the vector length (magnitude) to 1
			// we could only use between 0 and 1, so cut in half and add a half, so it get everytimes possitv or 0
			return dot(normalize(a), normalize(b)) * 0.5f + 0.5f ;
		}
		
		// own lighting function
		// needs to start with keyword Lighing, returns the color of texel as displayed on the sceen, runs for ever texel and ever lightsource (!!!), needs zo assigned in CGProgramm
		// SurfaceOutput: informations of the texel, provided by our surf function
		// lightDir: the direction of the current light source (vector)
		// viewDir: the looking direction of the camera (vector)
		// atten: attenuation of the lightsource (distance and intensity), falloff
		// LightColor0: color value of the current lightsoucre
		
		half4 LightingHalfLambert(SurfaceOutput o, half3 lightDir, half3 viewDir, half atten)
		{
			// using helping function diffuseTerm to calculate the shading value with the NormalVector and the light direction
			half shadingValue = halfDot(o.Normal, lightDir);
			// using this shading value to multiply with the albedo(color information) and the color of the light scoure to get the diffuse lighting
			half3 diffuseLighting = shadingValue * o.Albedo * _LightColor0;
			
			half3 returnColor = diffuseLighting *  atten * _LightPower;
			
			// return the vector with the modified color(lighting) and the original alpha
			return half4(returnColor, o.Alpha);
		}
		
		void RainSurface (Input IN, inout SurfaceOutput o)
		{
			half4 diffuseValue = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = diffuseValue.rgb * _Color;
			o.Alpha = diffuseValue.a;
			
			half3 normalValue = UnpackNormal( tex2D(_NormalTex, IN.uv_MainTex));
			o.Normal = normalValue;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
