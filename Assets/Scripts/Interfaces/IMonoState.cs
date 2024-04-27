using System;

namespace LPCFramework
{
    public interface IMonoState
    {        
        void Init();
        
        void Update();

        void FixedUpdate();

        void Destroy();
    }
}
