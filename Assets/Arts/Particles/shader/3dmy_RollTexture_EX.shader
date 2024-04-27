// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LP/Particle/Add/FlowUV_RotateUV_NoAmbient" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Main Texture", 2D) = "white" {}
	_NoiseTex ("Noise Texture (RG)", 2D) = "white" {}
	_RollTimeX ("Roll Time X", Float) = 0.2
	_RollTimeY ("Roll Time Y", Float) = 0
	_Angle ("Angle", Float) = 0
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha One
	Cull Off Lighting Off ZWrite Off

	SubShader {
		Pass {

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _NoiseTex;
			half _RollTimeX;
			half _RollTimeY;
			fixed4 _TintColor;

			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				half2 texMain : TEXCOORD0;
				half2 texNoise : TEXCOORD1;
			};
			half4 _MainTex_ST;
			half4 _NoiseTex_ST;

			half _Angle;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				half ag = radians(_Angle);
				half cosV = cos(ag);
				half sinV = sin(ag);
				o.texMain = v.texcoord.xy - half2(0.5, 0.5) + _MainTex_ST.zw;
				o.texMain = half2(cosV*o.texMain.x - sinV*o.texMain.y, sinV*o.texMain.x + cosV*o.texMain.y)/_MainTex_ST.xy +half2(0.5,0.5) ;
				o.texNoise = TRANSFORM_TEX(v.texcoord, _NoiseTex);
				return o;
			}
			fixed4 frag (v2f i) : COLOR
			{
				half2 uvoft = i.texMain;
				uvoft.x += _Time.yx * _RollTimeX;
				uvoft.y += _Time.yx * _RollTimeY;
				fixed4 offsetColor = tex2D(_NoiseTex, i.texNoise);
				fixed4 mainColor = tex2D(_MainTex, uvoft);
				return 2.0 * i.color * _TintColor * mainColor * offsetColor.a;
			}
			ENDCG
		}
	}
}
}