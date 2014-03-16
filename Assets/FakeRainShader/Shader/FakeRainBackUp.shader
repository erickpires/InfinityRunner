Shader "FakeRain/FakeRainBackUp"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB), Alpha Specular", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "white" {}

		_LightPower ("Power of nearby lights", Float) = 1
		
		_BaseSpecularPower ("Base Sepecular Power", range(1,10)) = 1
		
		_RainTexture("RainDrops(R), RainSide(G), Noise(B)", 2D) = "white" {}

		
		// need Values for the fake Distortion
	//	_rainSpeedX ("horizontal speed of the rain", Float) = 0.1
	//	_rainSpeedY ("vertical speed of the rain", Float) = 0.1
	//	_rainSpecularPower ("specular Power of the rain", Float) = 1
		_distortionPower ("distortion Power", Float) = 1
			

	}
	
	SubShader
	{
		
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf SpecMap
		#pragma target 3.0
		#pragma glsl
		
		half4 _Color;
		sampler2D _MainTex;
		sampler2D _NormalMap;
		half _LightPower;
		
		half _BaseSpecularPower;
		
		sampler2D _RainTexture;

		
		// definition
	//	half _rainSpeedX;
	//	half _rainSpeedY;
	//	half _rainSpecularPower;
		half _distortionPower;
	

		struct Input
		{
			float2 uv_MainTex;
			//add UV infomations
			float2 uv_RainTexture;

			float3 worldNormal;
			INTERNAL_DATA
			
			// cube Map viewDir
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
		

		half halfDiffuseTerm(half3 a, half3 b)
		{
			return dot(normalize(a), normalize(b)) * 0.5f + 0.5f ;
		}
		

		half4 LightingSpecMap(NewSurfaceOutput o, half3 lightDir, half3 viewDir, half atten)
		{
			half d = halfDiffuseTerm(o.Normal, lightDir);
			half3 diffuseLighting = d * o.Albedo * _LightColor0;
			half s = pow( halfDiffuseTerm(o.Normal, lightDir + viewDir) , _BaseSpecularPower);
			half3 specularLighing = s * o.SpecularColor * _LightColor0;
			half3 returnColor = ( diffuseLighting + specularLighing ) *  atten * _LightPower ;
		
			return half4(returnColor, o.Alpha);
		}
		

		void surf (Input IN, inout NewSurfaceOutput o)
		{

			// Normalmap needs first to applie
			half3 n = UnpackNormal( tex2D(_NormalMap, IN.uv_MainTex));

			o.Normal = n;
			half3 worldNormal = WorldNormalVector (IN, o.Normal);
			
			// ################################# FAKE Dis ################################################
			//   half2 distortionDrops =  lerp(noise2,0.95, RainDrops *(-1)+1) * (sin(_Time*8));
         	//   half2 distortionDrops =  rainSpeed * step(0.95, RainDrops *(-1)+1) * (sin(_Time*8)) *noise2;
         	//  half2 distortionDrops =  lerp(0f, noise2 ,0.5* RainDrops*(-1)+1) * sin(_Time) ;
         			//drops
			//half2 RainDrops = tex2D(_MainTex, IN.uv_MainTex ).a;
			//half2 noise2 = tex2D(_RainTexture, IN.uv_MainTex ).b;
			//half2 RainDrops2 = step(0.75, RainDrops *(-1)+1)* (sin(_Time*4)*0.5 +0.5);
			//half2 RainDrops3 = clamp(RainDrops2);
			//half2 distortionDrops = step(0.75, RainDrops *(-1)+1) * 0.25 * (sin(_Time)*0.5 +0.5) ;
			//side
         
         
			//spec
			half2 RainTop = tex2D(_MainTex, IN.uv_MainTex ).a;
			half2 RainDropsOffset = step(0.75, RainTop*(-1)+1) * sin(_Time*8)*0.5 +0.5;
			half2 RainDropsOffset2 = tex2D(_RainTexture, IN.uv_RainTexture + RainDropsOffset).x ;
			half2 mainOffset = RainDropsOffset2 * _distortionPower;
		

			// ################################# SPECULAR MAP ################################################
			//o.SpecularColor = specbase;
			
		   // half4 nt = tex2D (_NoiseTexture,  ((IN.uv_NoiseTexture + noiseOffset).xy * _noisePower));
		    //half4 s = tex2D(_BaseSpecularTexture, IN.uv_MainTex +  mainTextureOffset);

			
			//half4 nt = tex2D (_NoiseTexture,  ((IN.uv_NoiseTexture + noiseOffset).xy * _noisePower));

			//half4 s = tex2D(_BaseSpecularTexture, IN.uv_MainTex +  mainTextureOffset);
			
			//half4 s2 = 1-( (1-s)*(1-nt) * _NoiseSpecluarPower) ;
			//o.SpecularColor = lerp(rainDrops.rgb, rainSide.rgb, transitionValue);
			//o.SpecularColor = s.rgb;



			o.SpecularColor = tex2D(_MainTex, IN.uv_MainTex + mainOffset).a * _BaseSpecularPower;
			
			// ################################# NORMAL MAP ################################################
			
			half3 n2 = UnpackNormal( tex2D(_NormalMap, IN.uv_MainTex + mainOffset ));
			o.Normal = n2;

			half4 c = tex2D (_MainTex, IN.uv_MainTex + mainOffset );
			o.Albedo = c.rgb * _Color;
			o.Alpha = c.a;
			

			// ################################# CUBE & EMISSIV MAP ################################################
			// rim
			//half rimDot = tex2D (_MainTex, IN.uv_MainTex);
			//half rimLine = step (_Rim, rimDot);
					//	half3 addEmission = _RimColor.rgb * pow (rim, _RimPower) * lerp(specAdd1, specAdd2, transitionValue);
		   // o.Emission = pow(texCUBE (_CubeMap, reflectedViewDir), _CubeMapPower) ;
		  	//o.Emission = 1 - (1- ) * (1 - (rimLine * lerp(specAdd1, specAdd2, transitionValue)) );
			// o.Emission = texCUBE (_CubeMap, reflectedViewDir) + (halfDiffuseTerm( reflectedViewDir, o.Normal) * lerp(specAdd1, specAdd2, transitionValue));
				
			//o.Emission = _RimColor.rgb * pow (rim, _RimPower);
			//o.Emission = addEmission;
			

		}
		ENDCG
	} 
	
	FallBack "Diffuse"
}
