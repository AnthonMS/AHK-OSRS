#Requires AutoHotkey v2.0

#Include <Gui/Page>
; global FarmerPosition := {x: 0, y: 0}

class DraynorFarmersPage extends Page {
    __New(window:=false, name:="Draynor Master Farmer Thief") {
        super.__New(window, name)
        this.Config := this.GetConfig()  ; NOT THE SAME AS this.Window.Config

        this.Running := false
        this.Status := "Idle"
        this.StartTime := 0
        this.BreakTime := 0

        this.Worldpoints := []
        this.Worldpoints := JSON.Load(JSON.Dump(this.Worldpoints))

        this.Eating := false
        this.Dropping := false
        this.FarmerPosition := {x: 0, y: 0}
        this.LoopTask := ObjBindMethod(this, "ThisLoop")
        this.FindFarmerTask := ObjBindMethod(this, "FindFarmer")
    }
    GetConfig() {
        conf := FileReadOrCreate(A_ScriptDir "\Configs\DraynorMasterFarmers.config")
        if (conf == "") {
            return JSON.Load("{}")
        }
        return JSON.Load(conf)
    }
    SaveConfig(btn:=Object(), info:=Map()) {
        file := FileOpen(A_ScriptDir "\Configs\DraynorMasterFarmers.config", "w")
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
        this.AddElement("Text", "x35 y0 w200 h30 -Background", {name:"draynorFarmerStatus", text:this.Status, font:"s12"})
        this.AddElement("Button", "x0 y35 w50 h25 -Border", {name:"draynorFarmerStartBtn", text:"Start", eventName:"Click", cb:"StartTrainer"})
        this.AddElement("Button", "x55 y35 w50 h25 -Border", {name:"draynorFarmerStopBtn", text:"Stop", eventName:"Click", cb:"StopTrainer"})
        this.AddElement("Button", "x110 y35 w75 h25 -Border", {name:"draynorFarmerSetRectSize", text:"Set Rect Size", eventName:"Click", cb:"SetRectSize"})
        
        ; fkeysOnCaps := this.Window.Config.Has('fkeysOnCaps') ? this.Window.Config.Get('fkeysOnCaps') : ""
        ; if (fkeysOnCaps) {
        ;     this.Window.CreateFKeysOnCapslockKeybinds()
        ; }

        ; this.AddElement("Text", "x0 y75 w80 h25 +0x200 -Background", {text:"Scroll:"})
        ; this.AddElement("Edit", "x35 y75 w30 h20", {name:"draynorFarmerCamScroll", eventName:"Change", cb:"OnScrollEditChanged"})
        this.AddElement("Text", "x0 y75 w85 h25 +0x200 -Background", {text:"Drop IDs:"})
        this.AddElement("Edit", "x85 y75 w200 h20", {name:"edit-draynorFarmerDropIds", eventName:"Change", cb:"OnInputChanged"})

        this.AddElement("Text", "x0 y100 w85 h25 +0x200 -Background", {text:"Eat IDs:"})
        this.AddElement("Edit", "x85 y100 w200 h20", {name:"edit-draynorFarmerEatIds", eventName:"Change", cb:"OnInputChanged"})

        this.AddElement("Text", "x0 y125 w85 h25 +0x200 -Background", {text:"Min. Health:"})
        this.AddElement("Edit", "x85 y125 w200 h20", {name:"edit-draynorFarmerMinHealth", eventName:"Change", cb:"OnInputChanged"})

        this.AddElement("Text", "x0 y150 w85 h25 +0x200 -Background", {text:"Tile Marker Color:"})
        this.AddElement("Edit", "x85 y150 w200 h20", {name:"edit-draynorFarmerTileMarkerColor", eventName:"Change", cb:"OnInputChanged"})
        this.AddElement("Button", "x285 y150 w20 h20 -Border", {name:"draynorFarmerTileMarkerColor", text:"X", eventName:"Click", cb:"OnSetColorClicked"})
    }

