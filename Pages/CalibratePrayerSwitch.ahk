#Requires AutoHotkey v2.0

#Include <Gui/Page>

class CalibratePrayerSwitch extends Page {
    __New(window:=false, name:="Calibrate Prayer Switch") {
        super.__New(window, name)

        ; ; this.AddElement("Text", "x15 y15 w100 h25 +0x200 -Background", "Tester123")
        ; this.runeliteWindowTitles := GetWindowTitlesFromProcess("runelite.exe")

    }

    Show() {
        this.Window.Config := this.Window.GetConfig()
        super.Show()

        this.LoadConfiguration()
    }

    GoBack(el, info) {
        this.Window.ShowPage("Home")
    }

    SaveConfig(btn:=Object(), info:=Map()) {
        this.Window.SaveConfig(btn, info)
    }

    Init() {
        imgPath := A_ScriptDir "\Assets\prayer-icons\"
        this.AddElement("Button", "x0 y0 w20 h20 -Border", {name:"backFromCalibratePrayerSwitch", text:"←", eventName:"Click", cb:"GoBack"})
        
        this.AddElement("Picture", "x5 y35 w25 h25", {name:"protectMagic", path: imgPath "Protect_From_Magic.png", eventName:"Click", cb:"OnCalibratePrayer"})
        this.AddElement("Text", "x45 y25 w40 h20 +0x200 -Background", {text:"Position:"})
        this.AddElement("Text", "x90 y25 w50 h20 +0x200 -Background", {name:"position-protectMagic", text:""})
        this.AddElement("Text", "x45 y45 w40 h20 +0x200 -Background", {text:"Keybind:"})
        this.AddElement("Text", "x90 y45 w50 h20 +0x200 -Background", {name:"keybind-protectMagic", text:"No Key", eventName:"Click", cb:"OnSetPrayerHotkey"})
        
        this.AddElement("Picture", "x5 y80 w25 h25", {name:"protectMelee", path: imgPath "Protect_From_Melee.png", eventName:"Click", cb:"OnCalibratePrayer"})
        this.AddElement("Text", "x45 y70 w40 h20 +0x200 -Background", {text:"Position:"})
        this.AddElement("Text", "x90 y70 w50 h20 +0x200 -Background", {name:"position-protectMelee", text:""})
        this.AddElement("Text", "x45 y90 w40 h20 +0x200 -Background", {text:"Keybind:"})
        this.AddElement("Text", "x90 y90 w50 h20 +0x200 -Background", {name:"keybind-protectMelee", text:"No Key", eventName:"Click", cb:"OnSetPrayerHotkey"})

        
        this.AddElement("Picture", "x160 y35 w25 h25", {name:"protectMissiles", path: imgPath "Protect_From_Missiles.png", eventName:"Click", cb:"OnCalibratePrayer"})
        this.AddElement("Text", "x200 y25 w40 h20 +0x200 -Background", {text:"Position:"})
        this.AddElement("Text", "x245 y25 w50 h20 +0x200 -Background", {name:"position-protectMissiles", text:""})
        this.AddElement("Text", "x200 y45 w40 h20 +0x200 -Background", {text:"Keybind:"})
        this.AddElement("Text", "x245 y45 w50 h20 +0x200 -Background", {name:"keybind-protectMissiles", text:"No Key", eventName:"Click", cb:"OnSetPrayerHotkey"})

    }

    LoadConfiguration() {
        currentPos := this.Window.GetRuneliteWindowDimensions()
        
        for (el in this.Elements) {
            if (InStr(el.Name, "position-") == 1) {
                prayerName := StrReplace(el.Name, "position-", "")
                if (this.Window.Config.Has(prayerName)) {
                    thisConf := this.Window.Config.Get(prayerName)
                    if (thisConf.Has("x") && thisConf.Has("y") && thisConf.Has("windowWidth") && thisConf.Has("windowHeight")) {
                        if (el != false) {
                            el.Text := thisConf.Get("x") ", " thisConf.Get("y")
                        }
                        if (currentPos) {
                            if (currentPos.Get("width") != thisConf.Get("windowWidth") ||
                                currentPos.Get("height") != thisConf.Get("windowHeight")) {
                                    el.SetFont("c0xfc0303")
                            }
                            else {
                                el.SetFont("c0x008216")
                            }
                        }
                    }
                    else {
                        el.Text := "Not Calibrated"
                        el.SetFont("c0xfc0303")
                    }
                }
            }
            if (InStr(el.Name, "keybind-") == 1) {
                prayerName := StrReplace(el.Name, "keybind-", "")
                if (this.Window.Config.Has(prayerName)) {
                    thisConf := this.Window.Config.Get(prayerName)
                    if (thisConf.Has("keybind")) {
                        el.Text := thisConf.Get("keybind")
                        el.SetFont("c0x008216")
                    }
                    else {
                        el.Text := "No key"
                        el.SetFont("c0xfc0303")
                    }
                }
            }
        }
    }

