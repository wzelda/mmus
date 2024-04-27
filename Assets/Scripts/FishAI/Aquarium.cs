
using FairyGUI;
using LPCFramework;
using UnityEngine;

namespace FishAI
{
    public class Aquarium : MonoBehaviour
    {
        public Vector3 tankSize = new Vector3(8,8,8);

        public DG.Tweening.Ease fishFallEase = DG.Tweening.Ease.OutCubic;
        public float fishFallDuration = 0.4f;

        public TouchControllerBase touchController;

        private Camera cameraMain;

        private void OnEnable()
        {
            EasyTouchManager.Instance.OnTouchClick += OnTouchClick;
        }

        private void OnDisable()
        {
            if (EasyTouchManager._S != null)
            {
                EasyTouchManager.Instance.OnTouchClick -= OnTouchClick;
            }
        }

        private void EnsureCamera()
        {

            if (cameraMain == null || !cameraMain.isActiveAndEnabled)
            {
                cameraMain = Camera.main;
            }
        }

        // 水族馆点击交互
        public void OnTouchClick(Vector3 touchPosition)
        {
            if (Stage.isTouchOnUI)
            {
                return;
            }
            EnsureCamera();

            var ray = cameraMain.ScreenPointToRay(touchPosition);

            var hits = Physics.CapsuleCastAll(ray.origin, ray.GetPoint(cameraMain.farClipPlane), 1, ray.direction, cameraMain.farClipPlane, LayerMask.GetMask("Fish", "Default"));

            foreach (var hit in hits)
            {
                var controller = hit.collider.gameObject.GetComponentInParent<FishMoveController>();
                if (controller != null)
                {
                    controller.StartEscape();
                }
            }
        }

        private void Update()
        {
            if (touchController != null)
            {
                touchController.Update();
            }
        }

        public Vector3 ClampPosition(Vector3 pos)
        {
            var tankCenter = transform.position;
            var halfSize = tankSize / 2;
            pos.x = Mathf.Clamp(pos.x, tankCenter.x - halfSize.x, tankCenter.x + halfSize.x);
            pos.y = Mathf.Clamp(pos.y, tankCenter.y - halfSize.y, tankCenter.y + halfSize.y);
            pos.z = Mathf.Clamp(pos.z, tankCenter.z - halfSize.z, tankCenter.z + halfSize.z);

            return pos;
        }

        public Vector3 RandomPosition()
        {
            var t = Vector3.zero;
            t.x = Random.Range(-tankSize.x, tankSize.x) / 2 + transform.position.x;
            t.y = Random.Range(-tankSize.y, tankSize.y) / 2 + transform.position.y;
            t.z = Random.Range(-tankSize.z, tankSize.z) / 2 + transform.position.z;

            return t;
        }

        public bool IsInAquarium(Vector3 pos)
        {
            var tankCenter = transform.position;
            var halfSize = tankSize / 2;

            return (pos.x > tankCenter.x - halfSize.x && pos.x < tankCenter.x + halfSize.x
                && pos.y > tankCenter.y - halfSize.y && pos.y < tankCenter.y + halfSize.y
                && pos.z > tankCenter.z - halfSize.z && pos.z < tankCenter.z + halfSize.z);
        }

#if UNITY_EDITOR
        private void OnDrawGizmos()
        {
            var tankCenter = transform.position;
            Gizmos.DrawWireCube(tankCenter, tankSize);
        }
#endif

        #region DragControll

        [Header("缩放系数")]
        [SerializeField]
        private float m_scaleMultiple = 1f;
        [Header("滑动系数")]
        [SerializeField]
        private float m_moveMultiple = 6f;

        private float m_minFieldOfView = 10f;
        private float m_maxFieldOfView = 180f;

        bool isDragging;
        Vector2 dragStartPos;
        Plane dragPlane;
        public void EnableDrag()
        {
            if (touchController == null)
            {
                EnsureCamera();

                if (Input.touchSupported)
                {
                    touchController = new TouchController();
                }
                else
                {
                    touchController = new MouseController();
                }

                touchController.Init(OnTouchBegin, OnTouchMove, OnTouchScale, OnTouchEnd);
                dragPlane = new Plane(cameraMain.transform.forward, transform.position);
            }
        }

        public void DisableDrag()
        {
            if (touchController != null)
            {
                touchController = null;
            }
        }

        private void OnTouchBegin(Vector2 pos)
        {
            dragStartPos = pos;
            isDragging = false;
        }

        bool ShouldDragStart(Vector2 pos)
        {
            return (dragStartPos - pos).sqrMagnitude >= UIConfig.touchDragSensitivity;
        }

        private void OnTouchMove(Vector2 from, Vector2 to)
        {
            if (!isDragging && ShouldDragStart(to) && !Stage.isTouchOnUI)
            {
                isDragging = true;
            }

            if (isDragging)
            {
                Ray r1 = cameraMain.ScreenPointToRay(to);
                Ray r2 = cameraMain.ScreenPointToRay(from);

                float d1, d2;
                if (this.dragPlane.Raycast(r1, out d1) && dragPlane.Raycast(r2, out d2))
                {
                    var p1 = r1.GetPoint(d1);
                    var p2 = r2.GetPoint(d2);

                    var targetPosition = cameraMain.transform.position + (p2 - p1);
                    cameraMain.transform.position = targetPosition;
                }
            }
        }

        void OnTouchScale(float distance)
        {
            float field = cameraMain.fieldOfView - (distance * m_scaleMultiple);
            cameraMain.fieldOfView = Mathf.Clamp(field, m_minFieldOfView, m_maxFieldOfView);
        }

        void OnTouchEnd()
        {
        }

        #endregion DragControll
    }
}
