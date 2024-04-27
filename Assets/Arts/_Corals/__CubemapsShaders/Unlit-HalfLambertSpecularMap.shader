Shader "LP/Opacity/Fish"{
    Properties {
        _TineCol ("Tine Col", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _specCol ("spec Col", Color) = (0.5,0.5,0.5,1)
        _specPow ("spec Pow", Range(0, 30)) = 0
        _SpecScla ("Spec Scla", Range(0, 2)) = 1
        _CubeMap ("Cube Map", Cube) = "_Skybox" {}
        _CubePower ("Cube Power", Range(0, 1)) = 0
        _Fresnel ("Fresnel", Range(0, 5)) = 2
        _Fresnel_Power ("Fresnel_Power", Range(0, 3)) = 1
        _FresnelCol ("Fresnel Col", Color) = (0.5,0.5,0.5,1)
        _AmbientSwitch("AmbientSwitch", Range(0, 1)) = 0

        [NoScaleOffset] _CausticTex 	("    Caustics (R) Noise (GB)", 2D) = "black" {}
		_CausticsTiling 				("    Tiling", Float) = 1
		_CausticsScale 					("    Scale", Range(0, 8)) = 2
		_CausticsSpeed 	 				("    Speed", Float) = 0.9
		_CausticsSelfDistortion 		("    Distortion", Float) = 0.2
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        Pass {
            // Blend SrcAlpha OneMinusSrcAlpha
		    // ZWrite On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex; 
            half4 _MainTex_ST;
            half _specPow;
            samplerCUBE _CubeMap;
            half _SpecScla;
            half _Fresnel;
            half _Fresnel_Power;
            fixed4 _specCol;
            half _CubePower;
            sampler2D _NormalMap; 
            half4 _NormalMap_ST;
            fixed4 _TineCol;
            fixed4 _FresnelCol;
            fixed _AmbientSwitch;

            sampler2D _CausticTex;
            half    _CausticsScale;
            half    _CausticsSpeed;
            half    _CausticsTiling;
            half    _CausticsSelfDistortion;
 

            struct VertexInput {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half4 tangent : TANGENT;
                half2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                half4 pos : SV_POSITION;
                half2 uv0 : TEXCOORD0;
                half4 posWorld : TEXCOORD1;
                half3 normalDir : TEXCOORD2;
                half3 tangentDir : TEXCOORD3;
                half3 bitangentDir : TEXCOORD4;
                fixed3 lightDirection : TEXCOORD5;
                fixed3 halfDirection : TEXCOORD6;
                fixed3 viewDirection : TEXCOORD7;
                float3 worldNormal :TEXCOORD8;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, half4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                o.halfDirection = normalize(o.viewDirection+o.lightDirection);
                return o;
            }
            fixed4 frag(VertexOutput i) : SV_Target {
                i.normalDir = normalize(i.normalDir);
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                half3x3 tangentTransform = half3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                half3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                half3 normalLocal = UnpackNormal(tex2D(_NormalMap,TRANSFORM_TEX(i.uv0, _NormalMap)));
                half3 normalDirection = normalize(mul( normalLocal, tangentTransform ));
                half3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                half3 halfDirection = normalize(viewDirection+i.lightDirection);
                fixed4 CubeMap = texCUBE(_CubeMap,viewReflectDirection);
                half specPow = exp2( _SpecScla * 10.0 + 1.0 );
                fixed3 specularColor = _specPow*_specCol.rgb;
                fixed3 specular =  pow(max(0,dot(normalDirection,i.halfDirection)),specPow)*specularColor;
                fixed3 diffuse = max(0,dot(normalDirection,i.lightDirection))*0.2+0.8;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed4 MainTex = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex))*_TineCol;
                 diffuse *=  MainTex.rgb;
                fixed3 emissive = ( CubeMap.rgb*_CubePower*(pow(1.0-max(0,dot(normalDirection, viewDirection)),_Fresnel)*_Fresnel_Power*_FresnelCol.rgb));
                fixed3 finalColor = (diffuse + specular + emissive)*(lerp(ambient*0.7+0.3,1,_AmbientSwitch));


                half3 worldNormal = normalize(i.worldNormal);
                float CausticsTime = _Time.x * _CausticsSpeed;
                float2 cTexUV = i.posWorld.xz * _CausticsTiling ;      
                fixed4 causticsSample = tex2D(_CausticTex, cTexUV + CausticsTime.xx );
                causticsSample += tex2D(_CausticTex, cTexUV * 0.78 + float2(-CausticsTime, -CausticsTime * 0.87)  + causticsSample.gb * _CausticsSelfDistortion );
                causticsSample += tex2D(_CausticTex, cTexUV * 1.13 + float2(CausticsTime, 0.36)  - causticsSample.gb * _CausticsSelfDistortion );
                causticsSample = causticsSample.r*_CausticsScale ;



                return fixed4(finalColor+saturate(causticsSample*causticsSample*(worldNormal.g*0.8+0.2)),1);
            }
            ENDCG
        }
    }
}
