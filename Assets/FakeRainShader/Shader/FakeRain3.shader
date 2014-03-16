Shader "FakeRain/FakeRain3"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Diffuse Texture (RGB), Alpha Channel (A)", 2D) = "white" {}
		// read Spec from the alpha channel, importing the specular texture
		_NormalTex ("Normal Texture (RGB), Specular Texture (A)", 2D) = "white" {}

		_LightPower ("Power of nearby lights", Float) = 1
		
		// define the glossiness of the specular texture
		_SpecularPower ("Specular Power", range(0,10)) = 1
		// define the color of the specular
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
	}
	
	SubShader
	{
		
		Tags { "RenderType"="Opaque" }
		LOD 200
		

		CGPROGRAM
		#pragma surface RainSurface HalfLambert
		
		half4 _Color;
		sampler2D _MainTex;
		sampler2D _NormalTex;
		half _LightPower;
		
		// same transfrom
		half _SpecularPower;
		half4 _SpecularColor;

		struct Input
		{
			float2 uv_MainTex;
		};
		
		// to bring the surface color of the Specular into the lighting model, extends this with new output
		// dont forget to replace the old SurfaceOutput with the NewSurfaceOutput
		struct NewSurfaceOutput
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Specular;
			half Alpha;
			//new output SpecularColor
			half3 SpecularColor;
		};
		
		
		

		half halfDot(half3 a, half3 b)
		{
			return dot(normalize(a), normalize(b)) * 0.5f + 0.5f ;
		}
		
		// add repalced with NewSurfaceOutput
		half4 LightingHalfLambert(NewSurfaceOutput o, half3 lightDir, half3 viewDir, half atten)
		{
			half shadingValue = halfDot(o.Normal, lightDir);
			half3 diffuseLighting = shadingValue * o.Albedo * _LightColor0;
			
			// calculate the specluar value, with the sum of the light direction and view direction
			// using the pow(x,y) function get more controll over the specularMap with the specular power, -> x^y , 
			half specularValue = pow( halfDot(o.Normal, viewDir +lightDir), _SpecularPower );
			// the specular value multiply the light color and specularColor = specular lighting
			half3 specularLighing = specularValue * o.SpecularColor * _LightColor0;
			
			// adding the specular lighing to the deffuse lighing
			half3 returnColor = ( diffuseLighting + specularLighing ) *  atten * _LightPower ;
			
			return half4(returnColor, o.Alpha);
		}
		
		// add repalced with NewSurfaceOutput
		void RainSurface (Input IN, inout NewSurfaceOutput o)
		{
			half4 diffuseValue = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = diffuseValue.rgb * _Color;
			o.Alpha = diffuseValue.a;

			half3 normalValue = UnpackNormal( tex2D(_NormalTex, IN.uv_MainTex));
			o.Normal = normalValue.rgb;
			
			// add the new Texture to the new SurfaceOutput with the color
			// reading the information from the 4. channel of the normal texture and multiply with the color
			half specularValue = tex2D(_NormalTex, IN.uv_MainTex).a;
			o.SpecularColor = specularValue * _SpecularColor;
		}
		ENDCG
	} 
	
	FallBack "Diffuse"
}