    Update() {
        this.GetElement("draynorFarmerStartBtn").Enabled := !this.Running
        this.GetElement("draynorFarmerStopBtn").Enabled := this.Running
        this.GetElement("draynorFarmerStatus").Value := this.Status
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
        ; this.Config.Set(el.Name, el.Value)
        ; this.SaveConfig()
        ; this.Update()
    }
    
    OnInputChanged(el, info) {
        ; MyTip(el.Name " change to " el.Value)
        if (el.Name == "edit-draynorFarmerMinHealth") {
            if (!IsNumerical(el.Value)) {
                MyTip("Minimum Health can only be a numerical value!")
                return
            }
        }
        this.Config.Set(el.Name.Replace("edit-", ""), el.Value)
        this.SaveConfig()
        ; this.Update()
    }

    OnScrollEditChanged(el, info) {
        if (!IsNumerical(el.Value)) {
            ; inputField.Value := ""
            MyTip("Camera Scroll can only be numerical value")
        }
        else {
            ; this.Config.Set(el.Name, el.Value)
            ; this.SaveConfig()
        }
    }
    OnSetColorClicked(el, info) {
        MyTip("Click on Master Farmer Tile Filled With Tile Marker Color...", 10000)
        this.Window.FocusRuneliteWindow()
        
        Hotkey("LButton", (btn) => this.SetColorClick(btn, el.Name), "On")
    }
    SetColorClick(event, name) {
        Hotkey("LButton", "Off")
        MouseGetPos(&mouseX, &mouseY)
        color := PixelGetColor(mouseX, mouseY)
        this.Config.Set(name, color)
        this.SaveConfig()
        MyTip("Set " name " to " color)
        this.Update()
    }

    SetRectSize(btn, info:="") {
        this.Window.FocusRuneliteWindow()
        rlPos := this.Window.GetRuneliteWindowDimensions()
        ; colorSet := this.Config.Has("draynorFarmerTileMarkerColor") ? this.Config.Get("draynorFarmerTileMarkerColor") : "0x00FFFF"
        ; found2 := MyPixelSearch(0, 0, rlPos.Get("width"), rlPos.Get("height"), colorSet)
        ; if (found2) {
        ;     MouseMoveRandom(found2[1], found2[2], {offsetX: 0, offsetY: 0, blockMouse: true, mode:"custom:1"})
        ; }
        found := PixelSearch(&foundX, &foundY, 0, 0, rlPos.Get("width"), rlPos.Get("height"), "0x00FFFF")
        if (found) {
            rec := findRectangle(0x00FFFF, foundX, foundY)
            width := rec.p2.x - rec.p1.x
            height := rec.p2.y - rec.p1.y
            this.Config.Set("farmerRectWidth", width)
            this.Config.Set("farmerRectHeight", height)
            this.SaveConfig()
            MyTip("Width: " width " Height: " height, 5000)
        }
    }

    StopTrainer(el, info:="") {
        this.Running := false
        this.Status := "Stopped"
        this.StartTime := 0
        this.Update()
        SetTimer(this.FindFarmerTask, 0)
        SetTimer(this.LoopTask, 0)
        
        Hotkey("*Escape", "Off")
    }
    StartTrainer(el, info) {
        ; global FarmerPosition
        this.Window.FocusRuneliteWindow()
        this.Running := true
        this.Status := "Running"
        this.StartTime := A_TickCount
        this.BreakTime := 0
        this.Update()
        Hotkey("*Escape", (btn) => this.StopTrainer(btn), "On")

        SetTimer(this.FindFarmerTask, 1)
        SetTimer(this.LoopTask, 1)
        ; this.CheckHealth()
        ; 
    }

    ThisLoop() {
        if (A_TimeIdleMouse > 1000) {
            this.ClickFarmer()
        }
    }

