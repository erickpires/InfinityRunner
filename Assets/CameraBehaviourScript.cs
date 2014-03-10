using UnityEngine;
using System.Collections;
using XInputDotNetPure;

public class CameraBehaviourScript : MonoBehaviour {
	public GameObject player;
	public float distanceFromPlayer;
	public float cameraHeight;
	
	bool playerPoisoned;
	System.Random random = new System.Random();
	Vector3 movement;
	float xVariation = -2;
	float zVariation;
	float yVariation;
	float playerXvariation;
	
	// Use this for initialization
	void Start () {
		Messenger.AddListener("player poisoned", playerGotPoisoned);
		Messenger.AddListener("player not poisoned", playerIsNotPoisoned);
	}
	
	// Update is called once per frame
	void Update () {
		Vector3 pos = Vector3.zero;
		
		
		if(!playerPoisoned){
			pos.z = player.transform.position.z - distanceFromPlayer;
			pos.y = cameraHeight;
			
			transform.forward = player.transform.position - pos;
		}
		else{
			zVariation += RandomFloat(-3, 3);
			playerXvariation += RandomFloat(-2, 2);
			yVariation += RandomFloat(-1, 1);
			
			pos.z = player.transform.position.z - (distanceFromPlayer - zVariation * (Time.deltaTime));
			pos.y = cameraHeight + (yVariation * Time.deltaTime);
			
			if(transform.position.x < -1.5f)
				xVariation = RandomFloat(2, 5);
			
			if(transform.position.x > 1.5f)
				xVariation = RandomFloat(-5, -2);
			
			pos.x = transform.position.x + xVariation * Time.deltaTime;
			transform.forward = player.transform.position - pos + new Vector3(playerXvariation * Time.deltaTime, 0, 0);
			
			if(xVariation < 0)
				transform.rotation *= Quaternion.Euler(0, 0, 1);
			else
				transform.rotation *= Quaternion.Euler(0, 0, -2);
		}
		
		transform.position = pos;
	}
	
	float RandomFloat (float min, float max){
		return (float)(random.NextDouble() * (max - min) + min);
	}
	
	void playerGotPoisoned(){
		playerPoisoned = true;
	}
	
	void playerIsNotPoisoned(){
		playerPoisoned = false;
	}
}
