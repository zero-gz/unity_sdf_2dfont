Shader "Custom/sdf_light_font"
{
	Properties
	{
		_MainTex("Texture", 2D) = "black" {}
		_DistanceMark("Distance Mark", Range(0,1)) = 0.5
		_SmoothDelta("Smooth Delta", Range(0,1)) = 0.1
		_albedo_tex("albedo texture", 2D) = "white"{}
		_normal_tex("normal texture", 2D) = "bump"{}
		_normal_intensity("normal intensity", Range(0, 2)) = 1.0

		_clip_alpha("clip alpha", Range(0,1)) = 0.01
		_gloss("gloss", Float) = 32.0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Pass
			{
				Tags {"LightMode" = "ForwardBase"}
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float3 world_pos: TEXCOORD1;
					float3 world_normal: TEXCOORD2;
					float3 world_tangent: TEXCOORD3;
					float3 world_binnormal: TEXCOORD4;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				
				float _SmoothDelta;
				float _DistanceMark;
				float _gloss;
				float _clip_alpha;
				float _normal_intensity;

				sampler2D _albedo_tex;
				sampler2D _normal_tex;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);

					o.world_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
					o.world_normal = mul(v.normal.xyz, (float3x3)unity_WorldToObject);
					o.world_tangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
					o.world_binnormal = cross(o.world_normal, o.world_tangent)*v.tangent.w;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col;
					fixed4 sdf = tex2D(_MainTex, i.uv);

					float3 normal_color = tex2D(_normal_tex, i.uv).rgb;
					float3 normal = normal_color * 2.0 - 1.0;
					normal = float3(normal.x*_normal_intensity, normal.y*_normal_intensity, normal.z);
					normal.z = sqrt(1.0 - normal.x*normal.x - normal.y*normal.y);

					float3 N = normalize(normalize(i.world_tangent) * normal.x + normalize(i.world_binnormal) * normal.y + normalize(i.world_normal) * normal.z);
					float3 V = normalize(_WorldSpaceCameraPos.xyz - i.world_pos.xyz);
					float3 L = normalize(_WorldSpaceLightPos0.xyz);
					float3 H = normalize(V + L);
					float3 light_color = _LightColor0.rgb;

					float3 diffuse_color = tex2D(_albedo_tex, i.uv).rgb;
					float3 diffuse = light_color * diffuse_color*max(dot(N, L), 0.0);
					float3 specular = light_color * pow(max(dot(H, N), 0.0), _gloss);
					float3 result_color = diffuse + specular;

					float distance = sdf.a;
					col.a = smoothstep(_DistanceMark - _SmoothDelta, _DistanceMark + _SmoothDelta, distance); // do some anti-aliasing
					col.rgb = lerp(fixed3(0,0,0), fixed3(1,1,1), col.a)*result_color;

					clip(col.a - _clip_alpha);
					return col;
				}
				ENDCG
			}

			Pass {
			Tags { "LightMode" = "ShadowCaster" }

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "AutoLight.cginc"

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
				float _clip_alpha;

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
					clip(col.a - _clip_alpha);
					return float4(1.0, 1.0, 1.0, 1.0);
				}
				ENDCG
		}
		}
}