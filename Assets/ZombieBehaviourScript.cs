using UnityEngine;
using System.Collections;

public class ZombieBehaviourScript : MonoBehaviour {

	public float idleDistance;
	public float speed;
	
	bool isNearPlayer;
	
	GameObject player;
	
	// Use this for initialization
	void Start () {
		rigidbody.freezeRotation = true;
		isNearPlayer = false;
		
		player = GameObject.Find("Player");
	}
	
	// Update is called once per frame
	void Update () {
		
		Vector3 playerDirection = player.transform.position - this.transform.position;
		playerDirection.y = 0;
		
		
		if(playerDirection.magnitude < idleDistance){
			rigidbody.velocity = playerDirection.normalized * speed;
			transform.forward = playerDirection.normalized;
			
			if(!isNearPlayer){
				isNearPlayer = true;
				audio.enabled = true;
			}
		}
		else
			rigidbody.velocity = Vector3.zero;
			
		stopGoingUp();
	}
	
	void stopGoingUp(){
		Vector3 pos = transform.position;
		pos.y = 0;
		transform.position = pos;
	}
}
