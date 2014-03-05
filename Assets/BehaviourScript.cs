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
	public GUIText counter;
	
	Vector3 movementVelocity = Vector3.zero;
	bool hasJumped = false;
	bool onGround;
	bool crouching;
	
	float distance;
	// Use this for initialization
	void Start () {

		animation.Play("run");
		
		distance = 0;
		
		
	}
	
	// Update is called once per frame
	void Update () {
		//Variable Initiation
		CharacterController controller = (CharacterController)GetComponent<CharacterController>();
		GamePadState state = GamePad.GetState(0);
		onGround = transform.position.y > 0.1 ? false : true;//controller.isGrounded;
		
		movementVelocity = (transform.forward * Time.deltaTime * forwardSpeed);

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
			movementVelocity.y = Mathf.Sqrt(2 * jumpHeight * gravity);
		}

		if(crouching)
			controller.height = 1;
		else
			controller.height = 2;


		if (hasJumped && onGround && !Input.GetKey(KeyCode.Space) && state.Buttons.A == ButtonState.Released){
			hasJumped = false;
		}

		Animate();
		
		ApplyGravity();
		
		controller.Move(movementVelocity * Time.deltaTime);
		
		distance += movementVelocity.z * Time.deltaTime;
		
		counter.text = string.Format( "Distancia percorrida: {0:0.0}", distance);
	}
	
	void ApplyGravity(){
		if(!onGround)
			movementVelocity.y -= gravity * Time.deltaTime;
			
	}
	
	void Animate(){
		if (!onGround)
			animation.Play ("jump");
		else if(crouching)
			animation.Play("crouchRun");
		else
			animation.Play ("run");
	}
	
	void OnTriggerEnter( Collider other){
		Debug.Log("Collidiu com " + other);
	}
}
