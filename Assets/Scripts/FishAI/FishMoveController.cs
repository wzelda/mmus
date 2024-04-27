
using BehaviorDesigner.Runtime.Tasks.Unity.Math;
using DG.Tweening;
using FishBehavior;
using LPCFramework;
using UnityEngine;
using UnityEngine.UIElements;

namespace FishAI
{
    public class FishMoveController : AFishController
    {
        public enum SwimState
        {
            StateInit,
            StateFallOff,
            StateSwim,
            StateEscape
        }

        public SwimState swimState = SwimState.StateInit;

        public float _brake = .01f;					// 减速度有多快
        public float _speed;

        public float _escapeSpeed = 16;    // 逃逸速度

        public float _waypointDistance = 1.0f;
        [HideInInspector]
        public Transform _cacheTransform;
        public Transform _scanner;				// Scanner object used for push, this rotates to check for collisions

        public float maxWanderTime = 4;                // 防呆时间
        float wanderTime = 0f;
        bool _scan = true;

        public MyRange _turnSpeedWeight = new MyRange(2f, 4f);        // 旋转速度权重
        public MyRange _speedRange = new MyRange(0.2f, 5f);               // 速度范围
        public float _speedFactor = 1.0f;           // 实际速度=鱼本身速度*本系数

        float _targetSpeed;             // 目标速度
        public float tParam;

        float _rotateCounterR;          // 用于随着时间的推移增加壁障速度
        float _rotateCounterL;			
        ///避障
        public bool _avoidance = false;             // 避障开关
        public float _avoidAngle = 0.35f;       // 检测射线的左右角度
        public float _avoidDistance = 1.0f;     // 探测摄像的距离
        public float _avoidSpeed = 75.0f;           // 壁障的转向速度
        public float _stopDistance = .5f;      //  在停止和转向之前，这可以是多么接近它前面的对象。 这也将稍微旋转，以避免类似“机器人”行为
        public float _stopSpeedMultiplier = 2.0f;   // 停止速度
        public LayerMask _avoidanceMask = (LayerMask)(-1);

        ///PUSH
        public bool _push;					// 推动开关
        public float _pushDistance;				// 触发对障碍物推动的距离
        public float _pushForce = 5.0f;         // 推动力大小

        public Vector3 _wayPoint;

#if UNITY_EDITOR
        public static bool _sWarning;
#endif
        Rigidbody _rigidbody;
        public Rigidbody Rigidbody
        {
            get
            {
                if (_rigidbody == null)
                {
                    _rigidbody = gameObject.AddMissingComponent<Rigidbody>();
                }
                return _rigidbody;
            }
        }

        public override void Init(Fish owner)
        {
            base.Init(owner);

            _cacheTransform = Owner.transform;
            Rigidbody.useGravity = false;
            Rigidbody.constraints = RigidbodyConstraints.FreezeRotationZ;
            Rigidbody.isKinematic = true;
            Rigidbody.drag = 1;

            var renderer = gameObject.GetComponentInChildren<Renderer>();
            if (!renderer.material.IsKeywordEnabled("BOOLEAN_8BEB836A_ON"))
            {
                renderer.material.EnableKeyword("BOOLEAN_8BEB836A_ON");
            }
        }

        private void Start()
        {
            if (Aquarium != null)
            {
                if (_scanner == null)
                {
                    _scanner = new GameObject("Scanner").transform;
                    _scanner.parent = this.transform;
                    _scanner.localRotation = Quaternion.identity;
                    _scanner.localPosition = Vector3.zero;
#if UNITY_EDITOR
                    if (!_sWarning)
                    {
                        Debug.Log("No scanner assigned: creating... (Increase instantiate performance by manually creating a scanner object)");
                        _sWarning = true;
                    }
#endif
                }
                //Rigidbody.position = Aquarium.RandomPosition();

                if (swimState == SwimState.StateInit)
                {
                    StartSwim(true);
                }

                return;
            }
        }

        public void StartFallDown(Vector3 pos)
        {
            Rigidbody.isKinematic = true;
            swimState = SwimState.StateFallOff;
            this.Owner.animator.Play("Fight");

            var targetY = pos.y;
            pos.y = Aquarium.transform.position.y + Aquarium.tankSize.y / 2;
            Rigidbody.position = pos;
            _cacheTransform.position = pos;

            Quaternion targetRotation = Quaternion.Euler(0, Random.Range(0, 180), 0);
            _cacheTransform.rotation = targetRotation;

            Rigidbody.DOMoveY(targetY, Aquarium.fishFallDuration).SetEase(Aquarium.fishFallEase).OnComplete(() =>
            {
                StartSwim(false);
            });

            this.Invoke("TriggerSwim", Aquarium.fishFallDuration / 2);
        }

