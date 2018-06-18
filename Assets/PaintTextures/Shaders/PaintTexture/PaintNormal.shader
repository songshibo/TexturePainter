Shader "Paint Texture Shader/PaintNormal"
{
	Properties
	{
		[HideInInspector]
		_MainTex ("Texture", 2D) = "white" {}
		[HideInInspector]
		_Brush ("Brush", 2D) = "white" {}
		[HideInInspector]
		_BrushScale ("Brush Scale", Float) = 0.1
		[HideInInspector]
		_BrushNormal ("Brush Normal", 2D) = "white" {}
		[HideInInspector]
		_PaintUV("Hit point UV", Vector) = (0, 0, 0, 0)
		[HideInInspector]
		_NormalBlend ("Normal Blend", Float) = 1
	}
	SubShader
	{
		CGINCLUDE

        #include "Assets/CgInclude/CustomCGInclude.cginc"

		struct app_data {
			float4 vertex:POSITION;
			float4 uv:TEXCOORD0;
		};

		struct v2f {
			float4 screen:SV_POSITION;
			float4 uv:TEXCOORD0;
		};

		sampler2D _MainTex;
		sampler2D _Brush;
		sampler2D _BrushNormal;
		float4 _PaintUV;
		float _BrushScale;
		float _NormalBlend;

		ENDCG

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			v2f vert (app_data i)
			{
				v2f o;
				o.screen = UnityObjectToClipPos(i.vertex);
				o.uv = i.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float h = _BrushScale;
				float4 base = SampleTexture(_MainTex, i.uv.xy);

				if (IsPaintRange(i.uv.xy, _PaintUV, h))
				{
					float2 uv = CalcBrushUV(i.uv.xy, _PaintUV, h);
					float4 brushColor = SampleTexture(_Brush, uv);
					
					if (brushColor.a > 0)
					{
						float4 normal = SampleTexture(_BrushNormal, uv);
						return NormalBlendUseBrush(base, normal, _NormalBlend, brushColor.a);
					}
				}
				
				return base;
			}
			ENDCG
		}
	}
}
