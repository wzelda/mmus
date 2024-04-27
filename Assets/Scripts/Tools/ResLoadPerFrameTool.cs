using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace  LPCFramework
{
	//隔帧加载资源
	[LuaCallCSharp]
	public class ResLoadPerFrameTool {
		static List<Coroutine> tempCo = new List<Coroutine>();
		public static void DoActionByPerFrame(System.Action[] acs){
			Coroutine co = LuaManager.Instance.StartCoroutine(StartDoAction(acs));
			tempCo.Add(co);
		}

		public static void StopAtionByPerFrame(){
			for(int i = 0;i<tempCo.Count;i++){
				LuaManager.Instance.StopCoroutine(tempCo[i]);
			}
			tempCo.Clear();
		}
		static IEnumerator StartDoAction(System.Action[] acs){
			for(int i = 0; i<acs.Length; i++){
				if(acs[i] != null){
					acs[i]();
				}
				yield return null;
			}
			yield return null;
			acs = null;
		}

		
	}
}