        public void TriggerSwim()
        {
            this.Owner.animator.SetTrigger("Swim");
        }

        public void StartSwim(bool resetPos)
        {
            swimState = SwimState.StateSwim;
            Rigidbody.isKinematic = false;

            SetRandomWaypoint();

            if (resetPos)
            {
                _speed = _speedRange.SetCurrentRandom() * _speedFactor;

                var vector = _wayPoint - Rigidbody.position;
                Quaternion targetRotation = Quaternion.LookRotation(vector);
                _cacheTransform.rotation = targetRotation;
                Rigidbody.rotation = targetRotation;
                Rigidbody.velocity = _cacheTransform.TransformDirection(Vector3.forward).normalized * _speed;
            }
            else
            {
                _speed = Rigidbody.velocity.magnitude;
            }
        }

        public void StartEscape()
        {
            tParam = 0.0f;
            swimState = SwimState.StateEscape;
        }

        public static float ClampAngle(float angle, float min, float max)
        {
            if (angle < -360) angle += 360.0f;
            if (angle > 360) angle -= 360.0f;
            return Mathf.Clamp(angle, min, max);
        }

        public void ForwardMovement(float deltaTime)
        {
            //_cacheTransform.position += _cacheTransform.TransformDirection(Vector3.forward)*_speed* Aquarium._newDelta;
            //Rigidbody.velocity = _cacheTransform.TransformDirection(Vector3.forward).normalized * _speed;
            //Rigidbody.position += _cacheTransform.TransformDirection(Vector3.forward) * _speed * Aquarium._newDelta;
            var rigidbody = Rigidbody;
            var velocity = rigidbody.velocity;
            _speed = rigidbody.velocity.magnitude;

            // 计算侧向速度
            var localVelocity = _cacheTransform.InverseTransformVector(velocity);
            localVelocity.z = 0;
            // 计算横向阻力
            var dragForceH = -rigidbody.drag * localVelocity * 4;
            rigidbody.AddRelativeForce(dragForceH);

            // 前进推力
            // 目标方向
            var vector = _wayPoint - rigidbody.position;
            // 只有目标在前方时才产生推力
            if (Vector3.Dot(vector, _cacheTransform.forward) > 0)
            {
                float targetSpeed = _targetSpeed;
                Vector3 pushForce;
                if (swimState == SwimState.StateEscape)
                {
                    if (_speed > _escapeSpeed || tParam > 1)
                    {
                        swimState = SwimState.StateSwim;
                    }
                }

                if (swimState == SwimState.StateEscape)
                {
                    targetSpeed = _escapeSpeed;
                }

                pushForce = rigidbody.mass * Vector3.Project(vector.normalized * (targetSpeed * rigidbody.drag), _cacheTransform.forward.normalized);

                tParam += deltaTime;

                if (_speed > targetSpeed)
                {
                    pushForce = -rigidbody.mass * Vector3.Project(vector.normalized * _brake, _cacheTransform.forward);
                }

                rigidbody.AddForce(pushForce);
            }
        }

        public void RotationBasedOnWaypointOrAvoidance(float deltaTime)
        {
            if (!Avoidance(deltaTime))
            {
                var rigidbody = Rigidbody;
                var localRotation = rigidbody.rotation;
                var vector = _wayPoint - rigidbody.position;
                Quaternion targetOrientation = Quaternion.LookRotation(vector);
                float turnSpeed = _turnSpeedWeight.Current;

                Quaternion rotationChange = targetOrientation * Quaternion.Inverse(rigidbody.rotation);

                // Convert to an angle-axis representation.
                rotationChange.ToAngleAxis(out float angle, out Vector3 axis);
                // I can't remember the range of the returned angle, so you might not need this.
                if (angle > 180f)
                    angle -= 360f;
                
                if (Mathf.Abs(angle) < 1)
                {
                    rigidbody.MoveRotation(targetOrientation);
                    return;
                }

                //Debug.Log("AngleAxis " + angle.ToString() + "," + axis.ToString());

                angle *= Mathf.Deg2Rad;

                var angleSpeed = angle / Time.deltaTime / 4;

                if (Mathf.Abs(angleSpeed) > _turnSpeedWeight.Current)
                {
                    angleSpeed = Mathf.Sign(angleSpeed) * _turnSpeedWeight.Current;
                }
                var angularVelocity = axis * angleSpeed;

                //Debug.Log("angularVelocity " + angularVelocity.ToString() + "," + rigidbody.angularVelocity.ToString());
                rigidbody.AddTorque(angularVelocity - rigidbody.angularVelocity, ForceMode.VelocityChange);
            }
        }

