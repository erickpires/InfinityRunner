Shader "FakeRain/FakeRain7"
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
		
		_CubeMap ("Cube Map / Environment Map", CUBE) = "white" {}
		_CubeMapPower ("Cube Map Power", Range(0.5, 3)) = 1
		
		// a thin inline on the object
		_RimPower ("Rim Outline Power", range(0,2)) = 1
		_RimColor ("Color of Rim outline", Color) = (1,1,1,1)
		
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
		
		samplerCUBE _CubeMap;
		half _CubeMapPower;
		
		//
		half _RimPower;
		//
		half4 _RimColor;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_RainTexture;
			float3 worldNormal;
			INTERNAL_DATA
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
			o.SpecularColor = (1- (1-specbase) * (1 - lerp(specAdd1, specAdd2, transitionValue))) *_SpecularColor;
			
			
			half3 reflectedViewDir = reflect( -IN.viewDir, o.Normal);
			half3 cubeMap = pow(texCUBE (_CubeMap, reflectedViewDir), _CubeMapPower);
			// rim light calculate thought the inverted specular without a light
			// saturate( x ): Clamps x  to the [0, 1] range.
			half rim = 1.0 - saturate( halfDot(normalize(IN.viewDir), o.Normal) );
			// the rim light multiplies with the specular texture of the lerp of the two rain texture
			// in this way the rim looks like the water reflection on edges
			half3 addEmission = _RimColor.rgb * pow (rim, _RimPower) * lerp(specAdd1, specAdd2, transitionValue);
			// adding the Rim the the cubemap to the emission output
			o.Emission = 1 - (1-  cubeMap ) * (1 - addEmission);
		}
		ENDCG
	} 
	
	FallBack "Diffuse"
}
