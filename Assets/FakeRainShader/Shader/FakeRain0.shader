
// Fake rain surface shader by Semjon Leinweber, 2013-04-04
// please follow this licenses of creative commons http://creativecommons.org/licenses/by-nc/3.0/
// be free to share and improve this shader how do you like

// Unity uses the RenderMan language for the surface shader, programming in CG (Nvidia) 
// a surface shader describe the surface character of a object

// Shader "directory/name/subname" can be used to sort your shaders
Shader "FakeRain/FakeRain0"
{
	// Properties: public input of values and textures by the editor user
	Properties
	{
		// variables needs to start with a underscore so CG can they identify as given
		// name ("display name", type) = default_value {}
		_Color ("Color", Color) = (1,1,1,1)
		// this texture has 4 channels, RGB (1.,2. & 3) for the pure color infomation, A (4.) for the transparency (alpha) 
		// a texture is a array of texels (boxes with infomation in it), textures using UV mapping to coordinate the information
		_MainTex ("Diffuse Texture (RGB), Alpha Channel (A)", 2D) = "white" {}

	}
	
	// here starts the fun
	SubShader
	{	
		// Tags can be used to define how they need to be rendered in the rendering engine
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		//CGPROGRAM: define the lightingmodel
		CGPROGRAM
		// surf is the surface function to define the surface
		// Lambert is the using lighting method
		// surf replaced by RainSurface
		#pragma surface RainSurface Lambert
		
		
		// transfrom Properties into SubShader variables, they need the same name to identify for CG
		// or the declaration of variables
		// type _variableName;
		// half4: float with four vetors
		// sampler2D: define a texture 
		half4 _Color;
		sampler2D _MainTex;

		// using for data transfer (messenger), value types, no reference
		struct Input
		{
			float2 uv_MainTex;
		};


		// function surf() [by default] describes indepentend from the lighting the surface
		// renamed function surf() to RainSurface()
		void RainSurface (Input IN, inout SurfaceOutput o)
		{
			// the Albedo discribes the diffuse reflectivity
			// c renamed diffuseValue
			half4 diffuseValue = tex2D (_MainTex, IN.uv_MainTex);
			// texture color information multiplied by input color and writing in the Albedo
			o.Albedo = diffuseValue.rgb * _Color;
			o.Alpha = diffuseValue.a;

		}
		ENDCG
	} 
	// the literally fallback shader, if the shader above don't work on old hardware for example
	FallBack "Diffuse"
}
