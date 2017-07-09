using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CutPlane : MonoBehaviour {

    private Vector3 normal;
    private Vector3 rot;

    public GameObject clipObj;
    private Material clipObjMat;

    void Start () {
        this.normal = this.GetComponent<MeshFilter>().mesh.normals[0];

        float angle = Mathf.Sin(Mathf.PI / 6.0F);
        this.rot = Vector3.one * angle;

        this.clipObjMat = clipObj.GetComponent<MeshRenderer>().material;
    }
	
	void Update () {
        this.transform.Rotate(this.rot);

        this.clipObjMat.SetVector("_PlaneCenter", this.transform.position);
        this.clipObjMat.SetVector("_PlaneNormal", this.transform.TransformDirection(this.normal));
    }
}
