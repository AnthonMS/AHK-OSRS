#Requires AutoHotkey v2.0


MyTip(str:="Tooltip yo!", ms:=2500) {
    ToolTip(str)
    SetTimer(RemoveTooltip, ms)
}

RemoveTooltip() {
    Tooltip  ; Remove the tooltip
}
QuickSleep() {
    Sleep(Random(100, 250))
}

ExtractCoords(var) {
    ; Accepts a string like "123,234"
    if (RegExMatch(var, "(\d+),(\d+)", &matches)) {
        x := matches[1]  
        y := matches[2]
    }
    else {
        x := -1
        y := -1
    }
    return { x: x, y: y }
}


GetWindowTitlesFromProcess(process:="runelite.exe", title:="") {
    windowsFromProcess := []
    HWNDs := WinGetList("ahk_exe " process)
    for (id in HWNDs) {
        windowTitle := WinGetTitle("ahk_id " . id)
        if (title != "") { ; Include only windows where title contain title
            if (InStr(windowTitle, title)) {
                windowsFromProcess.push(windowTitle)
            }
        }
        else {
            windowsFromProcess.push(windowTitle)
        }
    }
    return windowsFromProcess
}


FileReadOrCreate(path) {
    if (!FileExist(path)) {
        file := FileOpen(path, "w")
        file.Close()
    }
    contents := FileRead(path)
    return contents
}



IsNumerical(var) {
    if (RegExMatch(var, "^\d*$")) {
        return true
    }
    else {
        return false
    }
}


SpamClick(minimum:=1, maximum:=5) {
    spamAmount := Random(minimum, maximum)
    Loop spamAmount {
        Click()
        Sleep(Random(100,250))
    }
}


HexToRgb(hex)
{
    Red := hex >> 16 & 0xFF
    Green := hex >> 8 & 0xFF
    Blue := hex & 0xFF
    ; return [Red, Green, Blue]
    return { r: Red, g: Green, b: Blue }
}
CompareColors(c1, c2, vary:=20) {
    if (!IsObject(c1)) {
        c1 := HexToRgb(c1)
    }
    if (!IsObject(c2)) {
        c2 := HexToRgb(c2)
    }
    rdiff := Abs( c1.r - c2.r )
    gdiff := Abs( c1.g - c2.g )
    bdiff := Abs( c1.b - c2.b )

    return rdiff <= vary && gdiff <= vary && bdiff <= vary
}
ColorWithin(colorToCheck, c1, c2) {
    if (!IsObject(colorToCheck)) {
        colorToCheck := HexToRgb(colorToCheck)
    }
    if (!IsObject(c1)) {
        c1 := HexToRgb(c1)
    }
    if (!IsObject(c2)) {
        c2 := HexToRgb(c2)
    }
    
    ; Check if each component of colorToCheck is within the range defined by c1 and c2
    if (colorToCheck.r >= Min(c1.r, c2.r) && colorToCheck.r <= Max(c1.r, c2.r) &&
        colorToCheck.g >= Min(c1.g, c2.g) && colorToCheck.g <= Max(c1.g, c2.g) &&
        colorToCheck.b >= Min(c1.b, c2.b) && colorToCheck.b <= Max(c1.b, c2.b)) {
        return true
    } else {
        return false
    }
}


findRectangle(searchColor, guessX, guessY, maxDistance := 100) {
    pos := findEdge(searchColor, guessX, guessY, -1, 0, maxDistance)
    leftEdge := pos.x

    pos := findEdge(searchColor, guessX, guessY, 1, 0, maxDistance)
    rightEdge := pos.x

    pos := findEdge(searchColor, guessX, guessY, 0, -1, maxDistance)
    topEdge := pos.y

    pos := findEdge(searchColor, guessX, guessY, 0, 1, maxDistance)
    bottomEdge := pos.y

    centerX := (leftEdge + rightEdge) // 2
    centerY := (topEdge + bottomEdge) // 2

    return {p1: {x: leftEdge, y: topEdge}, p2: {x: rightEdge, y: bottomEdge}, center: {x: centerX, y: centerY}}
}

findEdge(searchClr, sx, sy, xstep, ystep, maxDistance) {
    lastSuccess := {x: sx, y: sy}
    Loop(maxDistance) {
        px := sx + (A_Index - 1) * xstep
        py := sy + (A_Index - 1) * ystep
        clr := PixelGetColor(px, py, "RGB")
        if (clr != searchClr) {
            return lastSuccess
        }
        lastSuccess := {x: px, y: py}
    }
    return lastSuccess
}



