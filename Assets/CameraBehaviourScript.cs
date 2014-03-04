using UnityEngine;
using System.Collections;
using XInputDotNetPure;

public class CameraBehaviourScript : MonoBehaviour {
	public GameObject player;
	public float distanceFromPlayer;
	public float cameraHeight;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {

		Vector3 pos = Vector3.zero;
		pos.z = player.transform.position.z - distanceFromPlayer;
		pos.y = cameraHeight;
		transform.position = pos;
		
		transform.forward = player.transform.position - pos;
	}
}
