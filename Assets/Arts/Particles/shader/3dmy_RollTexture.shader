// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LP/Particle/Add/FlowUV_NoAmbient" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_TintCtr ("Light Power", Range(1,10)) = 1
	_MainTex ("Main Texture", 2D) = "white" {}
	_NoiseTex ("Noise Texture (RG)", 2D) = "white" {}
	_RollTimeX ("Roll Time X", Float) = 0.2
	_RollTimeY ("Roll Time Y", Float) = 0
}
	SubShader {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Pass {
            Blend SrcAlpha One
	        Cull Off Lighting Off ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
            #pragma target 3.0

			sampler2D _MainTex;
			sampler2D _NoiseTex;
			fixed _TintCtr;
			float _RollTimeX;
			float _RollTimeY;
			fixed4 _TintColor;
			float4 _MainTex_ST;
			float4 _NoiseTex_ST;
			
			struct a2v {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed4 color : COLOR;
				float2 texMain : TEXCOORD0;
				float2 texNoise : TEXCOORD1;
			};

			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texMain = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.texNoise = TRANSFORM_TEX(v.texcoord, _NoiseTex);
				return o;
			}
			fixed4 frag(v2f i) : SV_Target
			{
				float2 uvoft = i.texMain;
				uvoft.x += _Time.yx * _RollTimeX;
				uvoft.y += _Time.yx * _RollTimeY;
				fixed4 offsetColor = tex2D(_NoiseTex, i.texNoise);
				fixed4 mainColor = tex2D(_MainTex, uvoft);
				return 2.0 * i.color * _TintColor * _TintCtr * mainColor * offsetColor.a;
			}
			ENDCG
		}
	} 	
}