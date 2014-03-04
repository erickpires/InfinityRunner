using UnityEngine;
using System.Collections;
using XInputDotNetPure;

public class BehaviourScript : MonoBehaviour {

	public float forwardSpeed;
	public float gravity;
	public float jumpHeight;
	public float sideSpeed;
	
	Vector3 movementVelocity = Vector3.zero;
	bool jumping = false;
	bool onGround;
	bool crouching;
	// Use this for initialization
	void Start () {

		animation.Play("run");
		
		
	}
	
	// Update is called once per frame
	void Update () {
		//Variable Initiation
		CharacterController controller = (CharacterController)GetComponent<CharacterController>();
		GamePadState state = GamePad.GetState(0);
		onGround = transform.position.y > 0.1 ? false : true;//controller.isGrounded;
		
		movementVelocity = (transform.forward * Time.deltaTime * forwardSpeed);

		if(Input.GetKey(KeyCode.LeftArrow) || state.ThumbSticks.Left.X == -1){
		  	movementVelocity -= Vector3.right * sideSpeed;
		}
		if(Input.GetKey(KeyCode.RightArrow) || state.ThumbSticks.Left.X == 1){
			movementVelocity += Vector3.right * sideSpeed;
		}

		if (Input.GetKey (KeyCode.LeftControl) || state.Buttons.B == ButtonState.Pressed)
			crouching = true;
		else
			crouching = false;
			
		if (!jumping && (Input.GetKey (KeyCode.Space) || state.Buttons.A == ButtonState.Pressed)) {
			jumping = true;
				movementVelocity.y = Mathf.Sqrt(2 * jumpHeight * gravity);
		}


		if (jumping && onGround && !Input.GetKey(KeyCode.Space) && state.Buttons.A == ButtonState.Released){
			jumping = false;
		}

		Animate();
		
		ApplyGravity();
		
		controller.Move(movementVelocity * Time.deltaTime);
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
}
