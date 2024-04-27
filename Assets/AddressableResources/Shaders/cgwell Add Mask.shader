Shader "LP/Particle/Add/1_Tex_2_Alpha" 
{
	Properties 
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_Mask ("Mask ( R Channel )", 2D) = "white" {}
	}

	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha One
		Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
	
		SubShader 
		{
			Pass 
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				sampler2D _Mask;
				fixed4 _TintColor;
			
				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					half2 texcoord : TEXCOORD0;
				};

				struct v2f 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					half2 texcoord : TEXCOORD0;
					half2 texcoordMask : TEXCOORD1;
				};
			
				half4 _MainTex_ST;
				half4 _Mask_ST;


				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = mul(UNITY_MATRIX_VP,v.vertex);
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					o.texcoordMask = TRANSFORM_TEX(v.texcoord,_Mask);
					return o;
				}
			
				fixed4 frag (v2f i) : SV_Target
				{
				    fixed4 c = tex2D(_MainTex, i.texcoord);
					c.a *= tex2D(_Mask, i.texcoordMask).r;
					return 2.0f * i.color * _TintColor * c;
				}
				ENDCG 
			}
		}
	}
}
