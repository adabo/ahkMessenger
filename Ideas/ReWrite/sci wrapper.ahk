class sci{
	__New(hwnd,x=0,y=0,w=500,h=500){
		Static ScintillaIndex:=0
		if !DllCall("GetModuleHandle","str","SciLexer.dll")
		this.hwnd:=DllCall("LoadLibrary","str","SciLexer.dll")
		this.hwnd:=DllCall("CreateWindowEx" ,"int",0x200 ,"str","Scintilla"
		,"str","Scintilla" . ++ScintillaIndex ,"int", 0x52310000
		,"int",X ,"int",Y ,"int",W ,"int",H ,"uint",hwnd
		,"uint",0 ,"uint",0 ,"uint",0)
		sci.hk({this:this,hwnd:this.hwnd})
		this.fn:=DllCall("SendMessageA","UInt",this.hwnd,"int",2184,int,0,int,0)
		this.ptr:=DllCall("SendMessageA","UInt",this.hwnd,"int",2185,int,0,int,0)
	}
	hk(hwnd=""){
		static keep:=[]
		if IsObject(hwnd)
		return keep[hwnd.hwnd]:=hwnd.this
		if hwnd
		return keep[hwnd]
		return keep
	}
	gettext(a*){
		f:=sci.hk(a.1)
		VarSetCapacity(text,f.2182),f.2182(f.2182,&text)
		return strget(&text,length,utf-16)
	}
	__Call(a="",b="",c="",d=""){
		f:=sci.hk(this.hwnd)
		if (a="gettextrange"){
			VarSetCapacity(text,abs(b-c)),VarSetCapacity(textrange,12,0),NumPut(b,textrange,0,"UInt"),NumPut(c,textrange,4,"UInt"),NumPut(&text,textrange,8,"UInt")
			f.2162(0,&textrange)
			rv:=strget(&text,abs(b-c),"cp0")
			return rv
		}
		if (a="gettext"){
			VarSetCapacity(text,f.2182),f.2182(f.2182,&text)
			return strget(&text,length,utf-16)
		}
		if (a="loop"){
			lp:=(c+1)!=""?"Int":"AStr",wp:=(d+1)!=""?"Int":"AStr"
			return DllCall(this.fn,"Ptr",this.ptr,"UInt",b,lp,c,wp,d,"Cdecl")
		}
		lp:=(b+1)!=""?"Int":"AStr",wp:=(c+1)!=""?"Int":"AStr"
		return DllCall(this.fn,"Ptr",this.ptr,"UInt",a,lp,b,wp,c,"Cdecl")
	}
	__Get(a*){
		return DllCall(this.fn,"Ptr",this.ptr,"UInt",a.1,"Int",0,"Int",0,"Cdecl")
	}
}