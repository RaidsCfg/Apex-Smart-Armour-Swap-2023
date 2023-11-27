Resolution1 := "1920x1080"
Resolution2 := "1728x1080"
Resolution3 := "1680x1050"
global DetectedResolution := ""

switch (A_ScreenWidth . "x" . A_ScreenHeight) {
    case "1920x1080":
        DetectedResolution := Resolution1
    case "1728x1080":
        DetectedResolution := Resolution2
    case "1680x1050":
        DetectedResolution := Resolution3
    default:
        MsgBox, The current resolution is not supported.
	ExitApp
}

switch (DetectedResolution) {
    case "1920x1080":
        shieldFolder := A_scriptDir "\data\shields\1920"
        uiFolder := A_scriptDir "\data\ui\1920"
    case "1728x1080":
        shieldFolder := A_scriptDir "\data\shields\1728"
        uiFolder := A_scriptDir "\data\ui\1728"
    case "1680x1050":
        shieldFolder := A_scriptDir "\data\shields\1680"
        uiFolder := A_scriptDir "\data\ui\1680"
    default:
        MsgBox, The current resolution is not supported. Exiting script.
        ExitApp
}
