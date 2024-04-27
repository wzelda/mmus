using System.Collections;
using System.Collections.Generic;
using FairyGUI;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class SceneFilterTest : MonoBehaviour {
	
	static Image _image;
	static int _width;
	static int _height;
	private static Dictionary<GGraph,RenderTexture> _renderTextureDic = new Dictionary<GGraph, RenderTexture>();

	private static Camera currentCamera;
	
	public static void SetSceneBlur(GGraph holder)
	{
		currentCamera = GetActiveCamera();
		if (currentCamera==null) return;
		
		_width = (int)holder.width;
		_height = (int)holder.height;

		if(_image==null || _image.gameObject==null) _image = new Image();
		if (holder == null)
		{
			Debug.LogError("SceneFilterTest.SetSceneBlur() holder==null");
			return;
		}

		holder.SetNativeObject(_image);


		RenderTexture tempTexture = null;
		if (!_renderTextureDic.ContainsKey(holder))
		{ 
			tempTexture = new RenderTexture(_width, _height, 14, RenderTextureFormat.Default)
			{
				antiAliasing = 1,
				filterMode = FilterMode.Bilinear,
				anisoLevel = 0,
				useMipMap = false
			};
			_renderTextureDic[holder] = tempTexture;
		}
		else
		{
			tempTexture = _renderTextureDic[holder];
		}

		currentCamera.targetTexture = tempTexture;

		_image.texture = new NTexture(tempTexture);
		_image.blendMode = BlendMode.Off;
	}

	public static void CloseBlur()
	{
		if(currentCamera==null) return;
		currentCamera.targetTexture = null;
	}

	/// <summary>
	/// 得到当前处于活跃状态的相机
	/// </summary>
	public static Camera GetActiveCamera()
	{
		Camera result = null;
		if (Camera.main && Camera.main.enabled)
		{
			return Camera.main;
		}
		
		GameObject Permanent = GameObject.Find("PoolManagerRoot/Permanent/");
		if (Permanent)
		{
			Camera temp = Permanent.GetComponentInChildren<Camera>();
			if (temp && temp.enabled)
			{
				return temp;
			}
		}

		GameObject AvatarRoot = GameObject.Find("PoolManagerRoot/Other/ShowAvatarPlatform(Clone)");
		if (AvatarRoot)
		{
			Camera temp = AvatarRoot.GetComponentInChildren<Camera>();
			if (temp && temp.enabled)
			{
				return temp;
			}
		}

		return null;
	}
}
