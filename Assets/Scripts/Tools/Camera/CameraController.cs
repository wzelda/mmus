using UnityEngine;
using System.Collections;
using DG.Tweening;
using DG.Tweening.Plugins.Options;
using DG.Tweening.Core;

///<summary>
///用于手动钓鱼相机跟随
///</summary>
[DisallowMultipleComponent]
public class CameraController : MonoBehaviour {
	private Transform target;		//an Object to lock on to
	private float damping = 6.0f;	//to control the rotation 

    private Quaternion originRotation;
    private Vector3 originAngles;
	private bool lookAt = false;
    private bool revert = false;
	private Transform _myTransform;
    private Camera _camera;
    private TweenerCore<float, float, FloatOptions>  doTween;

    private float _currentTime;
	void Awake() {
		_myTransform = transform;
        _camera = _myTransform.GetComponent<Camera>();
        originRotation = _myTransform.rotation;
        originAngles = _myTransform.eulerAngles;
	}
    
    public void LookAt(Transform tf,float speed)
    {
        target = tf;
        damping = speed;
        lookAt = true;
    }
    public void StopLookAt()
    {
        lookAt = false;
    }
    public Coroutine DelayToDo(float delayTime, System.Action action)
    {
        return StartCoroutine(DelayToInvokeDo(delayTime, action));;
    }

    public  IEnumerator DelayToInvokeDo(float delaySeconds, System.Action action)
    {
        yield return new WaitForSeconds(delaySeconds);
        action();
    }
    public void CameraThrowAction(float anglex,float duration)
    {
        doTween = DOTween.To(() => _myTransform.eulerAngles.x, (v) =>
        {
            var angles = _myTransform.eulerAngles;
            angles.x = v;
            _myTransform.eulerAngles = angles;
        },
        _myTransform.eulerAngles.x - anglex, duration).SetEase(Ease.OutQuart).OnComplete( () => 
        {
            // if(callBack != null)
            // {
            //     callBack();
            // }
            DelayToDo( 0.2f,()=> 
            {
                DOTween.To(() => _myTransform.eulerAngles.x, (v) =>
                {
                    var angles = _myTransform.eulerAngles;
                    angles.x = v;
                    _myTransform.eulerAngles = angles;
                },
                originAngles.x, duration*4).SetEase(Ease.OutQuart);
                }

            );
        });
    }

    public void CameraPullAction(float anglex,float duration)
    {
        doTween = DOTween.To(() => _myTransform.eulerAngles.x, (v) =>
        {
            var angles = _myTransform.eulerAngles;
            angles.x = v;
            _myTransform.eulerAngles = angles;
        },
        _myTransform.eulerAngles.x - anglex, duration).SetEase(Ease.InQuad);
    }

    public void RevertOrigin()
    {
        lookAt = false;
        revert = true;
        if (doTween != null)
        {
            doTween.Kill();
        }
    }
    public void Shake(float time)
    {
        _currentTime = time;
    }
    void UpdateShake()
    {
        if (_currentTime > 0.0f)
        {
            _currentTime -= Time.deltaTime;
            _camera.rect = new Rect(0.04f * (-1.0f + 2.0f * Random.value) * Mathf.Pow(_currentTime, 2), 0.04f * (-1.0f + 2.0f * Random.value) * Mathf.Pow(_currentTime, 2), 1.0f, 1.0f);
        }
    }

	void LateUpdate() {
        if(lookAt && target)
        {
            Quaternion rotation = Quaternion.LookRotation(target.position - _myTransform.position);
            if (damping == 0)
            {
                _myTransform.rotation = rotation;
            }
            else
            {
                _myTransform.rotation = Quaternion.Lerp(_myTransform.rotation, rotation, Time.deltaTime * damping);
            }

        }
		if(revert) {
			_myTransform.rotation = Quaternion.Slerp(_myTransform.rotation, originRotation, Time.deltaTime * damping);
            if (Vector3.Distance(_myTransform.rotation.eulerAngles , originRotation.eulerAngles) <= 0.01f)
            {
                revert = false;
            }
		}
        UpdateShake();
    }

    void OnDestroy()
    {
        if (doTween != null)
        {
            doTween.Kill();
            doTween = null;
        }
    }
}