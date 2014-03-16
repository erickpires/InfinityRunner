Shader "FakeRain/FakeRain4"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NormalTex ("Normal Map", 2D) = "white" {}

		_LightPower ("Power of nearby lights", Float) = 1
		_SpecularPower ("Specular Power", range(0,10)) = 1
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		
		// a Texture with three channels
			// 1.channel (R) falling rain drops texture for the top
			// 2.channel (G)pouring rain for the sides (walls etc.)
			// 3.channel (B) a perlin noise texture to blend between the rain drops and rain on the wall
		_RainTexture("RainDrops(R), RainSide(G), Noise(B)", 2D) = "white" {}
		// vector of the up direction
		_UpDirection("Up direction", Vector) = (0,1,0)
		// width of the gradient between top and side
		_transition("Transition", range(0, 1)) = 1
		// the height where the transition starts
		_RainDropsAmount("Rain drops amount" , range(0,1)) = 5
		// RainDropsPower
		_RainDropsPower("Rain Drops Power", range(1,10)) = 0.5
		
	}
	
	SubShader
	{
		
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface RainSurface HalfLambert
		// need pragma to compile to shader model 3.0 and use Direct3D 9 (now we can use way more instructions)
		#pragma target 3.0
		
		half4 _Color;
		sampler2D _MainTex;
		sampler2D _NormalTex;
		half _LightPower;
		
		half _SpecularPower;
		half4 _SpecularColor;
		
		// don't forget the declaraction of variables
		sampler2D _RainTexture;
		float3 _UpDirection;
		half _transition;
		half _RainDropsAmount;
		half _RainDropsPower;
		

		struct Input
		{
			float2 uv_MainTex;
			// we need a new UV
			float2 uv_RainTexture;
			//if you want to do reflections that are affected by normal maps,
			 // it needs to be slightly more involved: INTERNAL_DATA needs to be added to the Input structure, 
			 // and WorldReflectionVector function used to compute per-pixel reflection vector after you've written the Normal output.
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
			
			// Normalmap needs first to applie
			half3 normalValue = UnpackNormal( tex2D(_NormalTex, IN.uv_MainTex));
			o.Normal = normalValue;
			// IMPORTANT to first define the normalmap!
			// float3 worldNormal; INTERNAL_DATA - will contain world normal vector if surface shader writes to o.Normal. To get the normal vector based on per-pixel normal map, use WorldNormalVector (IN, o.Normal).
			half3 worldNormal = WorldNormalVector (IN, o.Normal);
			
			
			// import the noise, just using the first channel, using the noise the separate the drops and the side
			half4 noise = tex2D(_RainTexture, IN.uv_MainTex).b;
			// getting a value between 0 and 1 two difine which texture to blend in, with the dot product of the surface normal and the up direction
			half halfDot1 = halfDot(worldNormal, _UpDirection);
			// define the shiftLevel (transition) 
			half shiftLevel = pow(halfDot1, _RainDropsPower) * _RainDropsAmount;
			//max( a , b ) :	Maximum of a  and b . (its never goes under 0)
			// also clamps x  to the [0, 1] range.
			half transitionValue = saturate(max(noise - shiftLevel, 0) / _transition);
			
			half4 diffuseValue = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = diffuseValue.rgb * _Color;
			o.Alpha = diffuseValue.a;
			
			// a test lerp (linear interpolation) with two values
			// the first
			half2 TestLerp1 = tex2D(_RainTexture, IN.uv_RainTexture).x;
			// the second
			half2 TestLerp2 = tex2D(_RainTexture, IN.uv_RainTexture).y;
			// the lerp, the transition value define which value(TestLerp1 or 2) will be seen
			// if transitionValue is 1 it`s TestLerp1
			// if transitionValue is 2 it`s TestLerp2
			// else a blend between
			half SpecularLerp = lerp(TestLerp1, TestLerp2, transitionValue) ;

			// rewritting the normal with the Offset
			half3  normalValue2 = UnpackNormal( tex2D(_NormalTex, IN.uv_MainTex));
			o.Normal =  normalValue2;

			half specularValue = tex2D(_NormalTex, IN.uv_MainTex).a;
			
			// add SpecularLerp to the Specular output
			o.SpecularColor = specularValue * SpecularLerp * _SpecularColor;
		}
		ENDCG
	} 
	
	FallBack "Diffuse"
}
