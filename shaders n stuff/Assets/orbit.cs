using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class orbit : MonoBehaviour {
	public float r=1;
	public float h=1;
	public float speed=1;
	
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		float t=speed*Time.time*Mathf.PI/180;
		transform.localPosition=new Vector3(r*Mathf.Cos(t),h,r*Mathf.Sin(t));
	}
}
