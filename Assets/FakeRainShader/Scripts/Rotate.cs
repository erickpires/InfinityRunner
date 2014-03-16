using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class Rotate : MonoBehaviour {
	public float speed = 5;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		this.transform.RotateAround(new Vector3(1,1,0), speed * Time.deltaTime);
		this.transform.position = 
			new Vector3(Mathf.Sin(Time.time* 2) * 5 - Mathf.Cos (Time.time*3) * 5, 
				Mathf.Cos(Time.time * 2) * 5, Mathf.Cos(Time.time ) * 5 + Mathf.Sin(Time.time* 2) * 5);
	}
}
