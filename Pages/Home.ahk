#Requires AutoHotkey v2.0

; #Include ../../Lib/v2/gui/Page.ahk
#Include <Gui/Page>
; #Include ../../Lib/v2/JSON.ahk
; #Include ../../Lib/v2/Map.ahk

class HomePage extends Page {
    __New(window:=false, name:="Home") {
        super.__New(window, name)

        ; this.AddElement("Text", "x15 y15 w100 h25 +0x200 -Background", "Tester123")
        this.runeliteWindowTitles := GetWindowTitlesFromProcess("runelite.exe")
    }

    Show() {
        this.Window.Config := this.Window.GetConfig()
        super.Show()
        
        setRLBtn := this.GetElement("setRLBtn")
        windowSelect := this.GetElement("runeliteWindow")
        if (setRLBtn != false && windowSelect != false) {
            if (this.Window.Config.Has("runeliteWindow")) {
                if (windowSelect.Text == "") {
                    setRLBtn.Visible := false
                    setRLBtn.Enabled := false
                }
                else if (windowSelect.Text == this.Window.Config.Get("runeliteWindow")) {
                    rlDimensions := this.Window.GetRuneliteWindowDimensions()
                    if (this.Window.Config.Get("runeliteWidth") == rlDimensions.Get("width") &&
                        this.Window.Config.Get("runeliteHeight") == rlDimensions.Get("height")) {
                            setRLBtn.Visible := false
                            setRLBtn.Enabled := false
                        }
                }
            }
        }
        
        if (windowSelect != false) {
            loadSizeBtn := this.GetElement("loadSizeBtn")
            if (windowSelect.Text == "") {
                loadSizeBtn.Visible := false
                loadSizeBtn.Enabled := false
            }
            else {
                rlDimensions := this.Window.GetRuneliteWindowDimensions()
                if (this.Window.Config.Has("runeliteWidth") && this.Window.Config.Has("runeliteHeight")) {
                    if (this.Window.Config.Get("runeliteWidth") == rlDimensions.Get("width") &&
                        this.Window.Config.Get("runeliteHeight") == rlDimensions.Get("height")) {
                            if (loadSizeBtn != false) {
                                loadSizeBtn.Visible := false
                                loadSizeBtn.Enabled := false
                            }
                    }
                }
            }
        }
        
    }
    GoToSettings(btn:=Object(), info:=Map()) {
        this.Window.ShowPage("Settings")
    }
    GoToPrayerSwitch(btn:=Object(), info:=Map()) {
        this.Window.ShowPage("Calibrate Prayer Switch")
    }
    GoToFKeys(btn:=Object(), info:=Map()) {
        this.Window.ShowPage("Set F-Keys")
    }
    GoToSeersRooftop(btn:=Object(), info:=Map()) {
        this.Window.ShowPage("Seers' Rooftop Runner")
    }
    GoToHosFrutistalls(btn:=Object(), info:=Map()) {
        this.Window.ShowPage("Hosidious Fruitstall Trainer")
    }
    GoToDraynorFarmers(btn:=Object(), info:=Map()) {
        this.Window.ShowPage("Draynor Master Farmer Thief")
    }
    SaveConfig(btn:=Object(), info:=Map()) {
        this.Window.SaveConfig(btn, info)
    }

