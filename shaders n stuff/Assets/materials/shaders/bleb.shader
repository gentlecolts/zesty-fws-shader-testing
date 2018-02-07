Shader "Custom/bleb" {
	Properties{
		_MainTex("Texture",2D)="white"{}
		_diffuseStrength("Diffuse Strength",Range(0,1))=1
		_k("contrast",Range(-1,1))=1
		_BumpMap("Bumpmap",2D)="bump"{}
		_RimColor ("Rim Color", Color) = (0.26,0.19,0.16,0.0)
		_RimPower ("Rim Power", Range(0.5,8.0)) = 3.0
		_rimStrength("Rim Strength",Range(0,1))=1
		_Cube ("Reflection Map", CUBE) = "" {}
		_reflectiveness("Reflectiveness",Range(0,1))=1
		_blobFreq("Ripple Frequency",Float)=1
		_blobAmp("Ripple Amplitude",Range(0,1))=0.25
		_specShiny("Shinyness",Float)=10
		_specAmount("Specular Amount",Range(0,1))=1
	}
	SubShader{
		Tags{"RenderType"="Opaque"}
		CGPROGRAM
		#pragma surface surf SimpleSpecular vertex:vert fullforwardshadows
		struct Input{
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 viewDir;
			float3 reflCoord;
			float3 worldRefl;
			INTERNAL_DATA
		};

		//define parameters
		sampler2D _MainTex;
		fixed _diffuseStrength;
		float _k;

		sampler2D _BumpMap;
		
		float4 _RimColor;
		float _RimPower;
		float _rimStrength;
		
		samplerCUBE _Cube;
		float _reflectiveness;

		float _blobAmp,_blobFreq;
		float _specAmount,_specShiny;

		//functions here
		half4 LightingSimpleSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
			//diffuse
			const half NdotL = dot (s.Normal, lightDir);
			const half diff = NdotL * 0.5 + 0.5;
			
			//specular
			const half3 h=normalize(lightDir+viewDir);
			const float nh=max(0,dot(s.Normal,h));
			const float spec=pow(nh,_specShiny);
			
			half4 c;
			c.rgb = (s.Albedo*_LightColor0.rgb*diff + _LightColor0.rgb*spec*_specAmount)*atten;
			c.a = s.Alpha;
			return c;
		}

		fixed fn(float x,float k){
			//return x*k;
			float x2=2*x-1;
			x2=x2*k/(1+k-abs(x2));
			return isfinite(x2)?(x2+1)/2:x;
		}
		fixed3 filter(fixed3 rgb,float k){
			k=-1/k;
			rgb.r=fn(rgb.r,k);
			rgb.g=fn(rgb.g,k);
			rgb.b=fn(rgb.b,k);
			return rgb;
		}

		inline fixed4 LightingCustom_Reflect (SurfaceOutput s, fixed3 lightDir, half3 halfasview, fixed atten){
			float4 hdrReflection = 1.0;
			float3 reflectedDir = reflect(halfasview, s.Normal);
			float4 reflection = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflectedDir);
			hdrReflection.rgb = DecodeHDR(reflection, unity_SpecCube0_HDR);
			hdrReflection.a = 1.0;

			float4 c;
			c.rgb = hdrReflection;
			return c;
		}

		//void vert (inout appdata_full v, out Input o) {
		//	UNITY_INITIALIZE_OUTPUT(Input,o);
		//	o.customColor = abs(v.normal);
		//}

		static const float PI = 3.14159;
		static const float toRad=PI/180;

		void vert (inout appdata_full v) {
			float3 offset=v.normal;
			offset.y=0;
			//normalize(offset);
			offset*=_blobAmp*sin(_blobFreq*2*PI*(_Time.y+v.vertex.y));
			v.vertex.xyz += offset;
		}
		
		void surf(Input IN,inout SurfaceOutput o){

			//color and normals
			o.Albedo=filter(tex2D(_MainTex,IN.uv_MainTex+float2(_Time.y/4,0)).rgb,_k)*_diffuseStrength;
			o.Normal=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));

			//rim light
			half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
			fixed3 rimcol=_RimColor.rgb * pow (rim, _RimPower);
			
			//reflection
			fixed3 reflCol=LightingCustom_Reflect(o,o.Normal,IN.viewDir,1);
			
			o.Emission = rimcol*_rimStrength+reflCol*_reflectiveness;
		}
		ENDCG
	}
	Fallback "Diffuse"
}
