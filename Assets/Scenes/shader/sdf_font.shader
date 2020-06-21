Shader "Custom/sdf_font"
{
	Properties
	{
		_MainTex("Texture", 2D) = "black" {}
		_DistanceMark("Distance Mark", Range(0,1)) = 0.5

		_clip_alpha("clip alpha", Range(0, 1)) = 0.01
		_face_delta("face delta", Range(0,1)) = 0.1
		_outer_delta("outer delta", Range(0,1)) = 0.1
		_inner_delta("inner delta", Range(0,1)) = 0.1
		_back_color("back color", Color) = (0.0, 0.0, 0.0, 0.0)
		_face_color("face color", Color) = (1.0, 1.0, 1.0, 1.0)
		_outer_face_color("outer face color", Color) = (1.0, 1.0, 1.0, 1.0)
		_inner_face_color("inner face color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _DistanceMark;

				float _clip_alpha;
				float _face_delta;
				float _outer_delta;
				float _inner_delta;
				float4 _back_color;
				float4 _face_color;
				float4 _outer_face_color;
				float4 _inner_face_color;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col;
					fixed4 sdf = tex2D(_MainTex, i.uv);
					float distance = sdf.a;

					float alpha = 0.0f;
					float3 color = _back_color;
					if (distance < _DistanceMark && (distance >= _DistanceMark - _outer_delta) )
					{
						alpha = smoothstep(_DistanceMark - _outer_delta, _DistanceMark, distance);
						color = lerp(_outer_face_color, _face_color, alpha);
					}

					if (distance >= _DistanceMark && distance <= _DistanceMark + _face_delta)
					{
						alpha = distance;
						color = _face_color;
					}

					if (distance > _DistanceMark + _face_delta)
					{
						alpha = smoothstep(_DistanceMark + _face_delta, _DistanceMark + _face_delta + _inner_delta, distance);
						color = lerp(_face_color, _inner_face_color, alpha);
					}

					clip(alpha- _clip_alpha);
					col = float4(color, 1.0f);
					return col;
				}
				ENDCG
			}
		}
}