using UnityEngine;
using System.Collections;

public class TextureRotation : MonoBehaviour 
{
	
	Vector2 offset;
	Vector2 tiling;
	float rot = 0.0f;
	
	void Update ()
	{
	rot = transform.rotation.eulerAngles.y;
		    var matrix = Matrix4x4.TRS (offset, Quaternion.Euler (0, 0, rot), tiling);
    		renderer.material.SetMatrix ("_Matrix", matrix);
	}
	
}