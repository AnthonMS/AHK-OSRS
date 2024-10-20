#Requires AutoHotkey v2.0

#Include <Gui/Page>

class SettingsPage extends Page {
    __New(window:=false, name:="Settings") {
        super.__New(window, name)
    }

    Show() {
        this.Window.Config := this.Window.GetConfig()
        super.Show()
        this.TestSetttings()
    }

    Init() {
        this.AddElement("Button", "x0 y0 w20 h20 -Border", {name:"backFromSettingsBtn", text:"←", eventName:"Click", cb:"GoBack"})
        
        this.AddElement("Text", "x0 y25 w200 h20 +0x200 -Background", {text:"Runelite Settings Path:"})
        this.AddElement("Edit", "x0 y45 w260 h20", {name:"edit-runeliteSettingsPath", eventName:"Change", cb:"InputFieldChanged"})
        this.AddElement("Text", "x265 y45 w15 h20 +0x200 -Background", {name:"runeliteSettingsPathSuccess", text:"❌", font:"c0xfc0303"})

        this.AddElement("Text", "x0 y85 w200 h20 +0x200 -Background", {text:"Runelite HTTP Plugin Path  - Stats:"})
        this.AddElement("Text", "x0 y110 w55 h20 +0x200 -Background", {text:"Stats:"})
        this.AddElement("Edit", "x55 y110 w205 h20", {name:"edit-httpPluginPathStats", eventName:"Change", cb:"InputFieldChanged"})
        this.AddElement("Text", "x265 y110 w15 h20 +0x200 -Background", {name:"httpPluginPathStatsSuccess", text:"❌", font:"c0xfc0303"})

        this.AddElement("Text", "x0 y135 w55 h20 +0x200 -Background", {text:"Events:"})
        this.AddElement("Edit", "x55 y135 w205 h20", {name:"edit-httpPluginPathEvents", eventName:"Change", cb:"InputFieldChanged"})
        this.AddElement("Text", "x265 y135 w15 h20 +0x200 -Background", {name:"httpPluginPathEventsSuccess", text:"❌", font:"c0xfc0303"})

        this.AddElement("Text", "x0 y160 w55 h20 +0x200 -Background", {text:"Inventory:"})
        this.AddElement("Edit", "x55 y160 w205 h20", {name:"edit-httpPluginPathInv", eventName:"Change", cb:"InputFieldChanged"})
        this.AddElement("Text", "x265 y160 w15 h20 +0x200 -Background", {name:"httpPluginPathInvSuccess", text:"❌", font:"c0xfc0303"})

        this.AddElement("Text", "x0 y185 w55 h20 +0x200 -Background", {text:"Equipment:"})
        this.AddElement("Edit", "x55 y185 w205 h20", {name:"edit-httpPluginPathEquip", eventName:"Change", cb:"InputFieldChanged"})
        this.AddElement("Text", "x265 y185 w15 h20 +0x200 -Background", {name:"httpPluginPathEquipSuccess", text:"❌", font:"c0xfc0303"})
        
        this.AddElement("CheckBox", "x3 y210 w155 h30", {name:"stickyRight", text:" Prefer Right Side Sticky", eventName:"Click", cb:"StickyRight"})

        this.AddElement("Text", "x0 y245 w120 h20 +0x200 -Background", {text:"Inventory Slot 1 Position:"})
        this.AddElement("Edit", "x125 y245 w60 h20", {name:"edit-invSlot1Pos", eventName:"Change", cb:"InputFieldChanged"})
        this.AddElement("Button", "x190 y245 w20 h20 -Border", {name:"invSlot1Pos", text:"X", eventName:"Click", cb:"OnSetPosClicked"})
    }

    Update() {
        for (el in this.Elements) {
            if (InStr(el.Name, "edit-") == 1) {
                configName := StrReplace(el.Name, "edit-", "")
                if (this.Window.Config.Has(configName)) {
                    el.Value := this.Window.Config.Get(configName)
                }
            }
        }
        this.GetElement("stickyRight").Value := this.Window.Config.Has('stickyRight') ? this.Window.Config.Get('stickyRight') : ""
    }
    OnSetPosClicked(el, info) {
        MyTip("Click on position inside runelite", 5000)
        this.Window.FocusRuneliteWindow()
        
        Hotkey("LButton", (btn) => this.SetPosClick(btn, el.Name), "On")
    }
    SetPosClick(event, name) {
        Hotkey("LButton", "Off")
        MouseGetPos(&mouseX, &mouseY)
        pos := mouseX "," mouseY
        this.Window.Config.Set(name, pos)
        this.SaveConfig()
        MyTip("Set " name " to " pos)
        this.Update()
    }

