using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class LookAtCamera : MonoBehaviour
{
    public enum LookAtType
    {
        None = -1,
        Z = 0,
        Point = 1,
    }
    public LookAtType lookAtType;
    public Vector3 lookAtOffset;
    public Transform targetCamera;
    private Vector3 targetDir;
    public bool isReverse = true;
    void Start()
    {
        if (targetCamera == null)
        {
            targetCamera = Camera.main.transform;
        }
    }
    void Update()
    {
        if (null == targetCamera)
        {
            return;
        }
        if (lookAtType == LookAtType.Z)
        {
            if (isReverse)
                targetDir = -targetCamera.forward + lookAtOffset.normalized;
            else
                targetDir = targetCamera.forward + lookAtOffset.normalized;
            transform.LookAt(transform.position + targetDir);
        }
        else if (lookAtType == LookAtType.Point)
        {
            transform.LookAt(targetCamera);
        }
    }
}
