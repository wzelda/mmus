using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KeepHorizontal : MonoBehaviour {
	Transform cacheTrans;
	Vector3 cacheV3 = new Vector3(0, 180, 0);

	// Use this for initialization
	void Start () {
		cacheTrans = transform;
	}
	private void OnEnable() {
		gameObject.GetComponent<SpriteRenderer>().enabled = true;
	}
	// Update is called once per frame
	void LateUpdate () {
		cacheTrans.eulerAngles = cacheV3;
	}
}
