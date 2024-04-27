using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace LPCFramework
{
    public class CameraCollider : MonoBehaviour
    {
        HashSet<GameObject> ColliderGameobjects = new HashSet<GameObject>();
        BoxCollider m_Collider;
        Rigidbody m_rightBody;
        int m_selectlayer;

        
        public void Init(int selectlayer)
        {
            m_selectlayer = selectlayer;
            m_Collider = transform.GetComponent<BoxCollider>();
            if (m_Collider == null)
                m_Collider = gameObject.AddComponent<BoxCollider>();

            m_Collider.isTrigger = true;


            m_rightBody = transform.GetComponent<Rigidbody>();
            if (m_rightBody == null)
                m_rightBody = gameObject.AddComponent<Rigidbody>();
            m_rightBody.useGravity = false;
            m_rightBody.constraints = RigidbodyConstraints.FreezeAll;
        }

        public void SetSeeSize(float width,float height,float length)
        {
            m_Collider.size = new UnityEngine.Vector3(width, height, length);
            m_Collider.center = new UnityEngine.Vector3(0, 0, length / 2);
        }
                
        void OnTriggerEnter(Collider other)
        {            
            GameObject cgo = other.gameObject;
            if (cgo.layer != m_selectlayer)
                return;

            if (cgo.GetComponent<Renderer>() != null)
            {
                cgo.GetComponent<Renderer>().enabled = false;
            }                        
        }

        void OnTriggerExit(Collider other)
        {           
            GameObject cgo = other.gameObject;
            if (cgo.layer != m_selectlayer)
                return;

            if (cgo.GetComponent<Renderer>() != null)
            {
                cgo.GetComponent<Renderer>().enabled = true;
            }            
        }
    }
}
