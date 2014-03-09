Shader "FakeRain/FakeRain6"
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
		
		_rainSpeedX ("Rain Speed: horizontal", Float) = 0.1
		_rainSpeedY ("Rain Speed: vertical", Float) = 0.1
		_distortionPower ("distortion Power", Float) = 1
		
		// input a CubeMap with cube map power to modify
		_CubeMap ("Cube Map / Environment Map", CUBE) = "white" {}
		_CubeMapPower ("Cube Map Power", Range(0.5, 3)) = 1
		
	}
	
	SubShader
	{
		
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface RainSurface HalfLambert
		#pragma target 3.0
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
		
		half _rainSpeedX;
		half _rainSpeedY;
		half _distortionPower;
		
		// declaration
		samplerCUBE _CubeMap;
		half _CubeMapPower;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_RainTexture;
			float3 worldNormal;
			INTERNAL_DATA
			
			// need to work with the viewDir (looking direction of the camera)
			float3 viewDir;
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
			
			half2 rainSpeed = half2 (_rainSpeedX, _rainSpeedY);
			half2 distortion1 = rainSpeed * sin(_Time * 2);
			half2 distortion2 = rainSpeed * _Time;
			
			half2 RainDropsOffset = tex2D(_RainTexture, IN.uv_RainTexture + distortion1).x  ;
			half2 RainSideOffset = tex2D(_RainTexture, IN.uv_RainTexture + distortion2).y ;
			half2 mainOffset = lerp(RainDropsOffset, RainSideOffset, transitionValue) * _distortionPower ;

			half4 diffuseValue = tex2D (_MainTex, IN.uv_MainTex + mainOffset );
			o.Albedo = diffuseValue.rgb * _Color;
			o.Alpha = diffuseValue.a;

			half3  normalValue2 = UnpackNormal( tex2D(_NormalTex, IN.uv_MainTex + mainOffset ));
			o.Normal =  normalValue2;
			
			half4 specbase = tex2D(_MainTex, IN.uv_MainTex + mainOffset ).a;
			half4 specAdd1 = tex2D(_RainTexture, IN.uv_RainTexture + distortion2 ).r;
			half4 specAdd2 = tex2D(_RainTexture, IN.uv_RainTexture + distortion1 ).g;
			o.SpecularColor = (1- (1-specbase) * (1 - lerp(specAdd1, specAdd2, transitionValue))) * _SpecularColor;
			
			// reflect( I , N ) computes reflection vector from entering ray direction I  and surface normal N .
			// input viewDir needs inverted, important!! 
			half3 reflectedViewDir = reflect( -IN.viewDir, normalize(o.Normal));
			// reading the color infomation on the postion where the reflectedViewDir directs, 
			half3 cubeMap = pow(texCUBE (_CubeMap, reflectedViewDir), _CubeMapPower);
			// output Cubemap to the emission (self luminosity)
			o.Emission = cubeMap;
			 
			 
		}
		ENDCG
	} 
	
	FallBack "Diffuse"
}
