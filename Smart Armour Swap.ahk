#NoEnv
#SingleInstance force
#Persistent
SetBatchLines, -1
ListLines Off
Process, Priority, , H
SendMode, Input
RunAsAdmin()
HideProcess()

#Include, <ShinsImageScanClass>
#Include, <Helper Functions>
#Include, <Set Resolution>

global debugmode
global WornShield
global ShieldisFull := true
global Thresh := 100
global SwappableShields := []
global White := 0xBFBFBF, Blue := 0x1E8FFD, Gold := 0xFDCB3B, Purple := 0x9E2BFF, Red := 0xFD0202, Grey := 0x4B4B4B, None := 0
global shieldFolder, uiFolder
global scan := new ShinsImageScanClass("")

DetectShieldColor() { ;checks ur shields color
    switch (DetectedResolution) {
        case "1920x1080":
            WornShield := Format("0x{:06X}", scan.GetPixel(183, 1000, 1)) ;checks pixel color at point 183, 1000
        case "1728x1080":
            WornShield := Format("0x{:06X}", scan.GetPixel(163, 1008, 1)) ;checks pixel color at point 163, 1009
        case "1680x1050":
            WornShield := Format("0x{:06X}", scan.GetPixel(159, 980, 1)) ;checks pixel color at point 159, 980
    }
    WornShield := (WornShield = White) ? White : (WornShield = Blue) ? Blue : (WornShield = Gold) ? Gold : (WornShield = Purple) ? Purple : (WornShield = Red) ? Red : None
}

ShieldHealthBelow(threshold) { ;checks ur shields health
    switch (DetectedResolution) {
        case "1920x1080":
            X1 := 177, Y1 := 998, X2 := 407, Y2 := 1003 ;full bar (red or no shield dimensions)
            X2 -= (WornShield = Purple) ? 47 : (WornShield = Blue) ? 93 : (WornShield = White) ? 140 : 0 ;adjusts the full bar length to different shields
        case "1728x1080":
            X1 := 159, Y1 := 1006, X2 := 367, Y2 := 1011 ;full bar (red or no shield dimensions)
            X2 -= (WornShield = Purple) ? 42 : (WornShield = Blue) ? 85 : (WornShield = White) ? 127 : 0 ;adjusts the full bar length to different shields
        case "1680x1050":
            X1 := 155, Y1 := 978, X2 := 355, Y2 := 983 ;full bar (red or no shield dimensions)
            X2 -= (WornShield = Purple) ? 40 : (WornShield = Blue) ? 81 : (WornShield = White) ? 122 : 0 ;adjusts the full bar length to different shields
    }
    Width := (X2 - X1) * (threshold / 100) ;adjusts the bar length to your shields health
    if (debugmode)
        boxdraw(x1, y1, x1+width, y2, "blue")
    return scan.PixelRegion(Grey, X1, Y1, Width, Y2 - Y1, 0)
}

BoxIsOpen() { ;checks if deathbox/loba market is open. if loba market is open it will return false and ignore shield swaps in the market
    switch (DetectedResolution) {
        case "1920x1080":
            if (scan.ImageRegion(uiFolder "\Loba.png", 421, 101, 229, 52, 45))
                return false
            return scan.ImageRegion(uiFolder "\Esc.png", 501, 957, 160, 41, 25)
        case "1728x1080":
            if (scan.ImageRegion(uiFolder "\Loba.png", 367, 140, 217, 54, 45))
                return false
            return scan.ImageRegion(uiFolder "\Esc.png", 446, 918, 151, 33, 25)
        case "1680x1050":
            if (scan.ImageRegion(uiFolder "\Loba.png", 366, 136, 211, 51, 45))
                return false
            return scan.ImageRegion(uiFolder "\Esc.png", 452, 891, 114, 34, 25)
    }  
}
CheckBoxHealth(threshold, x, y) { ;checks the health of the shield in the deathbox. Does the same as ShieldHealthBelow function but for deathbox. Compares your shield to deathbox shield health
    if (WornShield = None) {
        tooltip, none
        return false
    }
    switch (DetectedResolution) {
        case "1920x1080":
            Modifier := (WornShield = White) ? 62 : (WornShield = Blue) ? 94 : (WornShield = Purple) ? 125 : 156
            X1 := x - 2, Y1 := y + 27, X2 := X1 + Modifier, Y2 := Y1 + 6
        case "1728x1080":
            Modifier := (WornShield = White) ? 56 : (WornShield = Blue) ? 86 : (WornShield = Purple) ? 112 : 140
            X1 := x - 2, Y1 := y + 24, X2 := X1 + Modifier, Y2 := Y1 + 7
        case "1680x1050":
            Modifier := (WornShield = White) ? 53 : (WornShield = Blue) ? 81 : (WornShield = Purple) ? 108 : 136
            X1 := x - 2, Y1 := y + 23, X2 := X1 + Modifier, Y2 := Y1 + 7
    }
    Width := (X2 - X1) * (threshold / 100)
    if (debugmode)
        boxdraw(x1, y1, x1+width, y2, "blue")
    return scan.PixelRegion(Grey, X1, Y1, Width, Y2 - Y1, 0)
}

