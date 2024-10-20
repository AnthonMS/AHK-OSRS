#Requires AutoHotkey v2.0

#Include <Gui/Page>

class SeersRooftopPage extends Page {
    __New(window:=false, name:="Seers' Rooftop Runner") {
        super.__New(window, name)
        this.Config := this.GetConfig()  ; NOT THE SAME AS this.Window.Config!

        this.Running := false
        this.Status := "Idle"
        this.TimeoutCall := ""
        this.StartTime := 0
        this.BreakTime := 0

        this.Worldpoints := [
            {
                key: "after1",
                x: 2729,
                y: 3491,
                plane: 3
            },
            {
                key: "after2Success",
                x: 2713,
                y: 3494,
                plane: 2
            },
            {
                key: "after2Fail",
                x: 2715,
                y: 3494,
                plane: 0
            },
            {
                key: "after3Success",
                x: 2710,
                y: 3480,
                plane: 2
            },
            {
                key: "after3Fail",
                x: 2710,
                y: 3484,
                plane: 0
            },
            {
                key: "after4",
                x: 2710,
                y: 3472,
                plane: 3
            },
            {
                key: "after4-2",
                x: 2712,
                y: 3472,
                plane: 3
            },
            {
                key: "after5",
                x: 2702,
                y: 3465,
                plane: 2
            },
            {
                key: "afterLast",
                x: 2704,
                y: 3464,
                plane: 0
            }
        ]
        this.Worldpoints := JSON.Load(JSON.Dump(this.Worldpoints))
    }
    GetConfig() {
        conf := FileReadOrCreate(A_ScriptDir "\Configs\seers.config")
        if (conf == "") {
            return JSON.Load("{}")
        }
        return JSON.Load(conf)
    }
    SaveConfig(btn:=Object(), info:=Map()) {
        file := FileOpen(A_ScriptDir "\Configs\seers.config", "w")
        jsonString := JSON.Dump(this.Config, true)
        file.Write(jsonString)
        file.Close()
    }

    Show() {
        this.Config := this.GetConfig()
        super.Show()
    }
    GoBack(el, info) {
        this.Window.ShowPage("Home")
    }

