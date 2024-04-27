using System;
using System.Collections;
using System.Collections.Generic;
using FairyGUI;
using UnityEngine;

public class RepeatUIShaderTool {

	private static Dictionary<string,Shader> shaderMap = new Dictionary<string, Shader>();
	
	public static void Repeat(GObject obj,string shaderName)
	{
		DisplayObject dis = obj.displayObject;
		GameObject g = dis.gameObject;
		Material mat = g.GetComponent<Renderer>().material;

		Shader targetShader = null;
		if (shaderMap.ContainsKey(shaderName))
		{
			targetShader = shaderMap[shaderName];
		}
		else
		{
			targetShader = Shader.Find(shaderName);
			shaderMap[shaderName] = targetShader;
		}
		
		mat.shader = targetShader;
	}
}
