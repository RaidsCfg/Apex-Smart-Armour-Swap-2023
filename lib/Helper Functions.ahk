RunAsAdmin() {
    Global 0
IfEqual, A_IsAdmin, 1, Return 0

Loop, %0%
    params .= A_Space . %A_Index%

DllCall("shell32\ShellExecute" (A_IsUnicode ? "":"A"),uint,0,str,"RunAs",str,(A_IsCompiled ? A_ScriptFullPath : A_AhkPath),str,(A_IsCompiled ? "": """" . A_ScriptFullPath . """" . A_Space) params,str,A_WorkingDir,int,1)
ExitApp
}

HideProcess() {
if ((A_Is64bitOS=1) && (A_PtrSize!=4)) {
    hMod := DllCall("LoadLibrary", Str, "hyde64.dll", Ptr)
} else {
    MsgBox, Mixed Versions detected!`nOS Version and AHK Version need to be the same (x86 & AHK32 or x64 & AHK64).`n`nScript will now terminate!
    ExitApp
}
if (hMod) {
    hHook := DllCall("SetWindowsHookEx", Int, 5, Ptr, DllCall("GetProcAddress", Ptr, hMod, AStr, "CBProc", ptr), Ptr, hMod, Ptr, 0, Ptr)
    if (!hHook) {
        MsgBox, SetWindowsHookEx failed!`nScript will now terminate!
        ExitApp
    }
} else {
    MsgBox, LoadLibrary failed!`nScript will now terminate!
    ExitApp
}
ToolTip, % "Process Hidden"
Sleep, 1000
tooltip
return
}

BoxDraw(X1:=0, Y1:=0, X2:=0, Y2:=0, colorpick:="white", thickness :=1) {
if (X2 < X1) {
    X1 := X1 
    X2 := X2
}
if (Y2 < Y1) {
    Y1 := Y1
    Y2 := Y2
}
Width := X2 - X1
Height := Y2 - Y1

Gui, New, +E0x00000020 +E0x08000000 -Caption +AlwaysOnTop -LastFound HwndboxHwnd
Gui, Color, %colorpick%
Gui, Show, x%X1% y%Y1% w%Width% h%Height% NA
WinSet, Transparent, 255

AdjustedThickness := thickness 
RegionString := "0-0 " Width "-0 " Width "-" Height " 0-" Height " 0-0 " thickness "-" thickness " " Width-AdjustedThickness "-" thickness " " Width-AdjustedThickness "-" Height-AdjustedThickness " " thickness "-" Height-AdjustedThickness " " thickness "-" thickness

WinSet, Region, % RegionString
}

InArray(img, imglist) {
for _, element in imglist {
    if (img == element)
        return true
}
return false
}

Join(arr, delimiter) {
result := ""
Loop, % arr.MaxIndex()
{
    result .= (A_Index > 1 ? delimiter : "") . arr[A_Index]
}
return result
}

GetColorName(Color) {
    switch (Color) {
        case White:
            return "White"
        case Blue:
            return "Blue"
        case Purple:
            return "Purple"
        case Red:
            return "Red"
        case None:
            return "None"
    }
}

ReleaseStuckKeys() {
    keys := ["W", "A", "S", "D", "E", "F", "G", "Q", "R", "C", "1", "2", "3", "4", "5", "Space", "LShift", "LControl"]
    for index, key in keys {
        if (GetKeyState(key, "P")) {
            Send {Blind}{%key% up}
        }
    }
}
