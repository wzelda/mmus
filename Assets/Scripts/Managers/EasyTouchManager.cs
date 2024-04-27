using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace LPCFramework
{
    [LuaCallCSharp]
    public class EasyTouchManager : SingletonMonobehaviour<EasyTouchManager>
    {
        public bool EnableTouch = false;        
        Ray m_ray;
        RaycastHit m_hit;
        RaycastHit m_directionhit;
        public Vector3 dirHitPoint;

        public Camera sceneCam;
        public System.Action<Vector3> OnTouchDown;
        public System.Action<Vector3> OnTouchPress;
        public System.Action<Vector3> OnTouchUp;
        public event System.Action<Vector3> OnTouchClick;
        public event System.Action<Vector3> OnTouchDoubleClick;
        public System.Action<Touch, Touch> OnMulitTouch;
        public System.Action<float> OnMouseScroll;
        public System.Action OnTouchUpdate;

        public System.Action OnAndroidEscape;
        public System.Action OnAndroidHome;

        
        private void Awake()
        {
            
        }

        public void AddCallBack(System.Action<Vector3> OnTouchDown,
            System.Action<Vector3> OnTouchPress,
            System.Action<Vector3> OnTouchUp)
        {
            this.OnTouchDown = OnTouchDown;
            this.OnTouchPress = OnTouchPress;
            this.OnTouchUp = OnTouchUp;
            EnableTouch = true;
        }

        public void ClearCallBack()
        {            
            OnTouchDown = null;
            OnTouchPress = null;
            OnTouchUp = null;
            OnMulitTouch = null;
            OnMouseScroll = null;
            OnTouchUpdate = null;
            OnAndroidEscape = null;
            OnAndroidHome = null;

            EnableTouch = false;
        }

        public void OnInitialize()
        {
            ClearCallBack();
        }

        public GameObject[] GetHitGameObjects(Vector3 beginpos,Vector3 direction,float maxdistance,int selectlayer)
        {
            if(sceneCam != null)
            {                
                RaycastHit[] hits = Physics.RaycastAll(beginpos, direction, maxdistance, 1 << selectlayer);                
                if (hits != null && hits.Length > 0)
                {
                    GameObject[] gos = new GameObject[hits.Length];
                    for (int i = 0;i<hits.Length;i++)
                    {             
                        gos[i] = hits[i].collider.gameObject;                        
                    }
                    return gos;
                }
                return null;
            }
            return null;
        }

        public GameObject[] GetScreenHitGameObjects(Vector3 touchPos, float maxdistance,int selectlayer)
        {
            if (sceneCam != null)
            {
                Ray ray = sceneCam.ScreenPointToRay(touchPos);
                RaycastHit[] hits = Physics.RaycastAll(ray, maxdistance, 1 << selectlayer);
                if (hits != null && hits.Length > 0)
                {
                    GameObject[] gos = new GameObject[hits.Length];
                    for (int i = 0; i < hits.Length; i++)
                    {
                        gos[i] = hits[i].collider.gameObject;
                    }
                    return gos;
                }
                return null;
            }

            return null;
        }


        public GameObject GetHitGameObject(Vector3 touchPos,int selectlayer)
        {
            if (sceneCam != null)
            {
                m_ray = sceneCam.ScreenPointToRay(touchPos);
                if (Physics.Raycast(m_ray, out m_hit, 1000, 1 << selectlayer))
                {
                    GameObject selectObject = m_hit.collider.gameObject;
                    return selectObject;
                }                
                return null;
            }            
            return null;
        }

        public bool RaycastToDest(Vector3 origin,Vector3 directon,int selectlayer)
        {
            if (Physics.Raycast(origin, directon, out m_directionhit, 1000, 1 << selectlayer))
            {
                //Debug.LogError("碰到了 :" + m_directionhit.collider.name + "  坐标是:" + m_directionhit.point);
                dirHitPoint = m_directionhit.point;
                return true;
            }
            return false;
        }

        public void SetSceneCam(Camera cam)
        {
            sceneCam = cam;
        }

        public void FindCamera()
        {
            if (sceneCam == null || !sceneCam.isActiveAndEnabled)
            {
                sceneCam = Camera.main;                
            }
        }

        public Vector3 GetHitPosition(Vector3 touchPos, int selectlayer)
        {
            if (sceneCam != null)
            {
                m_ray = sceneCam.ScreenPointToRay(touchPos);
                if (Physics.Raycast(m_ray, out m_hit, 1000, 1 << selectlayer))
                {
                    //GameObject go = GameObject.Instantiate(Resources.Load("Effects/Eff_Rou")) as GameObject;
                    //go.transform.position = m_hit.point;
                    return m_hit.point;
                }
                Debug.LogWarning("什么都没碰到");
                return Vector3.zero;
            }
            Debug.LogWarning("什么都没碰到");
            return Vector3.zero;
        }
        public void OnUpdate()
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                if (Input.GetKeyUp(KeyCode.Escape))
                {
                    if (OnAndroidEscape != null)
                    {
                        OnAndroidEscape();
                    }
                }

                if (Input.GetKeyUp(KeyCode.Home))
                {
                    if (OnAndroidHome != null)
                    {
                        OnAndroidHome();
                    }
                }

            }


            if (!EnableTouch)
                return;

            if (OnTouchUpdate != null)
            {
                OnTouchUpdate();
            }

#if UNITY_EDITOR || UNITY_STANDALONE_WIN || UNITY_STANDALONE_OSX
            UpdateMouse();
#elif UNITY_IPHONE || UNITY_ANDROID || UNITY_WP8 || UNITY_BLACKBERRY
            UpdateTouch();
#endif
        }

        void TouchDownLogic(Vector3 touchPos)
        {
            FindCamera();
            lastTouchDownTime = Time.realtimeSinceStartup;
            lastTouchDownPos = touchPos;
            if (OnTouchDown != null)
            {
                OnTouchDown(touchPos);
            }
        }

        void TouchUpLogic(Vector3 touchPos)
        {
            if (OnTouchUp != null)
            {
                OnTouchUp(touchPos);
            }
            //判断点击事件
            TouchClick(touchPos);         
        }
        
        void TouchPressLogic(Vector3 touchPos)
        {
            if (OnTouchPress != null)
            {
                OnTouchPress(touchPos);
            }
        }

        void MultiTouchPressLogic(Touch touch1, Touch touch2)
        {            
            if (OnMulitTouch != null)
            {                                
                OnMulitTouch(touch1, touch2);                
            }
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
            else
            {
                UpdateMouseScroll();                
            }
        }

        private void UpdateTouch()
        {
            FindCamera();
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
            else if (Input.touchCount > 1)
            {
                // 多点触控处理                     
                MultiTouchPressLogic(Input.touches[0], Input.touches[1]);
            }


        }

        float lastClickTime = 0;         //上次点击时间    
        float lastTouchDownTime = 0;      //上次按下时间
        Vector3 lastTouchDownPos;     //上次按下的位置 
        public float clickDeltaDis = 0.5f;  //点击位移限制
        public float clickTimeInterval = 0.25f; //点击时间间隔
        float doubleClickTimeInterval = 0.2f; //点击时间
        float delay = 200;
        float status = 0; // 0:click、dbclick事件执行结束了，1：触发了click事件，2：click事件正在执行，3：dbClick事件正在执行

        private void TouchClick(Vector3 touchPos)
        {
            if (Time.realtimeSinceStartup - lastTouchDownTime < clickTimeInterval && Vector3.Distance(touchPos, lastTouchDownPos) < clickDeltaDis)
            {
                if (OnTouchClick != null)
                {
                    OnTouchClick(lastTouchDownPos);
                }
                //判断双击事件
                TouchDoubleClick();
                lastClickTime = Time.realtimeSinceStartup;
            }
        }

        private void TouchDoubleClick()
        {
            if (Time.realtimeSinceStartup - lastClickTime < doubleClickTimeInterval)
            {
                if (OnTouchDoubleClick != null)
                {
                    OnTouchDoubleClick(lastTouchDownPos);
                }
            }
        }

        void UpdateMouseScroll()
        {
            FindCamera();
            if (Input.mousePosition.x < 0 || Input.mousePosition.x > Screen.width || Input.mousePosition.y < 0 || Input.mousePosition.y > Screen.height)
                return;
            if (OnMouseScroll != null)
            {
                OnMouseScroll(Input.GetAxis("Mouse ScrollWheel"));
            }
        }
        
        
        private void OnDestroy()
        {
            ClearCallBack();
        }

        public static void Destruct()
        {
            if (_S != null)
            {
                _S.ClearCallBack();
                Destroy(_S);
            }
        }
    }

}