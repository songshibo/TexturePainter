using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour {

	Quaternion TargetRot;
	Quaternion Camera_TargetRot;
	public Transform _camera;
	private bool IsCursorLocked = true;
	// Use this for initialization
	void Start () {
		Camera_TargetRot = _camera.localRotation;
		TargetRot = transform.localRotation;
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetKey (KeyCode.Escape)) {
			if (IsCursorLocked) {
				IsCursorLocked = false;
			} else {
				IsCursorLocked = true;
			}
		}

		if (IsCursorLocked) {
			Cursor.visible = false;
		} else {
			Cursor.visible = true;
		}

		if (IsCursorLocked) {
			Rotate ();
		}
		Move ();
	}

	void Move(){
		
		float h = Input.GetAxis ("Horizontal");
		float v = Input.GetAxis ("Vertical");

		Vector3 move = (_camera.forward * v + transform.right * 3f * h);
		transform.position += move * Time.deltaTime;
	}

	void Rotate(){
		float yRot = Input.GetAxis("Mouse X") * 5f;
		float xRot = Input.GetAxis("Mouse Y") * 5f;

		TargetRot *= Quaternion.Euler (0, yRot, 0);
		Camera_TargetRot *= Quaternion.Euler (-xRot, 0, 0);

		Camera_TargetRot = ClampRotationAroundXAxis (Camera_TargetRot);

		_camera.localRotation = Quaternion.Slerp (_camera.localRotation, Camera_TargetRot, Time.deltaTime);
		transform.localRotation = Quaternion.Slerp (transform.localRotation, TargetRot, Time.deltaTime);
	}

	Quaternion ClampRotationAroundXAxis(Quaternion q)
	{
		q.x /= q.w;
		q.y /= q.w;
		q.z /= q.w;
		q.w = 1.0f;

		float angleX = 2.0f * Mathf.Rad2Deg * Mathf.Atan (q.x);

		angleX = Mathf.Clamp (angleX, -90f, 90f);

		q.x = Mathf.Tan (0.5f * Mathf.Deg2Rad * angleX);

		return q;
	}
}
