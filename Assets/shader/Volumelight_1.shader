Shader "myshaders/postsky"
{
	Properties
	{
		_MainTex("_MainTex",2D)="white"{}
		_StepColor("_StepColor",Color)=(1,1,1,1)
		_Depthfloor("_Depthfloor",float)=5
		_Depthupper("_Depthupper",float)=100
		_LightPos("_LightPos",vector)=(0,0,0,0)
		_LightDir("_LightDir",vector)=(0,-1,0,0)
		_LightIntencity("_LightIntencity",float)=1
		_Level("_Level",float)=8
		_BlurTex("_BlurTex",2D)="white"{}
		_LightCol("_LightCol",Color)=(1,1,1,1)
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		struct v2a{
			float2 uv:TEXCOORD0;
			float4 vertex:POSITION;
		};
		struct v2f{
			float2 uv:TEXCOORD0;
			float4 pos:SV_POSITION;
		};
		float4 _StepColor;//颜色阈值
		sampler2D _MainTex;
		sampler2D _BlurTex;
		float4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		float _Depthfloor;//距离阈值
		float _Depthupper;
		float _LightIntencity;
		float4 _LightDir;
		float _Level;
		float4 _LightPos;
		float4 _LightCol;
		v2f vert(v2a v){
			v2f o;
			o.pos=UnityObjectToClipPos(v.vertex);
			o.uv=v.uv;
			#if UNITY_UV_STARTS_AT_TOP
				if(_MainTex_TexelSize.y<0) o.uv.y=1-o.uv.y;
			#endif
			return o;
		}
		float4 frag_1(v2f i):SV_Target{
			float4 col=tex2D(_MainTex,i.uv);
			float linearDepth=LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv));
			float colgray=col.r*0.3+col.g*0.58+col.g*0.1;
			col=float4(colgray,colgray,colgray,1);//这里只保留了灰度信息
			col*=step(_StepColor.r*0.3+_StepColor.g*0.58+_StepColor.b*0.1,colgray)*step(_Depthfloor,linearDepth)*step(linearDepth,_Depthupper);
			return col;			
		}
		float4 frag_2_1(v2f i):SV_Target{
			float4 col=float4(0,0,0,0);
			float2 blur=_LightDir.xy*(_LightPos.xy-i.uv);//*step(0,_LightPos.y-i.uv.y);
			for(float j=0;j<_Level;j++){
				col+=tex2D(_MainTex,i.uv);
				i.uv+=blur;
			}
			col/=_Level;
			return col;
		}
		float4 frag_2_2(v2f i):SV_Target{
			float2 center=_LightPos.xy;
			float2 uv=i.uv-center;
			float4 col=float4(0,0,0,0);
			for(float j=0;j<_Level;j++){
				col+=tex2D(_MainTex,uv*(1-0.01*j)+center);
			}
			col/=_Level;
			return col;
		}
		float4 frag_3(v2f i):SV_Target{
			float4 col=tex2D(_MainTex,i.uv);
			float4 col2=tex2D(_BlurTex,i.uv);
			return col+col2*_LightIntencity*_LightCol;
		}
	ENDCG
	SubShader
	{
		Pass
		{	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_1
			ENDCG
		}
		Pass
		{	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_2_1
			ENDCG
		}
		Pass
		{	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_2_2
			ENDCG
		}
		Pass
		{	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_3
			ENDCG
		}
	}
}
