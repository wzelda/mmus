using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace FishAI
{
    public abstract class AFishController : MonoBehaviour
    {
        public Fish Owner { get; set; }
        public Aquarium Aquarium {
            get {
                return Owner.aquarium;
            }
        }

        public virtual void Init(Fish owner)
        {
            this.Owner = owner;
        }
    }
}
