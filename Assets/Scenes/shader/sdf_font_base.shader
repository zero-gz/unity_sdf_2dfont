Shader "Custom/sdf_font_base"
{
	Properties
	{
		_MainTex("Texture", 2D) = "black" {}
		_DistanceMark("Distance Mark", Range(0,1)) = 0.5
		_SmoothDelta("Smooth Delta", Range(0,1)) = 0.5
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
				float _SmoothDelta;
				float _DistanceMark;

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
					col.a = smoothstep(_DistanceMark - _SmoothDelta, _DistanceMark + _SmoothDelta, distance); // do some anti-aliasing
					col.rgb = lerp(fixed3(0,0,0), fixed3(1,1,1), col.a);
					return col;
				}
				ENDCG
			}
		}
}