// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LP/Particle/Add/FlowUV_RotateUV_Fresnel3" {
Properties {
	_TintColor ("Tint Color", Color) = (1,1,1,1)
	_Abc("Tint Color Max",range(0,10)) = 1
	_MainTex ("Main Texture", 2D) = "white" {}
	_NoiseTex ("Noise Texture (RG)", 2D) = "white" {}
	_RollTimeX ("Roll Time X", Float) = 0.2
	_RollTimeY ("Roll Time Y", Float) = 0
	_Speed ("Rotation", float) = 0
	_Rim_Col ("Rim_Col", Color) = (1,1,1,1)
    _Rim_Intensity ("Rim_Intensity", Range(0, 3)) = 0
    _Rim_Range ("Rim_Range", Range(0, 3)) = 1

}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha One
	Lighting Off
//	Cull Off  ZWrite Off

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
			half _Speed;
		    half _Rim_Intensity;
            fixed4 _Rim_Col;
            half _Rim_Range;
            half4 _MainTex_ST;
			half4 _NoiseTex_ST;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				half3 normal : NORMAL;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				half2 texMain : TEXCOORD0;
				half2 texNoise : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
                half3 normalDir : TEXCOORD3;
			};

			
			v2f vert (appdata_t v)
			{
				
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.color = v.color;
				half ag = _Time.y*_Speed;
				half cosV = cos(ag);
				half sinV = sin(ag);
				o.texMain = v.texcoord.xy - half2(0.5, 0.5) + _MainTex_ST.zw;
				o.texMain = half2(cosV*o.texMain.x - sinV*o.texMain.y, sinV*o.texMain.x + cosV*o.texMain.y)/_MainTex_ST.xy +half2(0.5,0.5) ;
				o.texNoise = TRANSFORM_TEX(v.texcoord, _NoiseTex);

				return o;
			}
			fixed4 frag (v2f i) : COLOR
			{
				
			    i.normalDir = normalize(i.normalDir);
                half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                half3 normalDirection = i.normalDir;
                half2 uvoft = i.texMain;
				uvoft.x += _Time.yx * _RollTimeX;
				uvoft.y += _Time.yx * _RollTimeY;

                fixed4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(uvoft, _MainTex));
                fixed NdotV = dot(i.normalDir,viewDirection);
                fixed4 offsetColor = tex2D(_NoiseTex, i.texNoise);
                fixed3 finalColor = ((2.0 * i.color * _TintColor.rgb *_Abc * _MainTex_var.rgb)+(pow((1.0 - NdotV),_Rim_Range)*_Rim_Intensity*_Rim_Col.rgb));

                return fixed4(finalColor, (offsetColor.a * _MainTex_var.a  * _TintColor.a+pow((1.0 - NdotV),_Rim_Range)*_Rim_Intensity*_Rim_Col.a))* i.color.a;

 
			}
			ENDCG
		}
	} 	
}
}