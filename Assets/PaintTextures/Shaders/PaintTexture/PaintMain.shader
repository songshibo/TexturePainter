Shader "Paint Texture Shader/PaintMain"
{
	Properties
	{
		[HideInInspector]
		_MainTex ("Texture", 2D) = "white" {}
		[HideInInspector]
		_Brush("Brush", 2D) = "white" {}
		[HideInInspector]
		_BrushScale("BrushScale", Float) = 0.1
		[HideInInspector]
		_ControlColor("ControlColor", Vector) = (0, 0, 0, 0)
		[HideInInspector]
		_PaintUV("Hit point UV", Vector) = (0, 0, 0, 0)
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
		float4 _PaintUV;
		float _BrushScale;
		float4 _ControlColor;

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
				float4 brushColor;

				if (IsPaintRange(i.uv.xy, _PaintUV, h))
				{
					float2 uv = CalcBrushUV(i.uv.xy, _PaintUV, h);
					brushColor = SampleTexture(_Brush, uv.xy);

					return ColorBlendUseControl(base, brushColor, _ControlColor);
				}
				return base;
			}
			ENDCG
		}
	}
}