        public void RotateScanner(float deltaTime)
        {
            // 扫描器随机旋转
            if (_scan)
            {
                _scanner.rotation = Random.rotation;
                return;
            }
            //Scan slow if pushing
            _scanner.Rotate(new Vector3(150 * deltaTime, 0.0f, 0.0f));
        }

        public bool Avoidance(float deltaTime)
        {
            if (!_avoidance)
            {
                return false;
            }

            RaycastHit hit = new RaycastHit();
            float d = 0.0f;
            Quaternion rx = _cacheTransform.rotation;
            Vector3 ex = _cacheTransform.rotation.eulerAngles;
            Vector3 cacheForward = _cacheTransform.forward;
            Vector3 cacheRight = _cacheTransform.right;
            //Up / Down avoidance
            if (Physics.Raycast(_cacheTransform.position, -Vector3.up + (cacheForward * .1f), out hit, _avoidDistance, _avoidanceMask))
            {
                //Debug.DrawLine(_cacheTransform.position,hit.point);
                d = (_avoidDistance - hit.distance) / _avoidDistance;
                ex.x -= _avoidSpeed * d * deltaTime * (_speed + 1);
                rx.eulerAngles = ex;
                _cacheTransform.rotation = rx;
            }
            if (Physics.Raycast(_cacheTransform.position, Vector3.up + (cacheForward * .1f), out hit, _avoidDistance, _avoidanceMask))
            {
                //Debug.DrawLine(_cacheTransform.position,hit.point);
                d = (_avoidDistance - hit.distance) / _avoidDistance;
                ex.x += _avoidSpeed * d * deltaTime * (_speed + 1);
                rx.eulerAngles = ex;
                _cacheTransform.rotation = rx;
            }

            //Crash avoidance //Checks for obstacles forward
            if (Physics.Raycast(_cacheTransform.position, cacheForward + (cacheRight * Random.Range(-.1f, .1f)), out hit, _stopDistance, _avoidanceMask))
            {
                //					Debug.DrawLine(_cacheTransform.position,hit.point);
                d = (_stopDistance - hit.distance) / _stopDistance;
                ex.y -= _avoidSpeed * d * deltaTime * (_targetSpeed + 3);
                rx.eulerAngles = ex;
                _cacheTransform.rotation = rx;
                _speed -= d * deltaTime * _stopSpeedMultiplier * _speed;
                if (_speed < 0.01f)
                {
                    _speed = 0.01f;
                }
                return true;
            }
            else if (Physics.Raycast(_cacheTransform.position, cacheForward + (cacheRight * (_avoidAngle + _rotateCounterL)), out hit, _avoidDistance, _avoidanceMask))
            {
                //				Debug.DrawLine(_cacheTransform.position,hit.point);
                d = (_avoidDistance - hit.distance) / _avoidDistance;
                _rotateCounterL += .1f;
                ex.y -= _avoidSpeed * d * deltaTime * _rotateCounterL * (_speed + 1);
                rx.eulerAngles = ex;
                _cacheTransform.rotation = rx;
                if (_rotateCounterL > 1.5f)
                    _rotateCounterL = 1.5f;
                _rotateCounterR = 0.0f;
                return true;
            }
            else if (Physics.Raycast(_cacheTransform.position, cacheForward + (cacheRight * -(_avoidAngle + _rotateCounterR)), out hit, _avoidDistance, _avoidanceMask))
            {
                //			Debug.DrawLine(_cacheTransform.position,hit.point);
                d = (_avoidDistance - hit.distance) / _avoidDistance;
                if (hit.point.y < _cacheTransform.position.y)
                {
                    ex.y -= _avoidSpeed * d * deltaTime * (_speed + 1);
                }
                else
                {
                    ex.x += _avoidSpeed * d * deltaTime * (_speed + 1);
                }
                _rotateCounterR += .1f;
                ex.y += _avoidSpeed * d * deltaTime * _rotateCounterR * (_speed + 1);
                rx.eulerAngles = ex;
                _cacheTransform.rotation = rx;
                if (_rotateCounterR > 1.5f)
                    _rotateCounterR = 1.5f;
                _rotateCounterL = 0.0f;
                return true;
            }
            else
            {
                _rotateCounterL = 0.0f;
                _rotateCounterR = 0.0f;
            }
            return false;
        }

