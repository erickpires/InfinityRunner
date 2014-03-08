using UnityEngine;
using System.Collections;

public class BarriersScript : MonoBehaviour {
	
	public GameObject[] barriers;
	public GameObject[] floorObjects;
	public GameObject[] scenarioElements;
	public GameObject player;
	public GameObject zombie;
	public GameObject gold;
	public float minDistance;
	public int maxBarriers;
	public int maxFloorObjects;
	public int maxZombies;

	public double floorObjectProbability;
	public double ZombieProbability;
	public double goldProbability;
	public double scenarioElementProbability;
	
	GameObject fartherBarrier;
	GameObject closestBarrier;
	System.Random random = new System.Random();
	//bool playerIsAlive;
	
	ArrayList barriersInGame = new ArrayList();
	ArrayList floorObjectsInGame = new ArrayList();
	ArrayList zombiesInGame = new ArrayList();
	ArrayList goldInGame = new ArrayList();
	ArrayList scenarioElementsInGame = new ArrayList();
	
	// Use this for initialization
	void Start () {
		
		Messenger.AddListener("player died", playerHasDied);
		//playerIsAlive = true;
		
		for(int i = 0; i < maxBarriers; i++){
			createBarrier();
		}
	
	}
	
	// Update is called once per frame
	void Update () {
			if(isBehindPlayer(closestBarrier)){
				barriersInGame.Remove(closestBarrier);
				Destroy(closestBarrier);
				
				closestBarrier = barriersInGame[0] as GameObject;
				
				createBarrier();
			}
			
			if(floorObjectsInGame.Count < maxFloorObjects)
				if(random.NextDouble() < floorObjectProbability){
					Vector3 pos = generateRandomPosition();	
					if(canSpawn(pos))
						createFloorObject(pos);
				}
			
			if (zombiesInGame.Count < maxZombies)
					if (random.NextDouble () < ZombieProbability) {
							Vector3 pos = generateRandomPosition ();
							if (canSpawn (pos))
									createZombie (pos);
					}
				
			if(random.NextDouble() < goldProbability){
				Vector3 pos = generateRandomPosition();
				if(canSpawn(pos))
					createGold(pos);
			}
			
			if(random.NextDouble() < scenarioElementProbability){
				int randomNumber = random.Next(0, scenarioElements.Length);
				
				if((scenarioElements[randomNumber] as GameObject).name.Contains("Door") || random.NextDouble() < 0.4){					
					Vector3 pos = generateRandomPosition();
					pos.x = (scenarioElements[randomNumber] as GameObject).transform.position.x;				
				
					if(canSpawn(pos))
						createCenarioElement(pos, randomNumber);
				}
			}
			
			removeUnnecessary(floorObjectsInGame);
			removeUnnecessary(zombiesInGame);
			removeUnnecessary(goldInGame);
			removeUnnecessary(scenarioElementsInGame);
	}

	bool isBehindPlayer (GameObject o){
		return player.transform.position.z - o.transform.position.z > minDistance;
	}
	
	bool canSpawn(Vector3 pos){
		Ray ray = new Ray(pos, Vector3.up);
		
		return !Physics.Raycast(ray, 3);
	}

	void createBarrier (){
		int randomNumber = random.Next(0, barriers.Length);
		
		GameObject barrier = GameObject.Instantiate(barriers[randomNumber]) as GameObject;
		
		Vector3 barrierPos = barrier.transform.position;
		if(fartherBarrier == null){
			barrierPos.z = random.Next(50, 70);
			closestBarrier = barrier;
		}
		else
			barrierPos.z = fartherBarrier.transform.position.z + random.Next(20, 30);
			
		barrier.transform.position = barrierPos;
		
		barriersInGame.Add(barrier);
		fartherBarrier = barrier;
	}

	void createFloorObject (Vector3 pos){
		int randomNumber = random.Next(0, floorObjects.Length);
		
		GameObject floorObject = GameObject.Instantiate(floorObjects[randomNumber]) as GameObject;
		
		Vector3 floorObjectPos = floorObject.transform.position;
		
		floorObjectPos.x = pos.x;
		floorObjectPos.z = pos.z;
		
		floorObject.transform.position = floorObjectPos;
		
		floorObjectsInGame.Add(floorObject);
	}

	void createZombie (Vector3 pos){
		GameObject zombieObject = GameObject.Instantiate(zombie) as GameObject;
		
		Vector3 zombiePos = zombieObject.transform.position;
		
		zombiePos.x = pos.x;
		zombiePos.z = pos.z;
		
		zombieObject.transform.position = zombiePos;
		
		zombiesInGame.Add(zombieObject);
	}

	void createGold (Vector3 pos){
		GameObject goldObject = GameObject.Instantiate(gold) as GameObject;
		
		Vector3 goldPos = goldObject.transform.position;
		
		goldPos.x = pos.x;
		goldPos.z = pos.z;
		
		goldObject.transform.position = goldPos;
		
		goldInGame.Add(goldObject);
	}

	void createCenarioElement (Vector3 pos, int randomNumber){
		
		
		GameObject scenarioElement = GameObject.Instantiate(scenarioElements[randomNumber]) as GameObject;
		
		Vector3 floorObjectPos = scenarioElement.transform.position;

		floorObjectPos.z = pos.z;
		
		scenarioElement.transform.position = floorObjectPos;
		
		scenarioElementsInGame.Add(scenarioElement);
	}

	Vector3 generateRandomPosition (){
		float x = (float)random.NextDouble() * 4 - 2;
		float z = (float)random.NextDouble() * (200 - 50) + 50 + player.transform.position.z;
		
		return new Vector3(x, 0, z);
	}

	void removeUnnecessary (ArrayList list){
		ArrayList tempList = list.Clone() as ArrayList;
		
		foreach(GameObject listObject in tempList){
			if(listObject == null){
				list.Remove(listObject);
				continue;
			}
			
			if(isBehindPlayer(listObject)){
				list.Remove(listObject);
				Destroy(listObject);
			}
		}
	}
	
	void playerHasDied(){
		Debug.Log("Dead Messege received");
		
		Messenger.Cleanup();
		gameObject.SetActive(false);
		//playerIsAlive = false;
	}
}
