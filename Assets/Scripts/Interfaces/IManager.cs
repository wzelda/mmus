using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace LPCFramework
{
    public interface IManager
    {
        void OnInitialize();
        void OnUpdate();
        void OnDestruct();
    }
}