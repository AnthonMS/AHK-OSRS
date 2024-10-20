#Requires AutoHotkey v2.0

#Include <Gui/Page>

class HosidiousFruitstallsPage extends Page {
    __New(window:=false, name:="Hosidious Fruitstall Trainer") {
        super.__New(window, name)
        this.Config := this.GetConfig()  ; NOT THE SAME AS this.Window.Config!

        this.Running := false
        this.Status := "Idle"
        this.TimeoutCall := ""
        this.StartTime := 0
        this.BreakTime := 0

        this.LastStall := -1 ; 0: left, 1: right

        this.Worldpoints := [
            {
                key: "right-down",
                x: 1800,
                y: 3607,
                plane: 0
            },
            {
                key: "right-up",
                x: 1800,
                y: 3608,
                plane: 0
            },
            {
                key: "left-down",
                x: 1796,
                y: 3607,
                plane: 0
            },
            {
                key: "left-up",
                x: 1796,
                y: 3608,
                plane: 0
            },
        ]
        this.Worldpoints := JSON.Load(JSON.Dump(this.Worldpoints))
    }
    GetConfig() {
        conf := FileReadOrCreate(A_ScriptDir "\Configs\HosFruitStalls.config")
        if (conf == "") {
            return JSON.Load("{}")
        }
        return JSON.Load(conf)
    }
    SaveConfig(btn:=Object(), info:=Map()) {
        file := FileOpen(A_ScriptDir "\Configs\HosFruitStalls.config", "w")
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
        this.AddElement("Text", "x35 y0 w200 h30 -Background", {name:"hosFruitStatus", text:this.Status, font:"s12"})
        this.AddElement("Button", "x0 y35 w50 h25 -Border", {name:"hosFruitStartBtn", text:"Start", eventName:"Click", cb:"StartTrainer"})
        this.AddElement("Button", "x55 y35 w50 h25 -Border", {name:"hosFruitStopBtn", text:"Stop", eventName:"Click", cb:"StopTrainer"})
        
        ; fkeysOnCaps := this.Window.Config.Has('fkeysOnCaps') ? this.Window.Config.Get('fkeysOnCaps') : ""
        ; if (fkeysOnCaps) {
        ;     this.Window.CreateFKeysOnCapslockKeybinds()
        ; }
        this.AddElement("CheckBox", "x80 y60 w75 h25", {name:"hosFruitStallOnlyLeft", text:" Only Left", eventName:"Click", cb:"CheckboxToggle"})
        this.AddElement("CheckBox", "x80 y80 w75 h25", {name:"hosFruitStallOnlyRight", text:" Only Right", eventName:"Click", cb:"CheckboxToggle"})

        this.AddElement("Text", "x0 y75 w80 h25 +0x200 -Background", {text:"Scroll:"})
        this.AddElement("Edit", "x35 y75 w30 h20", {name:"hosFruitCamScroll", eventName:"Change", cb:"OnScrollEditChanged"})

        this.AddElement("Text", "x0 y110 w80 h25 +0x200 -Background", {text:"Drop Positions:"})
        this.AddElement("Edit", "x80 y110 w60 h20", {name:"edit-hosFruitDropPos1", eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x140 y110 w20 h20 -Border", {name:"hosFruitDropPos1", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Edit", "x165 y110 w60 h20", {name:"edit-hosFruitDropPos2", eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x225 y110 w20 h20 -Border", {name:"hosFruitDropPos2", text:"X", eventName:"Click", cb:"OnSetPosClicked"})

        this.AddElement("Text", "x0 y135 w180 h25 +0x200 -Background", {text:"Fruit Stall Positions after picking left"})
        this.AddElement("Text", "x0 y160 w100 h25 +0x200 -Background", {text:"Left:"})
        this.AddElement("Text", "x0 y185 w100 h25 +0x200 -Background", {text:"Right:"})
        this.AddElement("Edit", "x105 y160 w60 h20", {name:"edit-hosFruitStallLeftLeft",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Edit", "x105 y185 w60 h20", {name:"edit-hosFruitStallRightLeft",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y160 w20 h20 -Border", {name:"hosFruitStallLeftLeft", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Button", "x165 y185 w20 h20 -Border", {name:"hosFruitStallRightLeft", text:"X", eventName:"Click", cb:"OnSetPosClicked"})

        this.AddElement("Text", "x0 y205 w180 h25 +0x200 -Background", {text:"Fruit Stall Positions after picking right"})
        this.AddElement("Text", "x0 y230 w100 h25 +0x200 -Background", {text:"Left:"})
        this.AddElement("Text", "x0 y255 w100 h25 +0x200 -Background", {text:"Right:"})
        this.AddElement("Edit", "x105 y230 w60 h20", {name:"edit-hosFruitStallLeftRight",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Edit", "x105 y255 w60 h20", {name:"edit-hosFruitStallRightRight",  eventName:"Change", cb:"OnInputPosChanged"})
        this.AddElement("Button", "x165 y230 w20 h20 -Border", {name:"hosFruitStallLeftRight", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
        this.AddElement("Button", "x165 y255 w20 h20 -Border", {name:"hosFruitStallRightRight", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
    }

    Update() {
        this.GetElement("hosFruitStartBtn").Enabled := !this.Running
        this.GetElement("hosFruitStopBtn").Enabled := this.Running
        this.GetElement("hosFruitStatus").Value := this.Status
        this.GetElement("hosFruitCamScroll").Value := this.Config.Has("hosFruitCamScroll") ? this.Config.Get("hosFruitCamScroll") : ""
        this.GetElement("hosFruitStallOnlyLeft").Value := this.Config.Has("hosFruitStallOnlyLeft") ? this.Config.Get("hosFruitStallOnlyLeft") : false
        this.GetElement("hosFruitStallOnlyRight").Value := this.Config.Has("hosFruitStallOnlyRight") ? this.Config.Get("hosFruitStallOnlyRight") : false
        for (el in this.Elements) {
            if (InStr(el.Name, "edit-") == 1) {
                configKey := StrReplace(el.Name, "edit-", "")
                if (this.Config.Has(configKey)) {
                    el.Value := this.Config.Get(configKey)
                }
            }
        }
    }
    CheckboxToggle(el, info) {
        this.Config.Set(el.Name, el.Value)
        if (el.Name == "hosFruitStallOnlyLeft" && el.Value) {
            this.Config.Set("hosFruitStallOnlyRight", 0)
        }
        else if (el.Name == "hosFruitStallOnlyRight" && el.Value) {
            this.Config.Set("hosFruitStallOnlyLeft", 0)
        }
        this.SaveConfig()
        this.Update()
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
            MyTip("Scroll out amount: " . el.Text)
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
        pos := mouseX "," mouseY
        this.Config.Set(name, pos)
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

    StopTrainer(btn, info:="") {
        this.Running := false
        this.Status := "Stopped"
        this.StartTime := 0
        this.Update()
        Hotkey("*Escape", "Off")
    }
    StartTrainer(btn, info) {
        this.Running := true
        this.Status := "Running"
        ; this.StartTime := A_Now ; YYYYMMDDhhmmss
        this.StartTime := A_TickCount
        this.BreakTime := 0
        this.Update()
        Hotkey("*Escape", (btn) => this.StopTrainer(btn), "On")
        this.ThisLoop()
    }

    ThisLoop() {
        While (this.Running) {
            if (this.BreakTime == 0) { ; If break time is 0, there should be a chance to begin break
                elapsedSeconds := Round((A_TickCount - this.StartTime) / 1000.0)
                if (elapsedSeconds > 0 && Mod(elapsedSeconds, 300) == 0) {
                    chance := (elapsedSeconds / 1800) * 10
                    randomChance := Format("{:.2f}", rand := 100 * Random())
                    if (randomChance < chance) {
                        MyTip("Break time started! " randomChance " < " chance, 10000)
                        this.BreakTime := A_TickCount
                    }
                }
            }
            else {
                elapsedBreakTime := Round((A_TickCount - this.BreakTime) / 1000.0)
                if (elapsedBreakTime > 0 && Mod(elapsedBreakTime, 300) == 0) {
                    breakStopChanceIncrement := (elapsedBreakTime / 1800) * 50
                    breakStopChance := Format("{:.2f}", rand := 100 * Random())
                    if (breakStopChance < breakStopChanceIncrement) {
                        MyTip("Break time stopped! " breakStopChance " < " breakStopChanceIncrement, 10000)
                        this.BreakTime := 0
                    }
                }
            }

            if (this.BreakTime == 0 && A_TimeIdleMouse > 2000) {
                this.ClickStall()
                ; SleepJittery(Random(2200, 2200))
                ; MyTip("Sleeping 50 before clicking stall again")
                ; SleepJittery(50)
            }
            else if (this.BreakTime != 0) {
                ; 300000
                MyTip("Taking a break, checking back in 10 seconds")
                Sleep(10000)
            }
        }
    }

    ClickStall(test:=false) {
        this.Window.FocusRuneliteWindow()
        currentPos := this.CheckCurrentWorldPos()
        Switch (currentPos)  {
            Case "right-up", "right-down":
                ; Click either left or right side stall, depending on what was clicked last
                if (this.Config.Has("hosFruitStallOnlyRight") && this.Config.Get("hosFruitStallOnlyRight")) {
                    hosFruitStallRightRight := ExtractCoords(this.Config.Get("hosFruitStallRightRight"))
                    MouseMoveRandom(hosFruitStallRightRight.x, hosFruitStallRightRight.y, {offsetX: 50, blockMouse: true, mode:"custom:600-1025"})
                    Sleep(Random(500, 650))
                    Click()
                    Sleep(Random(500, 650))
                    
                    hosFruitDropPos1 := this.Config.Has("hosFruitDropPos1") ? ExtractCoords(this.Config.Get("hosFruitDropPos1")) : ""
                    Send("{Shift Down}")
                    MouseMoveRandom(hosFruitDropPos1.x, hosFruitDropPos1.y, {offsetX: 7, blockMouse: true, mode:"custom:600-1025"})
                    Sleep(Random(500, 650))
                    Click()
                    Sleep(Random(500, 650))
                    Send("{Shift Up}")
                }
                else {
                    if (this.LastStall == 1) { ; just stole from right side
                        ; Steal from left side
                        hosFruitStallLeftRight := ExtractCoords(this.Config.Get("hosFruitStallLeftRight"))
                        MouseMoveRandom(hosFruitStallLeftRight.x, hosFruitStallLeftRight.y, {offsetX: 25, blockMouse: true, mode:"slow"})
                        QuickSleep()
                        Click()
                        QuickSleep()
                        this.LastStall := 0
                        ; SleepJittery(Random(2000,2250))
                        ; SleepJittery(2000)
                        Sleep(Random(2150,2250))
                    }
                    else { ; Standing on right side but havent stolen from it yet
                        hosFruitStallRightRight := ExtractCoords(this.Config.Get("hosFruitStallRightRight"))
                        MouseMoveRandom(hosFruitStallRightRight.x, hosFruitStallRightRight.y, {offsetX: 25, blockMouse: true, mode:"slow"})
                        QuickSleep()
                        Click()
                        QuickSleep()
                        this.LastStall := 1
                        ; SleepJittery(Random(1000,1150))
                        ; SleepJittery(1000)
                        Sleep(Random(1000,1250))
                    }
                }
            Case "left-up", "left-down":
                if (this.Config.Has("hosFruitStallOnlyLeft") && this.Config.Get("hosFruitStallOnlyLeft")) {
                    hosFruitStallLeftLeft := ExtractCoords(this.Config.Get("hosFruitStallLeftLeft"))
                    MouseMoveRandom(hosFruitStallLeftLeft.x, hosFruitStallLeftLeft.y, {offsetX: 50, blockMouse: true, mode:"custom:600-1025"})
                    Sleep(Random(500, 650))
                    Click()
                    Sleep(Random(500, 650))
                    
                    hosFruitDropPos1 := this.Config.Has("hosFruitDropPos1") ? ExtractCoords(this.Config.Get("hosFruitDropPos1")) : ""
                    Send("{Shift Down}")
                    MouseMoveRandom(hosFruitDropPos1.x, hosFruitDropPos1.y, {offsetX: 7, blockMouse: true, mode:"custom:600-1025"})
                    Sleep(Random(500, 650))
                    Click()
                    Sleep(Random(500, 650))
                    Send("{Shift Up}")
                }
                else {
                    if (this.LastStall == 0) { ; just stole from left side
                        ; Steal from right side after dropping items in inventory
                        this.DropItemsIfNecessary()
                        ; QuickSleep()
                        hosFruitStallRightLeft := ExtractCoords(this.Config.Get("hosFruitStallRightLeft"))
                        MouseMoveRandom(hosFruitStallRightLeft.x, hosFruitStallRightLeft.y, {offsetX: 25, blockMouse: true, mode:"slow"})
                        QuickSleep()
                        Click()
                        QuickSleep()
                        this.LastStall := 1
                        ; SleepJittery(Random(2000,2250))
                        ; SleepJittery(2000)
                        Sleep(Random(2150,2250))
                    }
                    else { ; Standing on left side but havent stolen from it yet
                        hosFruitStallLeftLeft := ExtractCoords(this.Config.Get("hosFruitStallLeftLeft"))
                        MouseMoveRandom(hosFruitStallLeftLeft.x, hosFruitStallLeftLeft.y, {offsetX: 25, blockMouse: true, mode:"slow"})
                        QuickSleep()
                        Click()
                        QuickSleep()
                        this.LastStall := 0
                        ; SleepJittery(Random(1000,1150))
                        ; SleepJittery(1000)
                        Sleep(Random(1000,1250))
                    }
                }
            Default:
                MyTip("Current position unknown. " currentPos)
                ; Sleep(50)
        }
    }

    DropItemsIfNecessary() {
        eventsUrl := this.Window.Config.Has('httpPluginPathInv') ? this.Window.Config.Get('httpPluginPathInv') : ""
        if (eventsUrl == "") {
            MsgBox("Configure HTTP Plugin path for inventory")
            return
        }

        oOptions := Map()
        oOptions["SslError"] := false
        oOptions["UA"] := "Autohotkey-lol"
        http := WinHttpRequest(oOptions)
        response := http.GET(eventsUrl)
        jsonRes := JSON.Load(response.Text)

        this.Window.FocusRuneliteWindow()
        Send("{Shift Down}")
        if (jsonRes[1].Get("id") != -1) {
            hosFruitDropPos1 := this.Config.Has("hosFruitDropPos1") ? ExtractCoords(this.Config.Get("hosFruitDropPos1")) : ""
            MouseMoveRandom(hosFruitDropPos1.x, hosFruitDropPos1.y, {offsetX: 7, blockMouse: true, mode:"slow"})
            Sleep(Random(25,50))
            Click()
            Sleep(Random(25,50))
        }
        if (jsonRes[2].Get("id") != -1) {
            hosFruitDropPos2 := this.Config.Has("hosFruitDropPos2") ? ExtractCoords(this.Config.Get("hosFruitDropPos2")) : ""
            MouseMoveRandom(hosFruitDropPos2.x, hosFruitDropPos2.y, {offsetX: 7, blockMouse: true, mode:"slow"})
            Sleep(Random(25,50))
            Click()
            Sleep(Random(25,50))
        }
        Send("{Shift Up}")
    }

}