        public void FixedUpdate()
        {
            if (this.swimState == SwimState.StateFallOff)
                return;

            var deltaTime = Time.deltaTime;
            CheckForDistanceToWaypoint(deltaTime);
            RotationBasedOnWaypointOrAvoidance(deltaTime);
            ForwardMovement(deltaTime);
            RayCastToPushAwayFromObstacles(deltaTime);
            SetAnimationSpeed();
        }

        public void SetAnimationSpeed()
        {
            //Owner.SetAnimSpeed(this._speed);
            if (swimState == SwimState.StateEscape)
            {
                Owner.SetAnimSpeed(this._escapeSpeed);
            }
            else
            {
                Owner.SetAnimSpeed(this._targetSpeed);
            }
        }

        public void CheckForDistanceToWaypoint(float deltaTime)
        {
            if ((_cacheTransform.position - _wayPoint).magnitude < _waypointDistance || wanderTime > maxWanderTime)
            {
                //Wander(0.0f);   // 创建新路点
                CheckIfThisShouldTriggerNewFlockWaypoint();
                return;
            }

            wanderTime += deltaTime;
        }

        // 使用扫描器推动远离障碍
        public void RayCastToPushAwayFromObstacles(float deltaTime) {
            if(_push){
                RotateScanner(deltaTime);
                RayCastToPushAwayFromObstaclesCheckForCollision(deltaTime);
            }
        }

        public void RayCastToPushAwayFromObstaclesCheckForCollision(float deltaTime) {
            RaycastHit hit = new RaycastHit();
            float d = 0.0f;
            Vector3 cacheForward = _scanner.forward;
            if (Physics.Raycast(_cacheTransform.position, cacheForward, out hit, _pushDistance, _avoidanceMask)){
                FishMoveController s = null;
                s = hit.transform.GetComponent<FishMoveController>();
                d = (_pushDistance - hit.distance)/_pushDistance;	// Equals zero to one. One is close, zero is far	
                if(s != null){
                    _cacheTransform.position -= cacheForward* deltaTime * d*_pushForce;	
                }
                else{
                    _speed -= .01f* deltaTime;
                    if(_speed < .1f)
                    _speed = .1f;
                    _cacheTransform.position -= cacheForward* deltaTime * d * _pushForce * 2;
                    //Tell scanner to rotate slowly
                    _scan = false;
                }					
            }else{
                // 让扫描器随机旋转
                _scan = true;
            }
        }

        public void Wander(float delay)
        {
            Invoke("SetRandomWaypoint", delay);
        }
        public void CheckIfThisShouldTriggerNewFlockWaypoint()
        {
            SetRandomWaypointPosition();
        }

        /// <summary>
        /// 生成随机路点
        /// </summary>
        public void SetRandomWaypointPosition()
        {
            tParam = 0.0f;
            wanderTime = 0;
            _turnSpeedWeight.SetCurrentRandom();
            _targetSpeed = _speedRange.SetCurrentRandom() * _speedFactor;

            if (_targetSpeed < _speedRange.Middle * _speedFactor)
            {
                var dir = _cacheTransform.forward;
                dir.y = 0;
                _wayPoint = _cacheTransform.position + (dir.normalized * 5 + Random.insideUnitSphere).normalized * _targetSpeed * 3;

                if (!Aquarium.IsInAquarium(_wayPoint))
                {
                    _wayPoint = Aquarium.RandomPosition();
                }
            }
            else
            {
                _wayPoint = Aquarium.RandomPosition();
            }
        }
        
        public void SetRandomWaypoint()
        {
            tParam = 0.0f;
            SetRandomWaypointPosition();
        }

#if UNITY_EDITOR
        private void OnDrawGizmos()
        {
            if (Application.isPlaying)
            {
                Gizmos.DrawLine(transform.position, _wayPoint);

                Gizmos.DrawRay(new Ray(Rigidbody.position, Rigidbody.rotation * Vector3.forward * 4));
            }
            //Gizmos.DrawLine(transform.position, transform.position + transform.TransformVector(Vector3.forward * 3));
        }
#endif
    }
}