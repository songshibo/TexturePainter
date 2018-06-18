Shader "Custom/VertexSurface" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo by r", 2D) = "white" {}
        _BumpMap ("Normal by r", 2D) = "normal" {}
        _DispMap ("Height by r", 2D) = "gray" {}

        _MainTex2 ("Albedo2 by g", 2D) = "white" {}
        _BumpMap2 ("Normal2 by g", 2D) = "normal" {}
        _DispMap2 ("Height by g", 2D) = "gray" {}

        _MainTex3 ("Albedo3 by b", 2D) = "white" {}
        _BumpMap3 ("Normal3 by b", 2D) = "normal" {}
        _DispMap3 ("Height by b", 2D) = "gray" {}

        _ControlMap ("ControlMap", 2D) = "white" {}
        _HeightBlend("Height Blend Factor", Range(0.01, 1)) = 0.3
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM

        #include "Assets/CgInclude/CustomCGInclude.cginc"
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows 

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _DispMap;

        sampler2D _MainTex2;
        sampler2D _BumpMap2;
        sampler2D _DispMap2;

        sampler2D _MainTex3;
        sampler2D _BumpMap3;
        sampler2D _DispMap3;

        sampler2D _ControlMap;
        float4 _ControlMap_ST;

		struct Input {
			float2 uv_MainTex;
            float2 uv_BumpMap;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
        float _HeightBlend;
        

		void surf (Input IN, inout SurfaceOutputStandard o) 
        {
            fixed4 c1 = tex2D (_MainTex, IN.uv_MainTex);
			fixed4 c2 = tex2D (_MainTex2, IN.uv_MainTex);
            fixed4 c3 = tex2D (_MainTex3, IN.uv_MainTex);

            fixed3 n1 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            fixed3 n2 = UnpackNormal(tex2D(_BumpMap2, IN.uv_BumpMap));
            fixed3 n3 = UnpackNormal(tex2D(_BumpMap3, IN.uv_BumpMap));

            fixed d1 = tex2D(_DispMap, IN.uv_MainTex).r;
            fixed d2 = tex2D(_DispMap2, IN.uv_MainTex).r;
            fixed d3 = tex2D(_DispMap3, IN.uv_MainTex).r;

            fixed4 control = tex2D(_ControlMap, IN.uv_MainTex);

            fixed3 blend = VertexBlendUseHeight(d1, d2, d3, control, _HeightBlend);
            fixed4 mainColor = c1 * blend.r + c2 * blend.g + c3 * blend.b;
            fixed3 mainNormal = n1 * blend.r + n2 * blend.g + n3 * blend.b;
			o.Albedo = mainColor.rgb;

            o.Normal = mainNormal;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = mainColor.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
