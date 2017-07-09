Shader "Custom/CutPlaneShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader {
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }

		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard alpha:fade
		#pragma target 3.0

		fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
		};
		
		void surf (Input IN, inout SurfaceOutputStandard o) {
			o.Emission = _Color.rgb;
			o.Alpha = _Color.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