    TestSetttings() {
        oOptions := Map()
        oOptions["SslError"] := false
        oOptions["UA"] := "Autohotkey-lol"
        http := WinHttpRequest(oOptions)

        runeliteSettingsPath := this.Window.Config.Has('runeliteSettingsPath') ? this.Window.Config.Get('runeliteSettingsPath') : ""
        if (runeliteSettingsPath != "") {
            runeliteSettingsPathSuccess := this.GetElement("runeliteSettingsPathSuccess")
            if (FileExist(runeliteSettingsPath)) {
                runeliteSettingsPathSuccess.Text := "✔️"
                runeliteSettingsPathSuccess.SetFont("c0x5afc03")
            }
            else {
                runeliteSettingsPathSuccess.Text := "❌"
                runeliteSettingsPathSuccess.SetFont("c0xfc0303")

            }
        }
        ; TODO: Dont check http paths if there are no runelite windows found
        httpPluginPathStats := this.Window.Config.Has('httpPluginPathStats') ? this.Window.Config.Get('httpPluginPathStats') : ""
        if (httpPluginPathStats != "") {
            httpPluginPathStatsSuccess := this.GetElement("httpPluginPathStatsSuccess")
            try {
                response := http.GET(httpPluginPathStats)
                if (response.Status == 200 && httpPluginPathStatsSuccess != false) {
                    httpPluginPathStatsSuccess.Text := "✔️"
                    httpPluginPathStatsSuccess.SetFont("c0x5afc03")
                }
                else {
                    httpPluginPathStatsSuccess.Text := "❌"
                    httpPluginPathStatsSuccess.SetFont("c0xfc0303")
                }
            } catch {
                httpPluginPathStatsSuccess.Text := "❌"
                httpPluginPathStatsSuccess.SetFont("c0xfc0303")
            }
        }
        httpPluginPathEvents := this.Window.Config.Has('httpPluginPathEvents') ? this.Window.Config.Get('httpPluginPathEvents') : ""
        if (httpPluginPathEvents != "") {
            httpPluginPathEventsSuccess := this.GetElement("httpPluginPathEventsSuccess")
            try {
                response := http.GET(httpPluginPathEvents)
                if (response.Status == 200 && httpPluginPathEventsSuccess != false) {
                    httpPluginPathEventsSuccess.Text := "✔️"
                    httpPluginPathEventsSuccess.SetFont("c0x5afc03")
                }
                else {
                    httpPluginPathEventsSuccess.Text := "❌"
                    httpPluginPathEventsSuccess.SetFont("c0xfc0303")
                }
            } catch {
                httpPluginPathEventsSuccess.Text := "❌"
                httpPluginPathEventsSuccess.SetFont("c0xfc0303")
            }
        }
        httpPluginPathInv := this.Window.Config.Has('httpPluginPathInv') ? this.Window.Config.Get('httpPluginPathInv') : ""
        if (httpPluginPathInv != "") {
            httpPluginPathInvSuccess := this.GetElement("httpPluginPathInvSuccess")
            try {
                response := http.GET(httpPluginPathInv)
                if (response.Status == 200 && httpPluginPathInvSuccess != false) {
                    httpPluginPathInvSuccess.Text := "✔️"
                    httpPluginPathInvSuccess.SetFont("c0x5afc03")
                }
                else {
                    httpPluginPathInvSuccess.Text := "❌"
                    httpPluginPathInvSuccess.SetFont("c0xfc0303")
                }
            } catch {
                httpPluginPathInvSuccess.Text := "❌"
                httpPluginPathInvSuccess.SetFont("c0xfc0303")
            }
        }
        httpPluginPathEquip := this.Window.Config.Has('httpPluginPathEquip') ? this.Window.Config.Get('httpPluginPathEquip') : ""
        if (httpPluginPathEquip != "") {
            httpPluginPathEquipSuccess := this.GetElement("httpPluginPathEquipSuccess")
            try {
                response := http.GET(httpPluginPathEquip)
                if (response.Status == 200 && httpPluginPathEquipSuccess != false) {
                    httpPluginPathEquipSuccess.Text := "✔️"
                    httpPluginPathEquipSuccess.SetFont("c0x5afc03")
                }
                else {
                    httpPluginPathEquipSuccess.Text := "❌"
                    httpPluginPathEquipSuccess.SetFont("c0xfc0303")
                }
            } catch {
                httpPluginPathEquipSuccess.Text := "❌"
                httpPluginPathEquipSuccess.SetFont("c0xfc0303")
            }
        }
        
    }

    Tester(el, info) {
        MyTip("Redraw")
        this.Redraw()
    }

    GoBack(el, info) {
        this.Window.ShowPage("Home")
    }

    InputFieldChanged(el, info) {
        MyTip(el.Text, 1000)
        this.Window.Config.Set(StrReplace(el.Name, "edit-",""), el.Value)
        this.SaveConfig()
    }
    StickyRight(el, info) {
        this.Window.Config.Set(el.Name, el.Value)
        this.Window.StickyHelper()
        this.SaveConfig()
    }

    SaveConfig(btn:=Object(), info:=Map()) {
        this.Window.SaveConfig(btn, info)
    }
}