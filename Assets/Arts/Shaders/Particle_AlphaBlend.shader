﻿Shader "LP/Particle/AlphaBlend/Unlit" {
Properties {
    _TintColor ("Tint Color", Color) = (1,1,1,1)
    _MainTex ("Particle Texture", 2D) = "white" {}
}

Category {
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
    Blend SrcAlpha OneMinusSrcAlpha
    Cull Off Lighting Off ZWrite Off

    SubShader {
        Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _TintColor;
            half4 _MainTex_ST;

            struct appdata_t {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                half2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
                half2 texcoord : TEXCOORD0;
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos( v.vertex );
                o.color = v.color * _TintColor;
                o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = 2.0 * i.color * tex2D(_MainTex, i.texcoord);
                col.a = saturate(col.a); 
                return col;
            }
            ENDCG
        }
    }
}
}
