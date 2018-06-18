Shader "Paint Texture Shader/PaintHeight"
{
	Properties
	{
		[HideInInspector]
		_MainTex ("Texture", 2D) = "white" {}
		[HideInInspector]
		_Brush ("Brush", 2D) = "white" {}
		[HideInInspector]
		_BrushHeight ("Brush Height", 2D) = "white" {}
		[HideInInspector]
		_BrushScale ("Brush Scale", Float) = 0.1
		[HideInInspector]
		_PaintUV("Hit UV Position", VECTOR) = (0,0,0,0)
		[HideInInspector]
		_HeightBlend("HeightBlend", FLOAT) = 1
		[HideInInspector]
		_Color("Color", VECTOR) = (0,0,0,0)
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
		sampler2D _BrushHeight;
		float4 _PaintUV;
		float _BrushScale;
		float _HeightBlend;
		float4 _Color;

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
					float4 brushColor = SampleTexture(_Brush, uv.xy);

					if (brushColor.a > 0)
					{
						float4 height = SampleTexture(_BrushHeight, uv);
#ifdef HEIGHT_BLEND_KEYWORD_COLOR_RGB_HEIGHT_A
						height.a = 0.299 * height.r + 0.587 * height.g + 0.114 * height.b;
						height.rgb = _Color.rgb;
						brushColor.a = _Color.a;
#endif
						return HeightBlendUseBrush(base, height, _HeightBlend, brushColor);
					}
				}

				return base;
			}
			ENDCG
		}
	}
}
