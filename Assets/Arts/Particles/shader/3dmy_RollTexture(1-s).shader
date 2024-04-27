// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LP/Particle/AlphaBlend/FlowUV_NoAmbient" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_Abc("Tint Color Max",range(0,10)) = 1
	_MainTex ("Main Texture", 2D) = "white" {}
	_NoiseTex ("Noise Texture (RG)", 2D) = "white" {}
	_RollTimeX ("Roll Time X", Float) = 0
	_RollTimeY ("Roll Time Y", Float) = 0
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha OneMinusSrcAlpha
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
			half _Abc;
			
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
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texMain = TRANSFORM_TEX(v.texcoord, _MainTex);
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
				return 2.0 * i.color * _TintColor*_Abc * mainColor * offsetColor.a;
			}
			ENDCG
		}
	} 	
}
}