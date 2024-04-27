using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenBlit : MonoBehaviour
{

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination);
    }
}
