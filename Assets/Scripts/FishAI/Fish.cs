using UnityEngine;

namespace FishAI
{
    public class Fish : MonoBehaviour
    {
        [HideInInspector]
        public Aquarium aquarium;
        public FishMoveController moveController;
        public Animator animator;
        public Animation _animation;

        public float _minAnimationSpeed = 2.0f;
        public float _maxAnimationSpeed = 4.0f;

        private void Awake()
        {
            InitController(ref moveController);
        }

        private void OnEnable()
        {
            if (aquarium == null)
            {
                aquarium = FindObjectOfType<Aquarium>();
            }
            if (animator == null)
            {
                animator = GetComponentInChildren<Animator>();
            }
            if (_animation == null)
            {
                _animation = GetComponentInChildren<Animation>();
            }
        }

        private void InitController<T>(ref T controller) where T : AFishController
        {
            if (controller == null)
            {
                controller = GetComponent<T>();
                if (controller == null)
                {
                    controller = gameObject.AddComponent<T>();
                }
            }
            controller.Init(this);
        }

        public void SetAnimSpeed(float speed)
        {
            if (animator != null)
            {
                animator.SetFloat("Speed", Mathf.InverseLerp(_minAnimationSpeed, _maxAnimationSpeed, speed));
            }

            if (_animation != null)
            {
                foreach (AnimationState state in _animation)
                {
                    state.speed = 1;
                }
            }
        }
    }
}
