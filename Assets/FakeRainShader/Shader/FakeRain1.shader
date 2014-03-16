
Shader "FakeRain/FakeRain1"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Diffuse Texture (RGB), Alpha Channel (A)", 2D) = "white" {}
		// the Normal Texture fake depth and height on the surface without changing the geometry
		// importing the Normal texture, the 4. channels is the specular texture, more later
		_NormalTex ("Normal Texture (RGB), Specular Texture (A)", 2D) = "white" {}
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface RainSurface Lambert
		
		half4 _Color;
		sampler2D _MainTex;
		// here also the transformation to CG
		sampler2D _NormalTex;

		struct Input
		{
			float2 uv_MainTex;
			// we don't use the normal UV
		};
		
		void RainSurface (Input IN, inout SurfaceOutput o)
		{
			half4 diffuseValue = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = diffuseValue.rgb * _Color;
			o.Alpha = diffuseValue.a;
			
			// tex2D(texName, texPosition) reads the color information from the texName on the position texPosition
			// UnpackNormal();calculate texture informations into vectors, to fake surface geometry
			half3 normalValue = UnpackNormal( tex2D(_NormalTex, IN.uv_MainTex));
			//Normaloutput, texture type must be set to normal
			o.Normal = normalValue.rgb;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