    OnSetPrayerHotkey(btn, info) {
        prayerName := StrReplace(btn.Name, "keybind-", "")
        if (this.Window.Config.Has(prayerName)) {
            thisConf := this.Window.Config.Get(prayerName)
            if (thisConf.Has("keybind")) {
                confirm := MsgBox("Hotkey already set " prayerName . "`n`nDo you want to overwrite old hotkey?", "Confirm Hotkey Change", "YesNoCancel")
                if (confirm == "Yes") {
                    this.CreateHotkeyListener(prayerName)
                }
            }
            else {
                this.CreateHotkeyListener(prayerName)
            }
        }
        else {
            this.CreateHotkeyListener(prayerName)
        }
    }
    CreateHotkeyListener(prayerName) {
        MyTip("Listening for hotkey...", 100000)
        this.hotkeyHook := InputHook()
        this.hotkeyHook.KeyOpt("{All}", "NS")
        this.hotkeyHook.OnKeyDown := ObjBindMethod(this, "HotkeyListener", prayerName)
        this.hotkeyHook.Start()
    }

    HotkeyListener(prayerName, hook, vk, sc) {
        this.hotkeyHook.Stop()
        this.hotkeyHook.OnKeyDown:= ""
        keyname := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
        keycode := GetKeyVK(Format("vk{:x}sc{:x}", vk, sc))
        MyTip("Caught: " keyname)
        if (this.Window.Config.Has(prayerName)) {
            this.Window.Config[prayerName].Set("keybind", keyname)
            this.Window.Config[prayerName].Set("keycode", keycode)
        }
        else {
            this.Window.Config.Set(prayerName, Map("keybind", keyname, "keycode", keycode))
        }
        this.Window.SaveConfig()
        this.LoadConfiguration()
        ; this.Window.TogglePrayerSwitchKeybinds()
        this.Window.CreatePrayerSwitchKeybinds()
    }

    
    OnCalibratePrayer(el, eventInfo) {
        focus := this.Window.FocusRuneliteWindow()
        if (focus) {
            ; Switch to prayer menu item with set hotkey
            prayerName := StrReplace(el.Name, "position-", "")
            prayerConf := this.Window.Config.Has("menu-prayer") ? this.Window.Config.Get("menu-prayer") : false
            if (!prayerConf) {
                MsgBox("You must configure your F-Keys first.")
                return
            }
            if (!prayerConf.Has("keybind")) {
                MsgBox("You must configure your F-Keys first.")
                return
            }
            Send("{" prayerConf.Get("keybind") "}")
            MyTip("Waiting for mouse click...", 100000)
            Hotkey("LButton", (btn) => this.Calibrate(btn, prayerName), "On")
        }
    }
    Calibrate(event, prayerName) {
        Hotkey("LButton", "Off")
        MouseGetPos(&mouseX, &mouseY)
        MyTip("Caught: " mouseX "," mouseY)
        rlPos := this.Window.GetRuneliteWindowDimensions()
        data := Map()
        if (this.Window.Config.Has(prayerName)) {
            if (this.Window.Config.Get(prayerName).Has("keybind")) {
                data.Set("keybind", this.Window.Config.Get(prayerName).Get("keybind"))
            }
        }
        data.Set("windowWidth", rlPos.Get("width"))
        data.Set("windowHeight", rlPos.Get("height"))
        data.Set("x", mouseX)
        data.Set("y", mouseY)
        this.Window.Config.Set(prayerName, data)
        this.Window.SaveConfig()

        this.LoadConfiguration()
        ; this.Window.RemovePrayerSwitchKeybinds()
        ; this.Window.CreatePrayerSwitchKeybinds()
        ; this.Window.TogglePrayerSwitchKeybinds()
    }
}