using System;

namespace LPCFramework
{
    public interface IState
    {      
        void Enter(params object [] args);
     
        void Exit(params object[] args);
        void Process(params object[] args);        
    }
}
