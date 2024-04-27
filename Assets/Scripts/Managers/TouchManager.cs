using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace LPCFramework
{
    [LuaCallCSharp]
    public class TouchManager : SingletonMonobehaviour<TouchManager>
    {
        public bool EnableTouch = false;

        GameObject selectObject;
        Ray m_ray;
        RaycastHit m_hit;        

        public int SelectObjectLayer = 0;
        public int FirePressLayer = 0;
        Vector3 lastposition;

        System.Action<GameObject,Vector3> OnTouchDown;
        System.Action<GameObject,Vector3,Vector2,Vector3> OnTouchPress;
        System.Action<GameObject,Vector3> OnTouchUp;
        
        private void Awake()
        {
            SelectObjectLayer = LayerMask.NameToLayer("Actor");
            FirePressLayer = LayerMask.NameToLayer("Map");
        }

        public void AddCallBack(System.Action<GameObject, Vector3> OnTouchDown,
            System.Action<GameObject, Vector3, Vector2, Vector3> OnTouchPress,
            System.Action<GameObject, Vector3> OnTouchUp)
        {
            this.OnTouchDown = OnTouchDown;
            this.OnTouchPress = OnTouchPress;
            this.OnTouchUp = OnTouchUp;
            EnableTouch = true;
        }

        public void ClearCallBack()
        {
            selectObject = null;
            OnTouchDown = null;
            OnTouchPress = null;
            OnTouchUp = null;
            EnableTouch = false;
        }

        public void OnInitialize()
        {
            selectObject = null;
        }

        public void OnUpdate()
        {
            if (!EnableTouch)
                return;

#if UNITY_EDITOR || UNITY_STANDALONE_WIN || UNITY_STANDALONE_OSX
            UpdateMouse();
#elif UNITY_IPHONE || UNITY_ANDROID || UNITY_WP8 || UNITY_BLACKBERRY
        UpdateTouch();
#endif
        }
        void TouchDownLogic(Vector3 touchPos)
        {
            selectObject = null;
            if (Camera.main != null)
            {
                m_ray = Camera.main.ScreenPointToRay(touchPos);
                if (Physics.Raycast(m_ray, out m_hit, 100, 1 << SelectObjectLayer))
                {
                    selectObject = m_hit.collider.gameObject;
                    //Debug.LogError(m_hit.collider.gameObject.name);
                    if (OnTouchDown != null)
                    {
                        OnTouchDown(selectObject,touchPos);
                    }                    
                }
            }
            lastposition = touchPos;
        }

        void TouchUpLogic(Vector3 touchPos)
        {        
            if (Camera.main != null)
            {
                m_ray = Camera.main.ScreenPointToRay(touchPos);
                if (Physics.Raycast(m_ray, out m_hit, 100, 1 << FirePressLayer))
                {
                    if (OnTouchUp != null)
                    {
                        OnTouchUp(selectObject, touchPos);
                    }
                }
            }
       
        }
        
        void TouchPressLogic(Vector3 touchPos)
        {
            Vector2 delta = (touchPos - lastposition) / Time.deltaTime;
            if (selectObject != null)
            {
                m_ray = Camera.main.ScreenPointToRay(touchPos);                
                if (Physics.Raycast(m_ray, out m_hit, 100, 1<<FirePressLayer))
                {                    
                    if (OnTouchPress != null)
                    {
                        OnTouchPress(selectObject, delta, touchPos,m_hit.point);                     
                    }
                    //Debug.LogError(m_hit.collider.gameObject.name);
                }
            }
            lastposition = touchPos;
        }

        private void UpdateMouse()
        {
            if (Input.GetKeyDown(KeyCode.Mouse0))
            {                
                TouchDownLogic(Input.mousePosition);
            }
            else if (Input.GetKeyUp(KeyCode.Mouse0))
            {
                TouchUpLogic(Input.mousePosition);
            }
            else if (Input.GetKey(KeyCode.Mouse0))
            {
                TouchPressLogic(Input.mousePosition);
            }
        }

        private void UpdateTouch()
        {
            if (Input.touchCount == 1)
            {
                Touch touch = Input.touches[0];
                if (TouchPhase.Began == touch.phase)
                {
                    TouchDownLogic(touch.position);
                }
                else if (TouchPhase.Ended == touch.phase)
                {
                    TouchUpLogic(touch.position);
                }
                else if (TouchPhase.Moved == touch.phase || TouchPhase.Stationary == touch.phase)
                {
                    TouchPressLogic(touch.position);
                }
            }
        }

        private void OnDestroy()
        {
            ClearCallBack();
        }
    }

}