    Init() {
        this.AddElement("Button", "x0 y0 w20 h20 -Border", {name:"settingsBtn", text:"⚙️", eventName:"Click", cb:"GoToSettings"})
        
        stickyHelper := this.Window.Config.Has('stickyHelper') ? this.Window.Config.Get('stickyHelper') : ""
        this.AddElement("CheckBox", "x28 y3 w15 h15", {name:"stickyHelper", value:stickyHelper, text:"", eventName:"Click", cb:"StickyToggle"})
        windowSelect := this.AddElement("ComboBox", "x43 y0 w150 h30 +r3", {name:"runeliteWindow", content:this.runeliteWindowTitles, eventName:"Change", cb:"ChangeRuneliteWindow"})
        if (this.Window.Config.Has("runeliteWindow")) {
            foundIndex := this.runeliteWindowTitles.Find((v) => v == this.Window.Config.Get("runeliteWindow"), &titleMatch)
            if (foundIndex) {
                windowSelect.Choose(foundIndex)
                this.ChangeRuneliteWindow(windowSelect)
            }
        }
        this.AddElement("Text", "x195 y1 w15 h15 0x200", {name:"refreshWindowListBtn", text:"⟳", eventName:"Click", cb:"RefreshWindowList", font:"s16"})
            
        this.AddElement("Text", "x245 y0 w15 h20 0x200", {name:"setRLBtn", text:"Set", eventName:"Click", cb:"SetRuneliteWindow"})
        this.AddElement("Text", "x265 y-2 w2 h20 0x200", {text:"|", font:"s10 c0xb8b8b8"})
        this.AddElement("Text", "x272 y0 w45 h20 0x200", {name:"loadSizeBtn", text:"Load size", eventName:"Click", cb:"LoadRuneliteSize"})

        
        fkeysOnCaps := this.Window.Config.Has('fkeysOnCaps') ? this.Window.Config.Get('fkeysOnCaps') : ""
        if (fkeysOnCaps) {
            this.Window.CreateFKeysOnCapslockKeybinds()
        }
        this.AddElement("CheckBox", "x3 y25 w115 h30", {name:"fkeysOnCaps", text:" F-keys on Capslock", value:fkeysOnCaps, eventName:"Click", cb:"FKeyToggle"})
        this.AddElement("Text", "x118 y25 w20 h25 0x200", {name:"calibrateFKeysBtn", text:"🎯", eventName:"Click", cb:"GoToFKeys", font:"s12"})
        prayerSwitchHotkeys := this.Window.Config.Has('prayerSwitchHotkeys') ? this.Window.Config.Get('prayerSwitchHotkeys') : ""
        if (prayerSwitchHotkeys) {
            this.Window.CreatePrayerSwitchKeybinds()
        }
        this.AddElement("CheckBox", "x140 y25 w110 h30", {name:"prayerSwitchHotkeys", text:" Prayer switch keys", value:prayerSwitchHotkeys, eventName:"Click", cb:"PrayerSwitchToggle"})
        this.AddElement("Text", "x250 y25 w20 h25 0x200", {name:"calibratePrayerSwitchBtn", text:"🎯", eventName:"Click", cb:"GoToPrayerSwitch", font:"s12"})


        this.AddElement("Button", "x0 y75 w150 h25 -Border +Left", {name:"agilitySeersRooftopBtn", text:" Seers' Rooftop Runner", eventName:"Click", cb:"GoToSeersRooftop"})
        this.AddElement("Button", "x0 y105 w150 h25 -Border +Left", {name:"hosidiousFruitstallsBtn", text:" Hosidious Fruitstall Trainer", eventName:"Click", cb:"GoToHosFrutistalls"})
        this.AddElement("Button", "x0 y135 w150 h25 -Border +Left", {name:"draynorFarmersBtn", text:" Draynor Farmers Trainer", eventName:"Click", cb:"GoToDraynorFarmers"})
    }

    Tester(btn, info) {
        MyTip("Testing123")
        ; MsgBox(this.Window.RuneliteTitle)
        this.Window.FocusRuneliteWindow()
        activeMenu := this.Window.FindActiveIngameMenu()
    }

    RefreshWindowList(btn, info) {
        MyTip("Refreshing window list")
        combobox := this.GetElement("runeliteWindow")
        combobox.Delete()
        this.runeliteWindowTitles := GetWindowTitlesFromProcess("runelite.exe")
        if (this.runeliteWindowTitles.Length > 0) {
            combobox.Add(this.runeliteWindowTitles)
            
            if (this.Window.Config.Has("runeliteWindow")) {
                foundIndex := this.runeliteWindowTitles.Find((v) => v == this.Window.Config.Get("runeliteWindow"), &titleMatch)
                if (foundIndex) {
                    combobox.Choose(foundIndex)
                    ;; Attach hooks to window
                    this.Window.AddRuneliteHooks(this.Window.Config.Get("runeliteWindow"))
                }
                else {
                    combobox.Choose(1)
                }
            }
            else {
                combobox.Choose(1)
            }
            this.ChangeRuneliteWindow(combobox)
        }
    }

    StickyToggle(el, info) {
        this.Window.Config.Set(el.Name, el.Value)
        this.Window.Sticky := el.Value
        if (el.Value) {
            this.Window.StickyHelper()
        }
        this.SaveConfig()
    }

    FKeyToggle(el, info) {
        this.Window.Config.Set(el.Name, el.Value)
        if (el.Value) {
            this.Window.CreateFKeysOnCapslockKeybinds()
        }
        else {
            this.Window.RemoveFKeysOnCapslockKeybinds()
        }
        this.SaveConfig()
    }

    PrayerSwitchToggle(el, info) {
        this.Window.Config.Set(el.Name, el.Value)
        if (el.Value) {
            this.Window.CreatePrayerSwitchKeybinds()
        }
        else {
            this.Window.RemovePrayerSwitchKeybinds()
        }
        this.SaveConfig()
    }

    LoadRuneliteSize(btn, info) {
        windowSelect := this.GetElement("runeliteWindow")
        if (windowSelect != false) {
            winTitle := windowSelect.Text
            currentPos := this.Window.GetRuneliteWindowDimensions()
            newWidth := this.Window.Config.Get("runeliteWidth")
            newHeight := this.Window.Config.Get("runeliteHeight")
            
            screenWidth := SysGet(78)
            screenHeight := SysGet(79) - SysGet(4) - 25
            ; Calculate the new X and Y coordinates to keep the center position
            newX := currentPos.Get("x") - (newWidth - currentPos.Get("width")) // 2
            newY := currentPos.Get("y") - (newHeight - currentPos.Get("height")) // 2

            ; Check if the new window size goes beyond the screen dimensions
            if (newX + newWidth > screenWidth) {
                newX := screenWidth - newWidth
            }
            if (newY + newHeight > screenHeight) {
                newY := screenHeight - newHeight
            }
            if (newX < 0) {
                newX := 0
            }
            if (newY < 0) {
                newY := 0
            }
            WinMove(newX,newY,newWidth,newHeight,winTitle)

            setRLBtn := this.GetElement("setRLBtn")
            if (setRLBtn != false) {
                setRLBtn.Visible := false
                setRLBtn.Enabled := false
            }
            loadSizeBtn := this.GetElement("loadSizeBtn")
            if (loadSizeBtn != false) {
                loadSizeBtn.Visible := false
                loadSizeBtn.Enabled := false
            }
        }
    }

