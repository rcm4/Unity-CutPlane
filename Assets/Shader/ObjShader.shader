Shader "Custom/Obj Shader" {

	Properties{
		_ColorExt("External color", Color) = (1.0, 1.0, 1.0, 1.0)
		_ColorInt("Internal color", Color) = (1.0, 1.0, 1.0, 1.0)
		_EdgeWidth("Edge width", Range(0.99, 0.5)) = 0.9

		[HideInInspector]_PlaneCenter("Plane Center", vector) = (0, 0, 0, 1)
		[HideInInspector]_PlaneNormal("Plane Normal", vector) = (0, 0, -1, 0)
	}

	CGINCLUDE

	float4 _PlaneCenter;
	float4 _PlaneNormal;

	float Distance2Plane(float3 pt) {

		float3 n = _PlaneNormal.xyz;
		float3 pt2 = _PlaneCenter.xyz;

		float d = (n.x*(pt.x - pt2.x)) + (n.y*(pt.y - pt2.y)) + (n.z*(pt.z - pt2.z)) / sqrt(n.x*n.x + n.y*n.y + n.z*n.z);

		return d;
	}

	ENDCG

	SubShader{
		Tags{ "Queue" = "Geometry" }

		//  Pass 1
		Pass{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f {
				float4 pos : SV_POSITION;
				float4 worldPos : TEXCOORD0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 _ColorExt;

			fixed4 frag(v2f i) : SV_Target{
				clip(-Distance2Plane(i.worldPos.xyz));

				return _ColorExt;
			}
			ENDCG
		}

		//  Pass 2
		Pass{

			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f {
				float4 pos : SV_POSITION;
				float4 worldPos : TEXCOORD0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 _ColorInt;

			fixed4 frag(v2f i) : SV_Target{
				clip(-Distance2Plane(i.worldPos.xyz));

				return _ColorInt;
			}
			ENDCG
		}

		//  PASS 3
		Pass{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f {
				float4 pos : SV_POSITION;
				float4 worldPos : TEXCOORD0;
			};

			fixed4 _ColorInt;
			float _EdgeWidth;

			v2f vert(appdata_base v)
			{
				v2f o;
				v.vertex.xyz *= _EdgeWidth;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}		

			fixed4 frag(v2f i) : SV_Target{
				clip(-Distance2Plane(i.worldPos.xyz));

				return _ColorInt;
			}
			ENDCG
		}

		//  PASS 4 
		Pass{

			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2g {
				float4 pos : SV_POSITION;
				float4 worldPos : TEXCOORD0;
			};

			struct g2f {
				float4 pos : SV_POSITION;
				float4 worldPos : TEXCOORD0;
				float3 bary : TEXCOORD1;
			};

			fixed4 _ColorInt;
			fixed4 _ColorExt;

			float _EdgeWidth;

			v2g vert(appdata_base v)
			{
				v2g o;
				v.vertex.xyz *= _EdgeWidth;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			[maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream) {
                float3 param = float3(0., 0., 0.);
 
                float edge1 = length(IN[0].worldPos - IN[1].worldPos);
                float edge2 = length(IN[1].worldPos - IN[2].worldPos);
                float edge3 = length(IN[2].worldPos - IN[0].worldPos);
               
                if(edge1 > edge2 && edge1 > edge3)
                    param.y = 1.;
                else if (edge2 > edge3 && edge2 > edge1)
                    param.x = 1.;
                else
                    param.z = 1.;
 
                g2f o;
                o.pos = mul(UNITY_MATRIX_VP, IN[0].worldPos);
                o.bary = float3(1., 0., 0.) + param;
				o.worldPos = IN[0].worldPos;
                triStream.Append(o);

                o.pos = mul(UNITY_MATRIX_VP, IN[1].worldPos);
                o.bary = float3(0., 0., 1.) + param;
				o.worldPos = IN[1].worldPos;
                triStream.Append(o);

                o.pos = mul(UNITY_MATRIX_VP, IN[2].worldPos);
                o.bary = float3(0., 1., 0.) + param;
				o.worldPos = IN[2].worldPos;
                triStream.Append(o);
            }

			fixed4 frag(g2f i) : SV_Target{
				clip(-Distance2Plane(i.worldPos.xyz));

				float minBary = min(min(i.bary.x, i.bary.y), i.bary.z);
				float maxBary = max(max(i.bary.x, i.bary.y), i.bary.z);

				if (minBary >=  (1 - _EdgeWidth))
					return _ColorExt;
							
				return _ColorInt;
			}

		ENDCG
		}
	}
}