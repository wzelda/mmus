Shader "Jay/Caustics"
{
    Properties
    {
		[NoScaleOffset] _CausticTex 	("    Caustics (R) Noise (GB)", 2D) = "black" {}
		_CausticsTiling 				("    Tiling", Float) = 1
		_CausticsScale 					("    Scale", Range(0, 8)) = 2
		_CausticsSpeed 	 				("    Speed", Float) = 0.9
		_CausticsSelfDistortion 		("    Distortion", Float) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue"="Transparent"
        "RenderPipeline" = "UniversalPipeline"
         }

        Pass
        {   
            // Name "TestPass"
            Blend SrcAlpha OneMinusSrcAlpha
            Zwrite off
            Ztest on
            
            Tags {
                // "LightMode" = "Diss"
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"

            CBUFFER_START(UnityPerMaterial)
            half4 _CausticTex_ST;
            half    _CausticsScale;
            half    _CausticsSpeed;
            half    _CausticsTiling;
            half    _CausticsSelfDistortion;
            CBUFFER_END
            TEXTURE2D(_CausticTex);
            SAMPLER(sampler_CausticTex);



            struct Attributes {
            
                float4 positionOS : POSITION;
                float2 uv :TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings {
            
                float4 vertex : SV_POSITION;
                float2 uv :TEXCOORD0;
                // float3 worldPos : TEXCOORD1;
                // float3 worldNormal :TEXCOORD2;
                float3 positionWS :TEXCOORD1;
                float3 normalWS : NORMAL;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv,_CausticTex);
                output.positionWS = TransformObjectToWorld(input.positionOS);//TransformObjectToWorld(input.positionOS.xyz)
                output.normalWS = normalize(TransformObjectToWorldNormal(input.normalOS));
                output.vertex = vertexInput.positionCS;
                return output;
            }

            half4 frag(Varyings input) : SV_TARGET  {
                half3 worldNormal = input.normalWS;
                float CausticsTime = _Time.x * _CausticsSpeed;
                float2 cTexUV = input.positionWS.xz * _CausticsTiling ;      
                half4 causticsSample = SAMPLE_TEXTURE2D(_CausticTex, sampler_CausticTex,cTexUV + CausticsTime.xx );
                causticsSample += SAMPLE_TEXTURE2D(_CausticTex,sampler_CausticTex, cTexUV * 0.78 + float2(-CausticsTime, -CausticsTime * 0.87)  + causticsSample.gb * _CausticsSelfDistortion );
                causticsSample += SAMPLE_TEXTURE2D(_CausticTex, sampler_CausticTex,cTexUV * 1.13 + float2(CausticsTime, 0.36)  - causticsSample.gb * _CausticsSelfDistortion );
                causticsSample = causticsSample.r*_CausticsScale ;
                return half4 (saturate(causticsSample.rgb*(worldNormal.g*0.8+0.2)),1);
            }
            ENDHLSL
        }
        
    }
}