    SetRuneliteSize(btn, info) {
        currentDimensions := this.Window.GetRuneliteWindowDimensions()
        currentWidth := currentDimensions.Get("width"), currentHeight := currentDimensions.Get("height"), currentX := currentDimensions.Get("x"), currentY := currentDimensions.Get("y")
        setWidth := this.Window.Config.Has("runeliteWidth") ? this.Window.Config.Get("runeliteWidth") : -1
        setHeight := this.Window.Config.Has("runeliteHeight") ? this.Window.Config.Get("runeliteHeight") : -1
        if (!this.Window.Config.Has("runeliteWidth") || !this.Window.Config.Has("runeliteHeight")) {
            this.Window.Config.Set("runeliteX", currentX)
            this.Window.Config.Set("runeliteY", currentY)
            this.Window.Config.Set("runeliteWidth", currentWidth)
            this.Window.Config.Set("runeliteHeight", currentHeight)
        }
        else if (currentWidth != setWidth || currentHeight != setHeight) {
            confirmResult := MsgBox("The new runelite size is different from the set size." . "`n`nDo you want to proceed and apply the new size?", "Confirm Window Size Change", "YesNoCancel")
            if (confirmResult == "Yes") {
                this.Window.Config.Set("runeliteX", currentX)
                this.Window.Config.Set("runeliteY", currentY)
                this.Window.Config.Set("runeliteWidth", currentWidth)
                this.Window.Config.Set("runeliteHeight", currentHeight)
            }
        }
    }

    SetRuneliteWindow(btn, info) {
        if (this.Window.Config.Has("runeliteWindow")) {
            this.Window.RemoveRuneliteHooks()
        }

        windowSelect := this.GetElement("runeliteWindow")
        if (windowSelect != false) {
            this.Window.Config.Set("runeliteWindow", windowSelect.Text)
        }

        ; TODO: Create confirm window so we can choose to overwrite size if it is different.
        this.SetRuneliteSize(btn,info)

        this.SaveConfig()
        MyTip("Runelite Title & Size has been set")

        setRLBtn := this.GetElement("setRLBtn")
        if (setRLBtn != false) {
            setRLBtn.Visible := false
            setRLBtn.Enabled := false
        }
        loadSizeBtn := this.GetElement("loadSizeBtn")
        if (loadSizeBtn != false) {
            loadSizeBtn.Visible := false
            loadSizeBtn.Enabled := false
        }

        this.Window.AddRuneliteHooks(this.Window.Config.Get("runeliteWindow"))
    }


    ChangeRuneliteWindow(el, info:=Object()) {
        rlDimensions := this.Window.GetRuneliteWindowDimensions()
        setRLBtn := this.GetElement("setRLBtn")
        showSetBtn := true
        if (this.Window.Config.Has("runeliteWindow")) {
            if (this.Window.Config.Get("runeliteWindow") == el.Text && 
                this.Window.Config.Get("runeliteWidth") == rlDimensions.Get("width") &&
                this.Window.Config.Get("runeliteHeight") == rlDimensions.Get("height")) {
                if (setRLBtn != false) {
                    showSetBtn := false
                    setRLBtn.Visible := false
                    setRLBtn.Enabled := false
                }
                ; return ; Dont go further if changing to already configured window
            }
        }
        if (showSetBtn) {
            if (setRLBtn != false) {
                setRLBtn.Visible := true
                setRLBtn.Enabled := true
            }
        }


        loadSizeBtn := this.GetElement("loadSizeBtn")
        showLoadSizeBtn := true
        if (this.Window.Config.Has("runeliteWidth") && this.Window.Config.Has("runeliteHeight")) {
            if (this.Window.Config.Get("runeliteWidth") == rlDimensions.Get("width") &&
                this.Window.Config.Get("runeliteHeight") == rlDimensions.Get("height")) {
                    showLoadSizeBtn := false
                }
        }
        if (loadSizeBtn != false) {
            loadSizeBtn.Visible := showLoadSizeBtn
            loadSizeBtn.Enabled := showLoadSizeBtn
        }
        this.Window.RuneliteTitle := el.Text
    }

    RuneliteResizeEvent(dimensions) {
        loadSizeBtn := this.GetElement("loadSizeBtn")
        setRLBtn := this.GetElement("setRLBtn")
        if (this.Window.Config.Has("runeliteWindow")) {
            if (setRLBtn != false) {
                setRLBtn.Visible := true
                setRLBtn.Enabled := true
            }
            if (loadSizeBtn != false) {
                loadSizeBtn.Visible := true
                loadSizeBtn.Enabled := true
            }
        }
    }

}