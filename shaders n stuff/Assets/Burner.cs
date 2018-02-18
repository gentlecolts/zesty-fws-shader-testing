using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Burner : MonoBehaviour {
	Renderer r;

	// Use this for initialization
	void Start () {
		//make a copy of material at startup, allowing settings to be per-object
		r=GetComponent<Renderer>();
		r.material=new Material(r.material);
	}
	
	// Update is called once per frame
	void Update () {
		float x=Mathf.Sin(Time.time);
		x*=x;
		r.material.SetFloat("_BlendVal",x);
		//Debug.Log(x);
	}
}
