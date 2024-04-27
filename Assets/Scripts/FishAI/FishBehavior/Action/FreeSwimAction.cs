using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;
using FishAI;
using LPCFramework;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FishBehavior
{
    /// <summary>
    /// 自由游泳动作
    /// </summary>
    public class FreeSwimAction : Action
    {
        public Fish fishAI;

        public float arriveDistance = 0.1f;

        public float wanderJitter = 0.5f;
        public float wanderRadius = 2f;
        public float wanderDistance = 4f;

        private Vector3 wanderTarget = Vector3.forward;

        public MyRange thinkDuration = new MyRange(0.2f, 5);
        float elapsedTime;

        public override void OnStart()
        {
            elapsedTime = 0;
            fishAI = this.GetComponent<Fish>();
            wanderTarget = Vector3.forward * wanderRadius;
            RandomAct();
        }

        public override TaskStatus OnUpdate()
        {
            if (elapsedTime >= thinkDuration.Current)
            {
                RandomAct();
                elapsedTime = 0;
            }
            elapsedTime += Time.deltaTime;

            return TaskStatus.Running;
        }

        public void RandomAct()
        {
        }
    }

}