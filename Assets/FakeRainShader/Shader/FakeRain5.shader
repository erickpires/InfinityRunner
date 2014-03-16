Shader "FakeRain/FakeRain5"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NormalTex ("Normal Map", 2D) = "white" {}

		_LightPower ("Power of nearby lights", Float) = 1
		_SpecularPower ("Base Sepecular Power", range(1,10)) = 1
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		
		_RainTexture("RainDrops(R), RainSide(G), Noise(B)", 2D) = "white" {}
		_UpDirection("Up direction", Vector) = (0,1,0)
		_transition("Transition", range(0, 1)) = 1
		_RainDropsAmount("Rain drops amount" , range(0,1)) = 5
		_RainDropsPower("Rain Drops Power", range(1,10)) = 0.5
		
		// some variables for the fake Distortion of the rain
		_rainSpeedX ("Rain Speed: horizontal", Float) = 0.1
		_rainSpeedY ("Rain Speed: vertical", Float) = 0.1
		_distortionPower ("distortion Power", Float) = 1
		
	}
	
	SubShader
	{
		
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface RainSurface HalfLambert
		#pragma target 3.0
		// for the working and calculating with UVs
		// using #pragma glsl to translate into GLSL, it has fewer restrictions
		#pragma glsl
		
		half4 _Color;
		sampler2D _MainTex;
		sampler2D _NormalTex;
		half _LightPower;
		
		half _SpecularPower;
		half4 _SpecularColor;
		
		sampler2D _RainTexture;
		float3 _UpDirection;
		half _transition;
		half _RainDropsAmount;
		half _RainDropsPower;
		
		// the new declaration
		half _rainSpeedX;
		half _rainSpeedY;
		half _distortionPower;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_RainTexture;
			float3 worldNormal;
			INTERNAL_DATA
		};
		
		struct NewSurfaceOutput
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Specular;
			half Alpha;
			half3 SpecularColor;
		};
		

		half halfDot(half3 a, half3 b)
		{
			return dot(normalize(a), normalize(b)) * 0.5f + 0.5f ;
		}
		

		half4 LightingHalfLambert(NewSurfaceOutput o, half3 lightDir, half3 viewDir, half atten)
		{
			half shadingValue = halfDot(o.Normal, lightDir);
			half3 diffuseLighting = shadingValue * o.Albedo * _LightColor0;
			
			half specularValue = pow( halfDot(o.Normal, lightDir + viewDir),_SpecularPower);
			half3 specularLighing = specularValue * o.SpecularColor * _LightColor0;
			half3 returnColor = ( diffuseLighting + specularLighing ) *  atten * _LightPower ;
			return half4(returnColor, o.Alpha);
		}
		

		void RainSurface (Input IN, inout NewSurfaceOutput o)
		{
		
			half3 normalValue = UnpackNormal( tex2D(_NormalTex, IN.uv_MainTex));
			o.Normal = normalValue;
			half3 worldNormal = WorldNormalVector (IN, o.Normal);
			
			half4 noise = tex2D(_RainTexture, IN.uv_MainTex).b;
			half halfDot1 = halfDot(worldNormal, _UpDirection);
			half shiftLevel = pow(halfDot1, _RainDropsPower) * _RainDropsAmount;
			half transitionValue = saturate(max(noise - shiftLevel, 0) / _transition);
			
			// half2(x,y), vector with 2 value to address the UV coordinates
			half2 rainSpeed = half2 (_rainSpeedX, _rainSpeedY);
			// calculate the "distortion" for the UV with input Speed
			half2 distortion1 = rainSpeed * sin(_Time * 2);
			half2 distortion2 = rainSpeed * _Time;
			
			// read the new UV with the distortion
			half2 RainDropsOffset = tex2D(_RainTexture, IN.uv_RainTexture + distortion1).x  ;
			half2 RainSideOffset = tex2D(_RainTexture, IN.uv_RainTexture + distortion2).y ;
			// multiply distortion power to the UV infomation and lerp between
			half2 mainOffset = lerp(RainDropsOffset, RainSideOffset, transitionValue) * _distortionPower ;

			// add the distortion to old diffuse texture uv
			half4 diffuseValue = tex2D (_MainTex, IN.uv_MainTex + mainOffset );
			o.Albedo = diffuseValue.rgb * _Color;
			o.Alpha = diffuseValue.a;

			// add the distortion to old normal texture uv
			half3  normalValue2 = UnpackNormal( tex2D(_NormalTex, IN.uv_MainTex + mainOffset ));
			o.Normal =  normalValue2;
			
			// add the distortion to old specular texture uv
			half4 specbase = tex2D(_MainTex, IN.uv_MainTex + mainOffset ).a;
			/// using the uv of the RainTexture with the distortion, so it can also move with the distortion
			half4 specAdd1 = tex2D(_RainTexture, IN.uv_RainTexture + distortion2 ).r;
			half4 specAdd2 = tex2D(_RainTexture, IN.uv_RainTexture + distortion1 ).g;

			// adding "glossyness"
			//  Math: 1−(1−A)×(1−B) (A inverted multiplied by B inverted, and the product is inverted)
			 o.SpecularColor = (1- (1-specbase) * (1 - lerp(specAdd1, specAdd2, transitionValue))) *_SpecularColor;
		}
		ENDCG
	} 
	
	FallBack "Diffuse"
}
