using UnityEngine;
using System.Collections;
using XInputDotNetPure;

/* Xbox 360 controller wrapper
* https://github.com/speps/XInputDotNet
*/

public class BehaviourScript : MonoBehaviour {
	
	public float forwardSpeed;
	public float gravity;
	public float jumpHeight;
	public float sideSpeed;
	public float standingHeight;
	public float crouchingHeight;
	
	public Vector3 standingCenter;
	public Vector3 crouchingCenter;
	
	public GUIText score;
	public GUIText goldText;
	
	Vector3 movementVelocity = Vector3.zero;
	bool hasJumped = false;
	bool onGround;
	bool crouching;
	bool isAlive;
	
	float distance;
	float speedVariation;
	int gold;

	// Use this for initialization
	void Start () {
		
		animation.Play("run");
		
		distance = 0;
		isAlive = true;
		
		gold = 0;
		goldText.text = "Ouro: " + gold;
	}
	
	// Update is called once per frame
	void Update () {
		//Variable Initiation
		CharacterController controller = (CharacterController)GetComponent<CharacterController>();
		GamePadState state = GamePad.GetState(0);
		
		if(isAlive){
			movementVelocity = (transform.forward * Time.deltaTime * (forwardSpeed + speedVariation));
			
			if(onGround && (Input.GetKey(KeyCode.LeftArrow) || state.ThumbSticks.Left.X == -1)){
				movementVelocity -= Vector3.right * sideSpeed;
			}
			if(onGround && (Input.GetKey(KeyCode.RightArrow) || state.ThumbSticks.Left.X == 1)){
				movementVelocity += Vector3.right * sideSpeed;
			}
			
			if (onGround && (Input.GetKey (KeyCode.LeftControl) || state.Buttons.B == ButtonState.Pressed))
				crouching = true;
			else
				crouching = false;
			
			if ((Input.GetKey (KeyCode.Space) || state.Buttons.A == ButtonState.Pressed) && !hasJumped) {
				Debug.Log("jumped");
				hasJumped = true;
				onGround = false;
				movementVelocity.y = Mathf.Sqrt(2 * jumpHeight * gravity);
			}
			
			if(crouching){
				controller.height = crouchingHeight;
				controller.center = crouchingCenter;
			}
			else{
				controller.height = standingHeight;
				controller.center = standingCenter;
			}
			
			
			if (hasJumped && onGround && !Input.GetKey(KeyCode.Space) && state.Buttons.A == ButtonState.Released){
				hasJumped = false;
			}
			
			Animate();
			
			ApplyGravity();
			
			AdjustSpeedVariation();
			
			controller.Move(movementVelocity * Time.deltaTime);
			
			distance += movementVelocity.z * Time.deltaTime;
			
			score.text = string.Format( "Distancia percorrida: {0:0.0} m", distance);
		}
		else{
			animation.Play("idle");
			
			if(Input.GetKey (KeyCode.Return) || state.Buttons.Y == ButtonState.Pressed){
				Debug.Log("reloaded");
				Application.LoadLevel(Application.loadedLevel);
			}
		}
	}
	
	void ApplyGravity(){
		movementVelocity.y -= gravity * Time.deltaTime;
		
	}

	void AdjustSpeedVariation (){
		
		if(speedVariation > 0)
			speedVariation -= 20;
		if(speedVariation < 0)
			speedVariation += 1;
	}
	
	void Animate(){
		if (!onGround)
			animation.Play ("jump");
		else if(crouching)
			animation.Play("crouchRun");
		else
			animation.Play ("run");
	}
	
	void OnControllerColliderHit(ControllerColliderHit hit){
		Debug.Log("collided with " + hit.gameObject);
		if(hit.gameObject.name == "Barrier" || hit.collider.name == "Zombie")
			Die();
			
		if(hit.gameObject.name == "Ground")
			onGround = true;
			
		if(hit.gameObject.name == "Gold Ignot"){
			gold++;
			Destroy(hit.gameObject);
			goldText.text = "Ouro: " + gold;
		}
		
		if(hit.gameObject.name == "Water")
			speedVariation = 300;
		
		if(hit.gameObject.name == "Snow")
			speedVariation = -100;
	}
	
	void Die (){
		float record = 0;
		bool newRecord = false;
		
		if(System.IO.File.Exists("record.dat")){
			Debug.Log("record exists");
			
			System.IO.StreamReader streamReader = new System.IO.StreamReader("record.dat");
			
			record = float.Parse(streamReader.ReadLine());
			
			streamReader.Close();
		}
		
		if(distance > record){
			Debug.Log("new Record");
			record = distance;
			newRecord = true;
			System.IO.StreamWriter streamWriter = new System.IO.StreamWriter("record.dat");
			
			streamWriter.WriteLine(distance.ToString());
			
			streamWriter.Close();
		}
		
		ShowGameOverText(record, newRecord);
		
		isAlive = false;
	}
	
	void ShowGameOverText(float record, bool isNewRecord){
		GameObject textObject = new GameObject("Game Over");
		
		textObject.transform.position = new Vector3(0.5f, 0.5f, 0);
		textObject.AddComponent("GUIText");
		textObject.guiText.fontSize = 70;
		textObject.guiText.anchor = TextAnchor.MiddleCenter;
		textObject.guiText.color = Color.red;
		textObject.guiText.text = "Game\n Over";
		
		GameObject textObject2 = new GameObject("Score");
		
		string text = string.Format("Recorde atual: {0:0.0} m", record);
		
		if(isNewRecord)
			text = "Novo Recorde\n" + text;
		
		textObject2.transform.position = new Vector3(0.5f, 0, 0);
		textObject2.AddComponent("GUIText");
		textObject2.guiText.fontSize = 50;
		textObject2.guiText.anchor = TextAnchor.LowerCenter;
		textObject2.guiText.alignment = TextAlignment.Center;
		textObject2.guiText.color = Color.grey;
		textObject2.guiText.text = text;
	}
}