DetermineShieldUpgrade() { ;determines which shield to swap to
    if (BoxIsOpen())
        return
    DetectShieldColor()
    if (WornShield = None) {
        SwappableShields := ["Red", "Purple", "Gold", "Blue", "White"]
        return
    }
    if (ShieldHealthBelow(100)) { ;if ur shield is below 100% it checks the threshold of your shield, sets the threshold to check in CheckBoxHealth function and determines your swap
        ShieldisFull := False
        switch (WornShield) {
            case White:
                Thresh := ShieldHealthBelow(50) ? 50 : 100
                SwappableShields := ["Red", "Purple", "Gold", "Blue", "White"]
            case Blue:
                Thresh := ShieldHealthBelow(33) ? 33 : (ShieldHealthBelow(66) ? (Thresh := 66, "White") : 100)
                SwappableShields := (ShieldHealthBelow(66) || ShieldHealthBelow(33)) ? ["Red", "Purple", "Gold", "Blue", "White"] : ["Red", "Purple", "Gold", "Blue"]
            case Purple, Gold:
                Thresh := ShieldHealthBelow(50) ? 50 : (ShieldHealthBelow(75) ? 75 : 100)
                SwappableShields := (ShieldHealthBelow(50) ? ["Red", "Purple", "Gold", "Blue", "White"] : (ShieldHealthBelow(75) ? ["Red", "Purple", "Gold", "Blue"] : ["Red", "Purple", "Gold"]))
            case Red:
                Thresh := ShieldHealthBelow(40) ? 40 : (ShieldHealthBelow(60) ? 60 : (ShieldHealthBelow(80) ? 80 : 100))
                SwappableShields := (ShieldHealthBelow(40) ? ["Red", "Purple", "Gold", "Blue", "White"] : (ShieldHealthBelow(60) ? ["Red", "Purple", "Gold", "Blue"] : (ShieldHealthBelow(80) ? ["Red", "Purple", "Gold"] : ["Red"])))
        }
        return
    }
    if (!ShieldHealthBelow(100)) { ;if ur shield is 100% it only swaps to a higher shield that has more health than your shield
        ShieldisFull := True
        switch (WornShield) {
            case White:
                SwappableShields := ["Red", "Purple", "Gold", "Blue"]
            case Blue:
                SwappableShields := ["Red", "Purple", "Gold"]
            case Purple, Gold:
                SwappableShields := ["Red"]
            case Red:
                SwappableShields := []
        }
        return
    }
}

SwapArmour() { ;swaps your armour
    if (debugmode)
        Limit := A_TickCount + 50000
    else
        Limit := A_TickCount + 500
    While (A_TickCount < Limit) {
        if (!BoxIsOpen())
            return
        for index, shield in SwappableShields {
            ImagePath := ShieldFolder "\" shield ".png"
            switch (DetectedResolution) {
                case "1920x1080":
                    FoundCount := scan.ImageRegion(ImagePath, 76, 80, 597, 918, 25, X, Y) 
                case "1728x1080":
                    FoundCount := scan.ImageRegion(ImagePath, 68, 129, 538, 825, 25, X, Y)
                case "1680x1050":
                    FoundCount := scan.ImageRegion(ImagePath, 68, 123, 521, 803, 25, X, Y)
            }
            if (FoundCount > 0) {
                BlockInput, ON
                if (CheckBoxHealth(ShieldisFull ? 100 : Thresh, X, Y))
                    return
                Random, ExtraX, -4, 86
                Random, ExtraY, -2, 16
                X += ExtraX, Y += ExtraY
                Click %X%, %Y%
                Sleep, 100
                BlockInput, OFF
                return
            } 
            Sleep, 10
        } 
    }
}

~$*e::DetermineShieldUpgrade()
~$*e Up::
if (BoxIsOpen()) {
    SwapArmour()
    Thresh := 100
} 
return

;0::debug()

debug() {
    debugmode := true
    DetectShieldColor()
    ShieldHealthBelow(100)
    switch (DetectedResolution) {
        case "1920x1080":
        boxdraw(76, 80, 76+597, 80+918, "blue")
        boxdraw(421, 101, 421+229, 101+52, "blue")
        boxdraw(501, 957, 501+160, 957+41, "blue")
        case "1728x1080":
        boxdraw(68, 129, 68+538, 129+825, "blue")
        boxdraw(367, 140, 367+217, 140+54, "blue")
        boxdraw(446, 918, 446+151, 918+33, "blue") 
        case "1680x1050":
        boxdraw(68, 123, 68+521, 123+803, "blue")
        boxdraw(366, 136, 366+211, 136+51, "blue")
        boxdraw(452, 891, 452+114, 891+34, "blue")
    }  

    MsgBox, Wear a white shield. Make sure its an Evo shield and not a Body shield.`nOpen a deathbox with E and scroll down to until you see an armour, once this happens you will see a blue box around the shields health.`nUse this as reference for adding resolution support in the CheckBoxHealth method.`nRepeat for all shields
    Loop {
        if (WornShield != sc)
            DetectShieldColor()
        sc := GetColorName(WornShield)
        MouseGetPos, X, Y
        PixelGetColor, Color, X, Y
        Tooltip, % "X: " X ", Y: " Y "`nColor at cursor: " Color "`nShield Color: " sc " " WornShield
    }
}
end::exitapp


