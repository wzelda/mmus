
using LPCFramework;
using UnityEngine;

public class FollowTarget : MonoBehaviour
{
    public Transform target;

    Transform _cachedTransform;
    Transform cachedTransform
    {
        get {
            if (_cachedTransform == null)
            {
                _cachedTransform = transform;
            }
            return _cachedTransform;
        }
    }

    public void Update()
    {
        cachedTransform.position = target.position;
    }

    public static void AddFollowTarget(Transform self, Transform target)
    {
        var follow = self.gameObject.AddComponentIfNotExist<FollowTarget>();
        follow._cachedTransform = self;
        follow.target = target;
        follow.Update();
    }
}