    ClickFarmer() {
        ; global FarmerPosition
        this.Window.FocusRuneliteWindow()

        MouseGetPos(&mouseX, &mouseY)
        colorFound := PixelGetColor(mouseX, mouseY)
        colorSet := this.Config.Has("draynorFarmerTileMarkerColor") ? this.Config.Get("draynorFarmerTileMarkerColor") : "0x00FFFF"
        if (colorFound == colorSet) {
            Click()
            if (this.Window.IsInventoyFull()) {
                this.Dropping := true
                dropIds := this.Config.Has("draynorFarmerDropIds") ? this.Config.Get("draynorFarmerDropIds") : "5318,5308,5322,5305,5319,5324,5320,5323,5321,5307,5306,5309,5310,5311,5096,5098,5097,5099,5100,5101,5102,5103,5104,5105,5106,5282,5281,5280,21490,22873,5291,5292,5293,5294,5297"
                this.Window.DropItems(dropIds)
                this.Dropping := false
            }
            Sleep(Random(250,500))
            msg := this.Window.GetLatestIngameMessage()
            if (msg == "You've been stunned!" || msg == "You're stunned!" || msg == "You fail to pick the Master Farmer's pocket." || msg == "I can't reach that!") {
                ; MyTip("You're stunned!")
                this.Dropping := true
                dropIds := this.Config.Has("draynorFarmerDropIds") ? this.Config.Get("draynorFarmerDropIds") : "5318,5308,5322,5305,5319,5324,5320,5323,5321,5307,5306,5309,5310,5311,5096,5098,5097,5099,5100,5101,5102,5103,5104,5105,5106,5282,5281,5280,21490,22873,5291,5292,5293,5294,5297"
                this.Window.DropItems(dropIds)
                this.Dropping := false
                minHealth := this.Config.Has("draynorFarmerMinHealth") ? this.Config.Get("draynorFarmerMinHealth") : 20
                if (this.Window.CheckHealthLow(minHealth)) {
                    foodIds := this.Config.Has("draynorFarmerEatIds") ? this.Config.Get("draynorFarmerEatIds") : "361,373,379,385,7946"
                    foodIds := foodIds.Split(",", " ")
                    this.Eating := true
                    eatSuccess := this.Window.EatFood(foodIds)
                    if (!eatSuccess) {
                        this.StopTrainer("lol")
                        MsgBox("Stopped Master Farmer Trainer, you ran out of food to eat...")
                    }
                    this.Eating := false
                }
                Sleep(Random(400,900))
            }
            else {
                Sleep(Random(0,250))
            }
        }
        
    }

    FindFarmer() {
        ; global FarmerPosition
        rlPos := this.Window.GetRuneliteWindowDimensions()
        color := this.Config.Has("draynorFarmerTileMarkerColor") ? this.Config.Get("draynorFarmerTileMarkerColor") : "0x00FFFF"
        found := PixelSearch(&foundX, &foundY, 0, 0, rlPos.Get("width"), rlPos.Get("height"), color)
        
        ; found := MyPixelSearch(0, 0, rlPos.Get("width"), rlPos.Get("height"), color)
        ; if (!found) {
        ;     return
        ; }
        ; foundX := found[1], foundY := found[2]

        if (found) {
            posX := foundX
            ; posX := foundX + (this.Config.Get("farmerRectWidth") / 2)
            ; posY := foundY
            posY := foundY + 20
            ; posY := foundY + (this.Config.Get("farmerRectHeight") / 2)
            if (!this.Eating && !this.Dropping) {
                MouseMoveRandom(posX, posY, {offsetX: 10, offsetY: 10, blockMouse: true, mode:"normal"})
            }
        }
        else {
            this.FarmerPosition.x := 0
            this.FarmerPosition.y := 0
        }

        ; MyTip("X: " FarmerPosition.x " Y: " FarmerPosition.y, 1000)
        Sleep(1)
    }


}