    Init() {
        this.AddElement("Button", "x0 y0 w20 h20 -Border", {text:"←", eventName:"Click", cb:"GoBack"})
        this.AddElement("Text", "x35 y0 w200 h30 -Background", {name:"seersStatusText", text:this.Status, font:"s12"})
        this.AddElement("Button", "x0 y35 w50 h25 -Border", {name:"seersStartBtn", text:"Start", eventName:"Click", cb:"StartSeersRunner"})
        this.AddElement("Button", "x55 y35 w50 h25 -Border", {name:"seersStopBtn", text:"Stop", eventName:"Click", cb:"StopSeersRunner"})
        
        this.AddElement("Text", "x0 y75 w80 h25 +0x200 -Background", {text:"Scroll:"})
        this.AddElement("Edit", "x35 y75 w30 h20", {name:"camScrollEdit", eventName:"Change", cb:"OnScrollEditChanged"})

        this.AddElement("Text", "x0 y105 w150 h25 +0x200 -Background", {text:"Obstacle 1 Positions:"})
        this.AddElement("Text", "x0 y130 w100 h25 +0x200 -Background", {text:"After last:"})
        this.AddElement("Text", "x0 y155 w100 h25 +0x200 -Background", {text:"After fail check 1:"})
        this.AddElement("Text", "x0 y180 w100 h25 +0x200 -Background", {text:"After fail check 2:"})
        this.AddElement("Edit", "x105 y130 w60 h20", {name:"edit-afterLastPos",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Edit", "x105 y155 w60 h20", {name:"edit-afterFail1Pos",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Edit", "x105 y180 w60 h20", {name:"edit-afterFail2Pos", eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y130 w20 h20 -Border", {name:"afterLastPos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Button", "x165 y155 w20 h20 -Border", {name:"afterFail1Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Button", "x165 y180 w20 h20 -Border", {name:"afterFail2Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})


        this.AddElement("Text", "x0 y205 w150 h25 +0x200 -Background", {text:"Obstacle 2 Positions:"})
        this.AddElement("Text", "x0 y230 w100 h25 +0x200 -Background", {text:"Mark of Grace:"})
        this.AddElement("Text", "x0 y255 w100 h25 +0x200 -Background", {text:"With Mark:"})
        this.AddElement("Text", "x0 y280 w100 h25 +0x200 -Background", {text:"No Mark:"})
        this.AddElement("Edit", "x105 y230 w60 h20", {name:"edit-mark1Pos",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Edit", "x105 y255 w60 h20", {name:"edit-afterMark1Pos",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Edit", "x105 y280 w60 h20", {name:"edit-after1Pos", eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y230 w20 h20 -Border", {name:"mark1Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Button", "x165 y255 w20 h20 -Border", {name:"afterMark1Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Button", "x165 y280 w20 h20 -Border", {name:"after1Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})


        this.AddElement("Text", "x0 y305 w150 h25 +0x200 -Background", {text:"Obstacle 3 Positions:"})
        this.AddElement("Text", "x0 y330 w100 h25 +0x200 -Background", {text:"Mark of Grace:"})
        this.AddElement("Edit", "x105 y330 w60 h20", {name:"edit-mark2Pos",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Edit", "x190 y330 w60 h20", {name:"edit-mark3Pos",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y330 w20 h20 -Border", {name:"mark2Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Button", "x250 y330 w20 h20 -Border", {name:"mark3Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})

        this.AddElement("Text", "x0 y355 w100 h25 +0x200 -Background", {text:"With Mark:"})
        this.AddElement("Edit", "x105 y355 w60 h20", {name:"edit-afterMark2Pos", eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Edit", "x190 y355 w60 h20", {name:"edit-afterMark3Pos",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y355 w20 h20 -Border", {name:"afterMark2Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Button", "x250 y355 w20 h20 -Border", {name:"afterMark3Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Text", "x0 y380 w100 h25 +0x200 -Background", {text:"No Mark:"})
        this.AddElement("Edit", "x105 y380 w60 h20", {name:"edit-after2Pos",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y380 w20 h20 -Border", {name:"after2Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})



        this.AddElement("Text", "x0 y405 w150 h25 +0x200 -Background", {text:"Obstacle 4 Positions:"})
        this.AddElement("Text", "x0 y430 w100 h25 +0x200 -Background", {text:"Mark of Grace:"})
        this.AddElement("Edit", "x105 y430 w60 h20", {name:"edit-mark4Pos",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y430 w20 h20 -Border", {name:"mark4Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Text", "x0 y455 w100 h25 +0x200 -Background", {text:"With Mark:"})
        this.AddElement("Edit", "x105 y455 w60 h20", {name:"edit-afterMark4Pos",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y455 w20 h20 -Border", {name:"afterMark4Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Text", "x0 y480 w100 h25 +0x200 -Background", {text:"No Mark:"})
        this.AddElement("Edit", "x105 y480 w60 h20", {name:"edit-after3Pos", eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y480 w20 h20 -Border", {name:"after3Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})


        this.AddElement("Text", "x0 y505 w150 h25 +0x200 -Background", {text:"Obstacle 5 Positions:"})
        this.AddElement("Text", "x0 y530 w100 h25 +0x200 -Background", {text:"No Mark:"})
        this.AddElement("Edit", "x105 y530 w60 h20", {name:"edit-after4Pos", eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y530 w20 h20 -Border", {name:"after4Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})


        this.AddElement("Text", "x0 y555 w150 h25 +0x200 -Background", {text:"Obstacle 6 Positions:"})
        this.AddElement("Text", "x0 y580 w100 h25 +0x200 -Background", {text:"Mark of Grace:"})
        this.AddElement("Edit", "x105 y580 w60 h20", {name:"edit-mark5Pos",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y580 w20 h20 -Border", {name:"mark5Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Text", "x0 y605 w100 h25 +0x200 -Background", {text:"No Mark:"})
        this.AddElement("Edit", "x105 y605 w60 h20", {name:"edit-after5Pos", eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y605 w20 h20 -Border", {name:"after5Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Text", "x0 y630 w100 h25 +0x200 -Background", {text:"With Mark:"})
        this.AddElement("Edit", "x105 y630 w60 h20", {name:"edit-afterMark5Pos",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y630 w20 h20 -Border", {name:"afterMark5Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
    }

    Update() {
        this.GetElement("seersStartBtn").Enabled := !this.Running
        this.GetElement("seersStopBtn").Enabled := this.Running


        this.GetElement("seersStatusText").Value := this.Status
        this.GetElement("camScrollEdit").Value := this.Config.Has("camScrollEdit") ? this.Config.Get("camScrollEdit") : ""
        for (el in this.Elements) {
            if (InStr(el.Name, "edit-") == 1) {
                configKey := StrReplace(el.Name, "edit-", "")
                if (this.Config.Has(configKey)) {
                    el.Value := this.Config.Get(configKey)
                }
            }
        }
    }
    
    OnInputPosChanged(el, info) {
        MyTip(el.Name " change to " el.Value)
    }

    OnScrollEditChanged(el, info) {
        if (!IsNumerical(el.Value)) {
            ; inputField.Value := ""
            MyTip("Camera Scroll can only be numerical value")
        }
        else {
            this.Config.Set(el.Name, el.Value)
            this.SaveConfig()
        }
    }

    OnSetPosClicked(el, info) {
        MyTip("Click on agility obstacle to set position")
        this.Window.FocusRuneliteWindow()
        
        Hotkey("LButton", (btn) => this.SetPosClick(btn, el.Name), "On")
    }
    SetPosClick(event, name) {
        Hotkey("LButton", "Off")
        MouseGetPos(&mouseX, &mouseY)
        color := PixelGetColor(mouseX, mouseY)
        pos := mouseX "," mouseY
        this.Config.Set(name, pos)
        if (RegExMatch(name, "mark(\d+)Pos", &matches)) {
            this.Config.Set(StrReplace(name, "Pos", "Color"), color)
        }
        this.SaveConfig()
        MyTip("Set " name " to " pos)
        this.Update()
    }


    CheckCurrentWorldPos() {
        eventsUrl := this.Window.Config.Has('httpPluginPathEvents') ? this.Window.Config.Get('httpPluginPathEvents') : ""
        if (eventsUrl == "") {
            MsgBox("Configure HTTP Plugin path for events")
            return
        }

        
        oOptions := Map()
        oOptions["SslError"] := false
        oOptions["UA"] := "Autohotkey-lol"
        http := WinHttpRequest(oOptions)
        response := http.GET(eventsUrl)
        jsonRes := JSON.Load(response.Text)
        currentWorldPoint := jsonRes.Get("worldPoint")
        for (i, val in this.Worldpoints) {
            if (val.Get("x") == currentWorldPoint.Get("x") && 
                val.Get("y") == currentWorldPoint.Get("y") && 
                val.Get("plane") == currentWorldPoint.Get("plane")) {
                    return val.Get("key")
            }
        }
        return ""
    }

    StopSeersRunner(btn, info:="") {
        this.Running := false
        this.Status := "Stopped"
        this.StartTime := 0
        this.Update()
        Hotkey("*Escape", "Off")
    }
    StartSeersRunner(btn, info) {
        this.Running := !this.Running
        if (this.Running) {
            this.Status := "Running"
            ; this.StartTime := A_Now ; YYYYMMDDhhmmss
            this.StartTime := A_TickCount ; YYYYMMDDhhmmss
            this.BreakTime := 0
            this.Update()
            Hotkey("*Escape", (btn) => this.StopSeersRunner(btn), "On")
            this.Window.FocusRuneliteWindow()
            ; Find closest position to center with color


            ; scrollAmount := this.Config.Has("camScrollEdit") ? this.Config.Get("camScrollEdit") : 0
            ; MouseMoveRandom(200,200, {blockMouse:true, mode:"really-slow"})
            ; Loop(50) {
            ;     Send("{WheelUp 1}")
            ;     Sleep(Random(0,50))
            ; }
            ; QuickSleep()
            ; Loop (scrollAmount) {
            ;     Send("{WheelDown 1}")
            ;     QuickSleep()
            ; }
            ; this.ThisLoop()
        }
    }

    FindClosestObstacle() {
        rlPos := this.Window.GetRuneliteWindowDimensions()
        color := this.Config.Has("obstacleColor") ? this.Config.Get("obstacleColor") : "0x00FFFF"
        found := PixelSearch(&foundX, &foundY, 0, 0, rlPos.Get("width"), rlPos.Get("height"), color)
        if (found) {
            posX := foundX + (this.Config.Get("farmerRectWidth") / 2)
            posY := foundY + (this.Config.Get("farmerRectHeight") / 2)
            if (!this.Eating && !this.Dropping) {
                MouseMoveRandom(posX, posY, {offsetX: 10, blockMouse: true, mode:"normal"})
            }
        }
        else {
            this.FarmerPosition.x := 0
            this.FarmerPosition.y := 0
        }

        Sleep(1)
    }

    ThisLoop() {
        While (this.Running) {
            if (this.BreakTime == 0) { ; If break time is 0, there should be a chance to begin break
                elapsedSeconds := Round((A_TickCount - this.StartTime) / 1000.0)
                if (elapsedSeconds > 0 && Mod(elapsedSeconds, 300) == 0) {
                    ; Check for break chance every 5 minute
                    chance := (elapsedSeconds / 1800) * 10
                    randomChance := Format("{:.2f}", rand := 100 * Random())
                    ; MyTip("randomChance: " randomChance "`nA_TickCount: " A_TickCount "`nelapsedSeconds: " elapsedSeconds "`nchance: " chance, 5000)
                    ; MsgBox("randomChance: " randomChance "`nA_TickCount: " A_TickCount "`nelapsedSeconds: " elapsedSeconds "`nchance: " chance)
                    if (randomChance < chance) {
                        this.BreakTime := A_TickCount
                    }
                }
            }
            else {
                elapsedBreakTime := Round((A_TickCount - this.BreakTime) / 1000.0)
                if (elapsedBreakTime > 0 && Mod(elapsedBreakTime, 300) == 0) {
                    ;; Start Chancing for stopping break time
                    breakStopChanceIncrement := (elapsedBreakTime / 1800) * 50
                    breakStopChance := Format("{:.2f}", rand := 100 * Random())
                    ; MyTip("breakStopChance: " breakStopChance "`nA_TickCount: " A_TickCount "`nelapsedBreakTime: " elapsedBreakTime "`nbreakStopChanceIncrement: " breakStopChanceIncrement, 5000)
                    ; MsgBox("breakStopChance: " breakStopChance "`nA_TickCount: " A_TickCount "`nelapsedBreakTime: " elapsedBreakTime "`nbreakStopChanceIncrement: " breakStopChanceIncrement)
                    if (breakStopChance < breakStopChanceIncrement) {
                        this.BreakTime := 0
                    }
                }
            }

            if (this.BreakTime == 0 && A_TimeIdleMouse > 2000) {
                this.ClickNextObstacle()
            }
            else if (this.BreakTime != 0) {
                r := Random(7000, 13000)
                ; 300000
                MyTip("Taking a break, checking back in 10 seconds")
                Sleep("10000")
            }
        }
    }

    TestNextObstacleConfig() {
        this.ClickNextObstacle(true)
    }
    ClickNextObstacle(test:=false) {
        this.Window.FocusRuneliteWindow()
        currentPos := this.CheckCurrentWorldPos()
        Switch (currentPos)  {
            Default:
                MyTip("Current position unknown. Waiting 7-13 seconds to check again...")
                Sleep(Random(7000, 13000))
            Case "after1":
                ; Check for mark at `mark1Pos` with color `mark1Color`
                ; If color is different, mark is present. Click it, wait and click at `afterMark2Pos`
                ; Else click at `after1Pos`
                mark1Pos := ExtractCoords(this.Config.Get("mark1Pos"))
                mark1Color := this.Config.Get("mark1Color")
                foundColor := PixelGetColor(mark1Pos.x, mark1Pos.y)
                if (!CompareColors(foundColor, mark1Color)) {
                    ; CLick at mark1Pos
                    MouseMoveRandom(mark1Pos.x, mark1Pos.y, {offsetX: 5, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    Click()
                    SleepJittery(Random(1600, 2000))
                    ; Wait and click at `afterMark1Pos`
                    afterMark1Pos := ExtractCoords(this.Config.Get("afterMark1Pos"))
                    MouseMoveRandom(afterMark1Pos.x, afterMark1Pos.y, {offsetX: 5, offsetY: 20, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    SpamClick(,3)
                    if (!test) {
                        SleepJittery(Random(6000, 7000))
                    }
                }
                else {
                    ; Click at `after1Pos`
                    after1Pos := ExtractCoords(this.Config.Get("after1Pos"))
                    MouseMoveRandom(after1Pos.x, after1Pos.y, {offsetX: 5, offsetY: 20, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    SpamClick(,3)
                    if (!test) {
                        SleepJittery(Random(7000, 8000))
                    }
                }
            Case "after2Success":
                ; Check for mark at `mark2Pos` with color `mark2Color`
                    ; If color is different, mark is present. Click it, wait and click at `afterMark2Pos`
                ; Else Check for mark at `mark3Pos` with color `mark3Color`
                    ; If color is different, mark is present. Click it, wait and click at `afterMark3Pos`
                ; Else click at `after2Pos`
                mark2Pos := ExtractCoords(this.Config.Get("mark2Pos"))
                mark2Color := this.Config.Get("mark2Color")
                foundColor := PixelGetColor(mark2Pos.x, mark2Pos.y)
                mark3Pos := ExtractCoords(this.Config.Get("mark3Pos"))
                mark3Color := this.Config.Get("mark3Color")
                foundColor2 := PixelGetColor(mark3Pos.x, mark3Pos.y)
                if (!CompareColors(foundColor, mark2Color)) {
                    ; CLick at mark2Pos
                    MouseMoveRandom(mark2Pos.x, mark2Pos.y, {offsetX: 5, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    Click()
                    SleepJittery(Random(3500, 4000))
                    ; Wait and click at `afterMark2Pos`
                    afterMark2Pos := ExtractCoords(this.Config.Get("afterMark2Pos"))
                    MouseMoveRandom(afterMark2Pos.x, afterMark2Pos.y, {offsetX: 5, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    SpamClick(,3)
                    if (!test) {
                        SleepJittery(Random(9000, 10000))
                    }
                }
                else if (!CompareColors(foundColor2, mark3Color)) {
                    MouseMoveRandom(mark3Pos.x, mark3Pos.y, {offsetX: 5, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    Click()
                    SleepJittery(Random(3000, 4000))
                    afterMark3Pos := ExtractCoords(this.Config.Get("afterMark3Pos"))
                    MouseMoveRandom(afterMark3Pos.x, afterMark3Pos.y, {offsetX: 5, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    SpamClick(,3)
                    if (!test) {
                        SleepJittery(Random(9000, 10000))
                    }
                }
                else {
                    after2Pos := ExtractCoords(this.Config.Get("after2Pos"))
                    MouseMoveRandom(after2Pos.x, after2Pos.y, {offsetX: 5, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    SpamClick(,3)
                    if (!test) {
                        SleepJittery(Random(10000, 11000))
                    }
                }
            Case "after3Success":
                ; Check for mark at `mark4Pos` with color `mark4Color`
                ; If color is different, mark is present. Click it, wait and click at `afterMark4Pos`
                ; Else click at `after3Pos`
                mark4Pos := ExtractCoords(this.Config.Get("mark4Pos"))
                mark4Color := this.Config.Get("mark4Color")
                foundColor := PixelGetColor(mark4Pos.x, mark4Pos.y)
                if (!CompareColors(foundColor, mark4Color)) {
                    MouseMoveRandom(mark4Pos.x, mark4Pos.y, {offsetX: 5, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    Click()
                    SleepJittery(Random(1000, 1500))
                    afterMark4Pos := ExtractCoords(this.Config.Get("afterMark4Pos"))
                    MouseMoveRandom(afterMark4Pos.x, afterMark4Pos.y, {offsetX: 25, offsetY: 5, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    SpamClick(,3)
                    if (!test) {
                        SleepJittery(Random(4500, 5500))
                    }
                }
                else {
                    after3Pos := ExtractCoords(this.Config.Get("after3Pos"))
                    MouseMoveRandom(after3Pos.x, after3Pos.y, {offsetX: 25, offsetY: 5, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    SpamClick(,3)
                    if (!test) {
                        SleepJittery(Random(4500, 5500))
                    }
                }
            Case "after4", "after4-2":
                ; Click at `after4Pos`
                after4Pos := ExtractCoords(this.Config.Get("after4Pos"))
                if (currentPos == "after4-2") {
                    MouseMoveRandom(after4Pos.x, after4Pos.y, {offsetX: 10, offsetY: 5, blockMouse: true, mode:"really-slow"})
                }
                else {
                    MouseMoveRandom(after4Pos.x, after4Pos.y, {offsetX: 10, offsetY: 5, blockMouse: true, mode:"really-slow"})
                }
                QuickSleep()
                SpamClick(,3)
                if (!test) {
                    SleepJittery(Random(5500, 6500))
                }
            Case "after5":
                ; Check for mark at `mark5Pos` with color `mark5Color`
                    ; If color is different, mark is present. Click it, wait and click at `afterMark5Pos`
                ; Else click at `after5Pos`
                mark5Pos := ExtractCoords(this.Config.Get("mark5Pos"))
                mark5Color := this.Config.Get("mark5Color")
                foundColor := PixelGetColor(mark5Pos.x, mark5Pos.y)
                if (!CompareColors(foundColor, mark5Color)) {
                    MouseMoveRandom(mark5Pos.x, mark5Pos.y, {offsetX: 5, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    Click()
                    SleepJittery(Random(2000, 2500))
                    afterMark5Pos := ExtractCoords(this.Config.Get("afterMark5Pos"))
                    MouseMoveRandom(afterMark5Pos.x, afterMark5Pos.y, {offsetX: 5, offsetY: 10, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    SpamClick(,3)
                    if (!test) {
                        SleepJittery(Random(4500, 5500))
                    }
                }
                else {
                    after5Pos := ExtractCoords(this.Config.Get("after5Pos"))
                    MouseMoveRandom(after5Pos.x, after5Pos.y, {offsetX: 5, offsetY: 10, blockMouse: true, mode:"really-slow"})
                    QuickSleep()
                    SpamClick(,3)
                    if (!test) {
                        SleepJittery(Random(3500, 4500))
                    }
                }
            Case "after2Fail":
                ; Click at `afterFail1Pos`
                afterFail1Pos := ExtractCoords(this.Config.Get("afterFail1Pos"))
                MouseMoveRandom(afterFail1Pos.x, afterFail1Pos.y, {offsetX: 3, offsetY: 3, blockMouse: true, mode:"really-slow"})
                QuickSleep()
                SpamClick(,3)
                if (!test) {
                    SleepJittery(Random(10000, 11000))
                }
            Case "after3Fail":
                ; Click at `afterFail2Pos`
                afterFail2Pos := ExtractCoords(this.Config.Get("afterFail2Pos"))
                MouseMoveRandom(afterFail2Pos.x, afterFail2Pos.y, {offsetX: 3, offsetY: 3, blockMouse: true, mode:"really-slow"})
                QuickSleep()
                SpamClick(,3)
                if (!test) {
                    SleepJittery(Random(10000, 11000))
                }
            Case "afterLast":
                ; Click at `afterLastPos`
                afterLastPos := this.Config.Get("afterLastPos")
                afterLastCoords := ExtractCoords(afterLastPos)
                MouseMoveRandom(afterLastCoords.x, afterLastCoords.y, {offsetX: 3, blockMouse: true, mode:"really-slow"})
                QuickSleep()
                QuickSleep()
                SpamClick(,3)
                if (!test) {
                    SleepJittery(Random(18000, 19000))
                }
        }
    }

}