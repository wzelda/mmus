// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LP/Effect/Add/DisplacementMap" {
Properties {
	[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend Mode", Float) = 1
    [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Float) = 1
	[Enum(UnityEngine.Rendering.CullMode)] _Culling ("Culling", Float) = 0
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("MainTex", 2D) = "white" {}
	_NoiseTex ("Noise Texture (RG)", 2D) = "white" {}
	_MaskTex ("MaskTex !(A)", 2D) = "white" {}
	_ForceX2  ("MainTex Speed X", range (-10,10)) = 0
	_ForceY2  ("MainTex Speed Y", range (-10,10)) = 0
	_HeatTime  ("Noise Speed", range (-10,10)) = 0
	_ForceX  ("Noise X Strength", range (-1,1)) = 0.1
	_ForceY  ("Noise Y Strength", range (-1,1)) = 0.1
	_ForceX3  ("Mask Speed X", range (-10,10)) = 0
	_ForceY3  ("Mask Speed Y", range (-10,10)) = 0
}

Category {
	Tags { "Queue"="Transparent" "RenderType"="Transparent" }
	Blend [_SrcBlend][_DstBlend]
	Cull [_Culling]
	Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
	// BindChannels {
	// 	Bind "Color", color
	// 	Bind "Vertex", vertex
	// 	Bind "TexCoord", texcoord
	// }

	SubShader {
		Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
// #pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"

struct appdata_t {
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float2 texcoord: TEXCOORD0;
	float2 texcoord1: TEXCOORD1;
	float2 texcoord2: TEXCOORD2;
};

struct v2f {
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float2 uvmain : TEXCOORD1;
	float2 uv2 : TEXCOORD2;
	float2 uv3 : TEXCOORD3;
	
};

fixed4 _TintColor;
half _ForceX;
half _ForceY;
half _ForceX2;
half _ForceY2;
half _ForceX3;
half _ForceY3;
float _HeatTime;
float4 _MainTex_ST;
sampler2D _MaskTex;
float4 _MaskTex_ST;
float4 _NoiseTex_ST;
sampler2D _NoiseTex;
sampler2D _MainTex;

v2f vert (appdata_t v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.color = v.color;
	o.uvmain = TRANSFORM_TEX( v.texcoord, _MainTex );
	o.uv2 = TRANSFORM_TEX( v.texcoord1, _NoiseTex );
	o.uv3 = TRANSFORM_TEX( v.texcoord2, _MaskTex );
	return o;
}

half4 frag( v2f i ) : SV_TARGET
{
	//noise effect
	float4 Time = _Time;
	float4 offsetColor1 = tex2D(_NoiseTex, i.uvmain + Time.xz*_HeatTime);
    float4 offsetColor2 = tex2D(_NoiseTex, i.uvmain + Time.yx*_HeatTime);
	i.uvmain.x += ((offsetColor1.r + offsetColor2.r) - 1) * _ForceX;
	i.uvmain.y += ((offsetColor1.r + offsetColor2.r) - 1) * _ForceY;
	// fixed4 MainTex_Var = tex2D( _MainTex, i.uvmain)
	return 2.0f * i.color * _TintColor * tex2D( _MainTex, i.uvmain+float2(Time.y*_ForceX2,Time.y*_ForceY2))*float4(1,1,1,tex2D(_MaskTex,i.uv3+float2(Time.y*_ForceX3,Time.y*_ForceY3)).a);
}
ENDCG
		}
}

}
}
