Shader "LP/Opacity/Unlit_VertexColor" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
	}
	SubShader {
		
		Pass {
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _MainTex_ST;
			
			struct a2v {
				float4 vertex : POSITION;
				half4 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv1: TEXCOORD0;
				fixed4 color : COLOR;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.color = v.color;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv1 = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {  
				fixed4 Col = tex2D(_MainTex, i.uv1);
				fixed4 finalCol =Col*i.color;
				return finalCol;
			}
			ENDCG
		}
	} 
}