MyPixelSearch(startX, startY, width, height, color) {
    foundX := -1, foundY := -1
    found := PixelSearch(&foundX, &foundY, startX, startY, width, height, color)

    if (!found) {
        return false ; Color not found
    }
    if (foundX == -1 && foundY == -1) {
        return false ; Color not found
    }

    ; Initialize variables to store the furthest points
    maxSEX := foundX, maxSEY := foundY
    maxSWX := foundX, maxSWY := foundY
    maxY := foundY

    interval := 10
    distance0 := 0
    ; Find the furthest point in south direction
    loop {
        if (PixelGetColor(foundX, maxY + interval) != color) {
            break
        }
        maxY += interval
    }
    distance0 := CalcDistance(foundX,foundY, foundX,maxY)

    distance1 := 0
    if (distance0 < 10) {
        ; Find the furthest point in the south-east direction
        loop {
            if (PixelGetColor(maxSEX + interval, maxSEY + interval) != color) {
                break
            }
            maxSEX += interval, maxSEY += interval
        }
        distance1 := CalcDistance(foundX,foundY, maxSEX,maxSEY)
    }

    distance2 := 0
    if (distance1 < 10) {
        ; Find the furthest point in the south-west direction
        loop {
            if (PixelGetColor(maxSWX - interval, maxSWY + interval) != color) {
                break
            }
            maxSWX -= interval, maxSWY += interval
        }
    }
    distance2 := CalcDistance(foundX,foundY, maxSWX,maxSWY)

    if (distance0 > distance1 && distance0 > distance2) {
        centerX := foundX
        centerY := (foundY + maxY) // 2
    }
    ; Calculate the center point between the original found point and the furthest points
    else if (distance1 > distance2) {
        ; maxSEX,maxSEY is the furthest point, find middle of that and foundX,foundY
        centerX := (foundX + maxSEX) // 2
        centerY := (foundY + maxSEY) // 2
    }
    else {
        ; maxSWX,maxSWY is the furthest point, find middle of that and foundX,foundY
        centerX := (foundX + maxSWX) // 2
        centerY := (foundY + maxSWY) // 2
    }
    ; centerX := (foundX + maxSEX + maxSWX) // 3
    ; centerY := (foundY + maxSEY + maxSWY) // 3

    return [centerX, centerY]
}




; IsWindowBlocked(title) {
;     ; Get the window handle of the target window
;     targetHwnd := WinExist(title)
;     if (!targetHwnd)
;         return false  ; Window not found

;     ; Get the coordinates of the target window
;     WinGetPos(&targetX, &targetY, &targetWidth, &targetHeight, "ahk_id " targetHwnd)

;     ; Enumerate all top-level windows and check for overlaps
;     windowList := WinGetList()

;     for (windowIndex, currentHwnd in windowList) {
;         ; Skip the target window
;         if (currentHwnd == targetHwnd)
;             continue

;         ; Get the coordinates of the current window
;         WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_id " currentHwnd)

;         ; Check if the current window overlaps with the target window
;         if (targetX < winX + winWidth && targetX + targetWidth > winX
;             && targetY < winY + winHeight && targetY + targetHeight > winY) {
;             ; The current window is blocking the target window
;             return true
;         }
;     }

;     ; No blocking window found
;     return false
; }

; findRectangle(searchColor,guessX,guessY)
; {
; 	pos := findEdge(searchColor,guessX,guessY,-50,0) ;rough scan left 25 px step
; 	leftEdge := findEdge(searchColor,pos.x ,pos.y,-1,0) ;precice scan to find edge from last know good pos
	
; 	pos := findEdge(searchColor,guessX,guessY,50,0) 
; 	rightEdge := findEdge(searchColor,pos.x ,pos.y,1,0) 
	
; 	pos := findEdge(searchColor,guessX,guessY,0,-50) 
; 	topEdge := findEdge(searchColor,pos.x ,pos.y,0,-1) 
	
; 	pos := findEdge(searchColor,guessX,guessY,0,50) 
; 	bottomEdge := findEdge(searchColor,pos.x ,pos.y,0,1) 
; 	return {p1:{x:leftEdge.x,y:topEdge.y},p2:{x:rightEdge.x,y:bottomEdge.y}}
; }

; findEdge(searchClr,sx,sy,xstep,ystep)
; {
; 	lastSuccess := ""
; 	Loop
; 	{
; 		s := a_index - 1 
; 		px := sx+s*xstep
; 		py := sy+s*ystep
; 		clr := PixelGetColor(px,py,"RGB")
; 		if(clr != searchClr)
; 		{			
; 			return lastSuccess 
; 		}
; 		lastSuccess := {x:px,y:py}
; 	}
; }