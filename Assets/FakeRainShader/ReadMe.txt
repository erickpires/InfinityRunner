// Fake rain surface shader by Semjon Leinweber, 2013-04-04
// please follow this licenses of creative commons http://creativecommons.org/licenses/by-nc/3.0/
// be free to share and improve this shader how do you like
// Video tutorial: http://www.youtube.com/watch?v=zKX9IqN4Bdg

// the actually and finally shader is "FakeRainFinal.shader"
// the pre versions are step-by-step shaders to show the working process

// FakeRain0: basicly the default unity shader
// FakeRain1: adding a Normal Map
// FakeRain2: writing a simple ligthing (half lambert)
// FakeRain3: extending the ligthing with the specular
// FakeRain4: create a layer mask to separate the "rain distortions"
// FakeRain5: adding the rain distortions
// FakeRain6: adding reflection of a cube map
// FakeRain7: adding a rim light
// FakeRainFinal: final (with some test rotation)

// usefull links with topic Unity Shader
///////////////////////////////////////////////////
http://unity3d.com/learn/tutorials/modules
http://docs.unity3d.com/Documentation/Manual/Shaders.html
http://docs.unity3d.com/Documentation/Components/SL-Reference.html
http://docs.unity3d.com/Documentation/Components/SL-SurfaceShaderExamples.html
http://docs.unity3d.com/Documentation/Components/SL-SurfaceShaderLightingExamples.html
http://docs.unity3d.com/Documentation/Components/SL-ShaderPrograms.html
http://forum.unity3d.com/threads/150482-Rotation-of-Texture-UVs-directly-from-a-shader
http://forum.unity3d.com/threads/19018-rotate-texture
http://http.developer.nvidia.com/CgTutorial/cg_tutorial_appendix_e.html
https://developer.valvesoftware.com/wiki/Half_Lambert
http://en.wikipedia.org/wiki/UV_mapping

// all content (shaders and textures) created by me, excepts the Rain sound, the particle system and the environment textures
// tools used: Unity, Adobe Photoshop, MonoDevelop

// Credits:
// thanks to...

// aesqe for the rain_loop_01.ogg
// http://www.freesound.org/people/aesqe/sounds/37618/

// misterninjaboy for the rain particle system
// http://www.youtube.com/watch?v=lGSpPePkrLA  or http://forum.unity3d.com/attachment.php?attachmentid=3037&amp;d=1212704057

// Thanks for my Team Luna  (Phil,Matthias,Tom,Julian,Julia,Manu & Simon) http://bytestyles.net/luna/
// and my unity teacher Christian Bode
