#Requires AutoHotkey v2.0

#Include <Gui/Page>

class SetFKeys extends Page {
    __New(window:=false, name:="Set F-Keys") {
        super.__New(window, name)

        ; ; this.AddElement("Text", "x15 y15 w100 h25 +0x200 -Background", "Tester123")
        ; this.runeliteWindowTitles := GetWindowTitlesFromProcess("runelite.exe")

        this.keySelection := ["None","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12","ESC"]
    }

    Show() {
        this.Window.Config := this.Window.GetConfig()
        super.Show()
        this.LoadSelectionsFromConfig()
        this.LoadPositionsFromConfig()
    }

    Init() {
        imgPath := A_ScriptDir "\Assets\menu-icons\"
        this.AddElement("Button", "x0 y0 w20 h20 -Border", {name:"backFromSetFKeys", text:"←", eventName:"Click", cb:"GoBack"})

        ; this.AddElement("Text", "x0 y25 w400 h20 +0x200 -Background", args:=Map("name","testText", "text","Test Text 123: " A_ScriptDir))
        this.AddElement("Picture", "x5 y30 w40 h42", {name:"combatIcon", path: imgPath "combat.png"})
        this.AddElement("Picture", "x5 y80 w40 h42", {name:"statsIcon", path: imgPath "stats.png"})
        this.AddElement("Picture", "x5 y130 w40 h42", {name:"questIcon", path: imgPath "quest.png"})
        this.AddElement("Picture", "x5 y180 w40 h42", {name:"invIcon", path: imgPath "inv.png"})
        this.AddElement("Picture", "x5 y230 w40 h42", {name:"equipIcon", path: imgPath "equip.png"})
        this.AddElement("Picture", "x5 y280 w40 h42", {name:"settingsIcon", path: imgPath "settings.png"})
        this.AddElement("Picture", "x5 y330 w40 h42", {name:"emoteIcon", path: imgPath "emotes.png"})
        this.AddElement("ComboBox", "x60 y30 w50 h30 +r10", {name:"keybind-combat", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("ComboBox", "x60 y80 w50 h30 +r10", {name:"keybind-stats", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("ComboBox", "x60 y130 w50 h30 +r10", {name:"keybind-quest", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("ComboBox", "x60 y180 w50 h30 +r10", {name:"keybind-inv", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("ComboBox", "x60 y230 w50 h30 +r10", {name:"keybind-equip", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("ComboBox", "x60 y280 w50 h30 +r10", {name:"keybind-settings", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("ComboBox", "x60 y330 w50 h30 +r10", {name:"keybind-emote", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("Text", "x60 y55 w70 h15 +0x200 -Background", {name:"position-combat", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        this.AddElement("Text", "x60 y105 w70 h15 +0x200 -Background", {name:"position-stats", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        this.AddElement("Text", "x60 y155 w70 h15 +0x200 -Background", {name:"position-quest", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        this.AddElement("Text", "x60 y205 w70 h15 +0x200 -Background", {name:"position-inv", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        this.AddElement("Text", "x60 y255 w70 h15 +0x200 -Background", {name:"position-equip", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        this.AddElement("Text", "x60 y305 w70 h15 +0x200 -Background", {name:"position-settings", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        this.AddElement("Text", "x60 y355 w70 h15 +0x200 -Background", {name:"position-emote", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        
        this.AddElement("Picture", "x155 y30 w40 h42", {name:"prayerIcon", path: imgPath "prayer.png"})
        this.AddElement("Picture", "x155 y80 w40 h42", {name:"magicIcon", path: imgPath "magic.png"})
        this.AddElement("Picture", "x155 y130 w40 h42", {name:"friendIcon", path: imgPath "friends.png"})
        this.AddElement("Picture", "x155 y180 w40 h42", {name:"clanIcon", path: imgPath "clan.png"})
        this.AddElement("Picture", "x155 y230 w40 h42", {name:"doorIcon", path: imgPath "door.png"})
        this.AddElement("Picture", "x155 y280 w40 h42", {name:"ignoreIcon", path: imgPath "ignore.png"})
        this.AddElement("Picture", "x155 y330 w40 h42", {name:"musicIcon", path: imgPath "music.png"})
        this.AddElement("ComboBox", "x210 y30 w50 h30 +r10", {name:"keybind-prayer", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("ComboBox", "x210 y80 w50 h30 +r10", {name:"keybind-magic", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("ComboBox", "x210 y130 w50 h30 +r10", {name:"keybind-friend", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("ComboBox", "x210 y180 w50 h30 +r10", {name:"keybind-clan", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("ComboBox", "x210 y230 w50 h30 +r10", {name:"keybind-door", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("ComboBox", "x210 y280 w50 h30 +r10", {name:"keybind-ignore", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("ComboBox", "x210 y330 w50 h30 +r10", {name:"keybind-music", content:this.keySelection, eventName:"Change", cb:"ChangeKeybind"})
        this.AddElement("Text", "x210 y55 w70 h15 +0x200 -Background", {name:"position-prayer", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        this.AddElement("Text", "x210 y105 w70 h15 +0x200 -Background", {name:"position-magic", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        this.AddElement("Text", "x210 y155 w70 h15 +0x200 -Background", {name:"position-friend", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        this.AddElement("Text", "x210 y205 w70 h15 +0x200 -Background", {name:"position-clan", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        this.AddElement("Text", "x210 y255 w70 h15 +0x200 -Background", {name:"position-door", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        this.AddElement("Text", "x210 y305 w70 h15 +0x200 -Background", {name:"position-ignore", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        this.AddElement("Text", "x210 y355 w70 h15 +0x200 -Background", {name:"position-music", text:"PosX, PosY", eventName:"Click", cb:"ClickPos"})
        
        ; this.AddElement("Picture", "x105 y230 w40 h42", {name:"doorIcon", path: imgPath ".png"})

    }

    LoadPositionsFromConfig() {
        currentPos := this.Window.GetRuneliteWindowDimensions()
        for (el in this.Elements) {
            if (InStr(el.Name, "position-") == 1) {
                menuKey := StrReplace(el.Name, "position-", "menu-")
                thisConf := this.Window.Config.Has(menuKey) ? this.Window.Config.Get(menuKey) : Map()
                el.Text := thisConf.Has("position") ? thisConf.Get("position") : "Missing"
                if (el.Text == "Missing") {
                    el.SetFont("c0xfc0303")
                }
                else if (currentPos) {
                    if (currentPos.Get("width") != thisConf.Get("windowWidth") ||
                        currentPos.Get("height") != thisConf.Get("windowHeight")) {
                            el.SetFont("c0xfc0303")
                            el.Text := "No match"
                    }
                    else {
                        el.SetFont("c0x008216")
                    }
                }
            }
        }
    }

    LoadSelectionsFromConfig() {
        for (el in this.Elements) {
            if (InStr(el.Name, "keybind-") == 1) {
                menuKey := StrReplace(el.Name, "keybind-", "menu-")
                if (this.Window.Config.Has(menuKey)) {
                    el.Value := this.Window.Config.Get(menuKey).Has("keybind") ? this.keySelection.IndexOf(this.Window.Config.Get(menuKey).Get("keybind")) : 1
                }
            }
        }
    }

    ClickPos(el, info) {
        windowTitle := this.Window.GetRuneliteTitle()
        
        if (windowTitle) {
            if (el.Text == "No match" || el.Text == "Missing") {
                focus := this.Window.FocusRuneliteWindow()
                if (focus) {
                    menuKey := StrReplace(el.Name, "position-", "menu-")
                    MyTip("Click around " StrReplace(menuKey, "menu-", "") " icon to get on/off colors", 10000)
                    Hotkey("LButton", (btn) => this.CalibratePos(btn, el.Name), "On")
                }
            }
            else {
                confirm := MsgBox("Position already set" . "`n`nDo you want to overwrite old position?", "Confirm Position Change", "YesNoCancel")
                if (confirm == "Yes") {
                    focus := this.Window.FocusRuneliteWindow()
                    if (focus) {
                        menuKey := StrReplace(el.Name, "position-", "menu-")
                        MyTip("Click around " StrReplace(menuKey, "menu-", "") " icon to get on/off colors", 10000)
                        Hotkey("LButton", (btn) => this.CalibratePos(btn, el.Name), "On")
                    }
                }
            }
        }
    }
    
    CalibratePos(event, name) {
        Hotkey("LButton", "Off")
        MouseGetPos(&mouseX, &mouseY)
        rlPos := this.Window.GetRuneliteWindowDimensions()

        menuKey := StrReplace(name, "position-", "menu-")
        randKey := this.Window.Config.Has("menu-inv") ? this.Window.Config.Get("menu-inv").Get("keybind") : false
        if (menuKey == "menu-inv") {
            randKey := this.Window.Config.Has("menu-combat") ? this.Window.Config.Get("menu-combat").Get("keybind") : false
        }

        Send("{" randKey "}")
        Sleep(50)
        colorOff := PixelGetColor(mouseX, mouseY)
        Sleep(50)
        Click()
        Sleep(50)
        colorOn := PixelGetColor(mouseX, mouseY)
        ; pos := mouseX "," mouseY
        data := Map()
        data.Set("windowWidth", rlPos.Get("width"))
        data.Set("windowHeight", rlPos.Get("height"))
        data.Set("position", mouseX "," mouseY)
        data.Set("colorOff", colorOff)
        data.Set("colorOn", colorOn)
        if (this.Window.Config.Has(menuKey)) {
            if (this.Window.Config.Get(menuKey).Has("keybind")) {
                data.Set("keybind", this.Window.Config.Get(menuKey).Get("keybind"))
            }
        }
        ; data.Set("y", mouseY)
        this.Window.Config.Set(menuKey, data)
        this.Window.SaveConfig()
        MyTip(StrReplace(menuKey, "menu-", "") " configured")

        this.LoadPositionsFromConfig()
        ; this.Window.RemoveFKeysOnCapslockKeybinds()
        ; this.Window.CreateFKeysOnCapslockKeybinds()
    }

    ChangeKeybind(el, info) {
        menuKey := StrReplace(el.Name, "keybind-", "menu-")
        MyTip(el.Name " - " el.Value, 1000)
        if (el.Text == "None" && this.Window.Config.Has(menuKey)) {
            if (this.Window.Config.Get(menuKey).Has("keybind")) {
                this.Window.Config[menuKey].Delete("keybind")
            }
        }
        else {
            data := Map()
            data.Set("keybind", el.Text)
            if (this.Window.Config.Has(menuKey)) {
                thisConfig := this.Window.Config.Get(menuKey)
                if (thisConfig.Has("colorOff")) {
                    data.Set("colorOff", thisConfig.Get("colorOff"))
                }
                if (thisConfig.Has("colorOn")) {
                    data.Set("colorOn", thisConfig.Get("colorOn"))
                }
                if (thisConfig.Has("position")) {
                    data.Set("position", thisConfig.Get("position"))
                }
                if (thisConfig.Has("windowHeight")) {
                    data.Set("windowHeight", thisConfig.Get("windowHeight"))
                }
                if (thisConfig.Has("windowWidth")) {
                    data.Set("windowWidth", thisConfig.Get("windowWidth"))
                }
            }
            this.Window.Config.Set(menuKey, data)
        }
        this.SaveConfig()
    }

    GoBack(el, info) {
        this.Window.ShowPage("Home")
    }

    SaveConfig(btn:=Object(), info:=Map()) {
        this.Window.SaveConfig(btn, info)
    }
}