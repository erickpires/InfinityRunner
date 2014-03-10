using UnityEngine;
using System.Collections;

public class WallsScript : MonoBehaviour {
	
	public GameObject player;
	public GameObject leftWall;
	public GameObject rightWall;
	public GameObject ground;
	
	float wallLength = 100;
	
	ArrayList leftWallsInGame = new ArrayList();
	ArrayList rightWallsInGame = new ArrayList();
	ArrayList groundsInGame = new ArrayList();
	
	// Use this for initialization
	void Start () {
		GameObject left = GameObject.Instantiate(leftWall) as GameObject;
		GameObject right = GameObject.Instantiate(rightWall) as GameObject;
		GameObject groundObject = GameObject.Instantiate(ground) as GameObject;
		
		leftWallsInGame.Add(left);
		rightWallsInGame.Add(right);
		groundsInGame.Add(groundObject);
	}
	
	// Update is called once per frame
	void Update () {
		int wallsNumber = leftWallsInGame.Count;
		GameObject lastLeftWall = leftWallsInGame[wallsNumber - 1] as GameObject;
		if(lastLeftWall.transform.position.z - player.transform.position.z < 250){
			GameObject newLeftWall = GameObject.Instantiate(leftWall) as GameObject;
			GameObject newRightWall = GameObject.Instantiate(rightWall) as GameObject;
			GameObject newGround = GameObject.Instantiate(ground) as GameObject;
			
			Vector3 leftPosition = newLeftWall.transform.position;
			leftPosition.z = lastLeftWall.transform.position.z + wallLength;
			newLeftWall.transform.position = leftPosition;
			
			Vector3 rightPosition = newRightWall.transform.position;
			rightPosition.z = lastLeftWall.transform.position.z + wallLength;
			newRightWall.transform.position = rightPosition;
			
			Vector3 centerPosition = newGround.transform.position;
			centerPosition.z = lastLeftWall.transform.position.z + wallLength;
			newGround.transform.position = centerPosition;
			
			leftWallsInGame.Add(newLeftWall);
			rightWallsInGame.Add(newRightWall);
			groundsInGame.Add(newGround);
		}
		
		if(firstWallIsBehindPlayer())
			removeFirstWall();
	}
	
	bool firstWallIsBehindPlayer (){
		return player.transform.position.z - (leftWallsInGame[0] as GameObject).transform.position.z > 60;
	}
	
	void removeFirstWall (){
		
		Destroy(leftWallsInGame[0] as GameObject);
		Destroy(rightWallsInGame[0] as GameObject);
		Destroy(groundsInGame[0] as GameObject);
		
		leftWallsInGame.RemoveAt(0);
		rightWallsInGame.RemoveAt(0);
		groundsInGame.RemoveAt(0);
	}
}
