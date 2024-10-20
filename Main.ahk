#Requires AutoHotkey v2.0

#Include <Gui/Window>
#Include <JSON>
#Include <Map>
#Include <Array>
#Include <String>
#Include <WinEvent>
#Include <WinHttpRequest>
#Include <RandomBezier>

#Include ./Misc.ahk
#Include ./Pages/
#Include Home.ahk
#Include Settings.ahk
#Include CalibratePrayerSwitch.ahk
#Include SetFKeys.ahk
#Include SeersRooftop.ahk
#Include HosidiousFruitstalls.ahk
#Include DraynorFarmers.ahk
; #Include ./Info.ahk

BBHelperWindow := BBHelper()

class BBHelper extends Window {
    __New(Title:="bb's helper", Options:="+Resize -MaximizeBox +MinSize350x +MaxSize350x") {
        ; args := Map("height",500) ; Makes positioning of elements fucked?
        args := Map(), params:={}
        this.HomePage := HomePage()
        this.SettingsPage := SettingsPage()
        this.CalibratePrayerSwitchPage := CalibratePrayerSwitch()
        this.SetFKeysPage := SetFKeys()
        this.SeersRooftopPage := SeersRooftopPage()
        this.HosidiousFruitstallsPage := HosidiousFruitstallsPage()
        this.DraynorFarmersPage := DraynorFarmersPage()
        this.Config := this.GetConfig()
        this.minimizeHook := false, this.restoreHook := false, this.moveHook := false, this.activeHook := false, this.notActiveHook := false
        this.RuneliteTitle := ""
        this.ActivePrayerKeys := []
        this.ActiveFKeys := false
        this.FocussingRuneliteProg := false

        this.Sticky := false
        this.Minimized := false
        this.RuneliteMinimized := false

        super.__New(Title, Options, this.HomePage, params)
        this.AddPage(this.SettingsPage)
        this.AddPage(this.CalibratePrayerSwitchPage)
        this.AddPage(this.SetFKeysPage)
        this.AddPage(this.SeersRooftopPage)
        this.AddPage(this.HosidiousFruitstallsPage)
        this.AddPage(this.DraynorFarmersPage)

        this.Resize({height:500})

        foundRuneliteTitles := GetWindowTitlesFromProcess("runelite.exe")
        if (this.Config.Has("runeliteWindow")) {
            ; MsgBox("Config has a window title to listen to. Check if it exist still.")
            foundIndex := foundRuneliteTitles.Find((v) => v == this.Config.Get("runeliteWindow"), &match)
            if (foundIndex) {
                this.AddRuneliteHooks(this.Config.Get("runeliteWindow"))
                if (this.Config.Has("stickyHelper")) {
                    if (this.Config.Get("stickyHelper")) {
                        this.Sticky := true
                        this.StickyHelper()
                    }
                }
            }
        }
    }
    
    OnSizeEvent(args*) {
        super.OnSizeEvent(args*)
        if (!this.Minimized) {
            if (this.Sticky) {
                this.StickyHelper()
            }
        }
    }
    GetConfig() {
        conf := FileReadOrCreate(A_ScriptDir "\bb.config")
        return JSON.Load(conf)
    }
    SaveConfig(btn:=Object(), info:=Map()) {
        file := FileOpen(A_ScriptDir "\bb.config", "w")
        jsonString := JSON.Dump(this.Config, true)
        file.Write(jsonString)
        file.Close()
    }
    GetConfigValue(key) {
        val := this.Config.Has(key) ? this.Config.Get(key) : ""
        if (val == "") {
            MsgBox("Configure " key " so it's present in bb config")
        }
        return val
    }

    Focus() {
        windowId := WinGetID(this.Title)
        WinActivate("ahk_id " windowId)
    }

    AddRuneliteHooks(title) {
        this.AddHook("active", title)
        this.AddHook("not-active", title)
        this.AddHook("minimize", title)
        this.AddHook("restore", title)
        this.AddHook("move", title)
    }
    AddHook(hook, title) {
        this.RemoveHook(hook)
        Switch(hook) {
            Default:
                MsgBox("Dont know hook: " hook)
            Case "active":
                this.activeHook := WinEvent.Active(ObjBindMethod(this, "ActiveRuneliteHook"), title)
            Case "not-active":
                this.notActiveHook := WinEvent.NotActive(ObjBindMethod(this, "NotActiveRuneliteHook"), title)
            Case "minimize":
                this.minimizeHook := WinEvent.Minimize(ObjBindMethod(this, "MinimizeRuneliteHook"), title)
            Case "restore":
                this.restoreHook := WinEvent.Restore(ObjBindMethod(this, "RestoreRuneliteHook"), title)
            Case "move":
                this.moveHook := WinEvent.Move(ObjBindMethod(this, "MoveRuneliteHook"), title)
        }
    }
    RemoveRuneliteHooks() {
        this.RemoveHook("active")
        this.RemoveHook("not-active")
        this.RemoveHook("minimize")
        this.RemoveHook("restore")
        this.RemoveHook("move")
    }
    RemoveHook(hook) {
        Switch(hook) {
            Default:
                MsgBox("Dont know hook: " hook)
            Case "active":
                if (this.activeHook != false) {
                    this.activeHook.Stop()
                    this.activeHook := false
                }
            Case "not-active":
                if (this.notActiveHook != false) {
                    this.notActiveHook.Stop()
                    this.notActiveHook := false
                }
            Case "minimize":
                if (this.restoreHook != false) {
                    this.minimizeHook.Stop()
                    this.minimizeHook := false
                }
            Case "restore":
                if (this.restoreHook != false) {
                    this.restoreHook.Stop()
                    this.restoreHook := false
                }
            Case "move":
                if (this.moveHook != false) {
                    this.moveHook.Stop()
                    this.moveHook := false
                }
        }
    }

    ActiveRuneliteHook(eventObj, hWnd, dwmsEventTime) {
        if (!this.FocussingRuneliteProg && !this.Minimized) {
            ; MyTip("RUNELITE ACTIVE!")
            ; this.Show()
            ; WinMoveTop(this.Title)
        }
    }
    NotActiveRuneliteHook(eventObj, hWnd, dwmsEventTime) {
        ; if (!this.Minimized) {
        ;     activeId := WinGetID("A")
        ;     if (activeId != this.Hwnd) {
        ;         ; WinMoveBottom(this.Title)
        ;     }
        ; }
    }
    MoveRuneliteHook(eventObj, hWnd, dwmsEventTime) {
        rlDimensions := this.GetRuneliteWindowDimensions()
        if (this.Config.Has("runeliteWindow")) {
            if (this.Config.Get("runeliteWidth") != rlDimensions.Get("width") ||
                this.Config.Get("runeliteHeight") != rlDimensions.Get("height")) {
                    this.HomePage.RuneliteResizeEvent(rlDimensions)
                }
        }
        if (this.Sticky) {
            this.StickyHelper()
        }
    }
    MinimizeRuneliteHook(eventObj, hWnd, dwmsEventTime) {
        ; MyTip("runelite minimized")
        if (this.Sticky) {
            ; this.Hide()
        }
    }
    RestoreRuneliteHook(eventObj, hWnd, dwmsEventTime) {
        ; MyTip("runelite restored")
        if (this.Sticky) {
            ; this.Restore()
        }
    }

    StickyHelper() {
        ; Get width of this
        thisDim := this.GetThisDimensions()
        ; Get X, Y, Width and Height of runelite window
        rlDim := this.GetRuneliteWindowDimensions()
        if (!rlDim) {
            return
        }
        ; if (rlDim.Get("minimized")) {
        ;     return
        ; }
        if (this.Minimized) {
            return
        }


        screenWidth := SysGet(78)
        screenHeight := SysGet(79) - SysGet(4) - 25
        ; First check if runelite is maximized, 
        ;   if so, we should be sticky on the left side of screen unless stickyRight is true
        stickyRight := this.Config.Has("stickyRight") ? this.Config.Get("stickyRight") : false
        if (rlDim.Get("maximized")) {
            if (stickyRight) {
                ; Sticky on right side of screen
                newX := screenWidth - thisDim.Get("width")
                newY := 0
                newWidth := thisDim.Get("width")
                newHeight := screenHeight
            }
            else {
                ; Sticky on left side of screen
                newX := 0
                newY := 0
                newWidth := thisDim.Get("width")
                newHeight := screenHeight
            }
            this.Move(newX, newY, newWidth, newHeight)
            return ; Dont be sticky on the side of runelite if maximized. So return early
        }


        if (stickyRight) {
            if (rlDim.Get("x") + rlDim.Get("width") + thisDim.Get("width") > screenWidth) {
                ; Stick on the left side of runelite
                newX := rlDim.Get("x") - thisDim.Get("width") + 15
            }
            else {
                ; Stick on the right side of runelite
                newX := rlDim.Get("x") + rlDim.Get("width") - 15
            }
        }
        else {
            if (rlDim.Get("x") - thisDim.Get("width") < 0) {
                ; Stick on the right side of runelite
                newX := rlDim.Get("x") + rlDim.Get("width") - 15
            }
            else {
                ; Stick on the left side of runelite
                newX := rlDim.Get("x") - thisDim.Get("width") + 15
            }
        }
        newY := rlDim.Get("y")
        newWidth := thisDim.Get("width")
        newHeight := rlDim.Get("height")
        this.Move(newX, newY, newWidth, newHeight)
    }

    GetThisDimensions() {
        x := 0, y := 0, width := 0, height := 0
        WinGetPos(&x, &y, &width, &height, this.Title)
        windowState := WinGetMinMax(this.Title)
        minimized := windowState == -1 ? true : false
        
        return Map("x",x, "y",y, "width",width, "height",height, "minimized",minimized)
    }

    GetRuneliteTitle() {
        if (this.RuneliteTitle == "") {
            windowSelect := this.HomePage.GetElement("runeliteWindow")
            if (windowSelect != false) {
                this.RuneliteTitle := windowSelect.Text
            }
        }
        return this.RuneliteTitle
    }

    GetRuneliteWindowDimensions() {
        title := this.GetRuneliteTitle()
        if (!title) {
            MyTip("Could not get position of runelite window. Title not found.", 2500)
            return false
        }
        x := 0, y := 0, width := 0, height := 0
        WinGetPos(&x, &y, &width, &height, title)
        windowState := WinGetMinMax(title)
        minimized := windowState == -1 ? true : false
        maximized := windowState == 1 ? true : false
        
        return Map("x",x, "y",y, "width",width, "height",height, "minimized",minimized, "maximized",maximized, "title",title)
    }
    
    FocusRuneliteWindow(title:="") {
        this.FocussingRuneliteProg := true
        windowTitle := title == "" ? this.GetRuneliteTitle() : title
        if (!windowTitle) {
            MsgBox("Could not focus runelite window. Title not found.")
            this.FocussingRuneliteProg := false
            return false
        }
        windowId := WinGetID(windowTitle)
        WinActivate("ahk_id " windowId)
        this.FocussingRuneliteProg := false
        return true
    }

    CreatePrayerSwitchKeybinds() {
        this.RemovePrayerSwitchKeybinds()
        prayerKeys := ["protectMissiles", "protectMelee", "protectMagic"]
        for (key in prayerKeys) {
            conf := this.Config.Has(key) ? this.Config.Get(key) : false
            if (conf) {
                if (conf.Has("keybind")) {
                    Hotkey("$" conf.Get("keybind"), (btn) => this.PrayerKey(btn), "On")
                    this.ActivePrayerKeys.push(conf.Get("keybind"))
                }
            }
        }
        ; for (i, val in this.ActivePrayerKeys) {
        ;     MsgBox("added?: " this.ActivePrayerKeys[i])
        ; }
    }

    RemovePrayerSwitchKeybinds() {
        for (i, val in this.ActivePrayerKeys) {
            Hotkey("$" this.ActivePrayerKeys[i], "Off")
        }
        this.ActivePrayerKeys := []
    }

    PrayerKey(btn) {
        activeWindowTitle := WinGetTitle("A")
        btn := StrReplace(btn, "$", "")
        if (activeWindowTitle == this.GetRuneliteTitle()) {
            ;; Go through keys in config and find one that has the key "keybind" equal to btn
            ; foundKey := this.Config.Find((v) => v.Has("keybind") && v["keybind"] == btn, &foundObj)
            foundKey := this.Config.Find((v) => IsObject(v) && v.Has("keybind") && v["keybind"] == btn, &foundObj)
            if (foundKey) {
                this.ActivatePrayer(foundKey)
            } else {
                MsgBox("Cant find config with key " btn)
            }
        }
        else {
            if (StrLen(btn) == 1) {
                SendInput(btn)
            } 
            ; else if (btn == "Tab") {
            ;     SendInput(A_Tab)
            ; } else if (btn == "Space") {
            ;     SendInput(A_Space)
            ; } 
            else {
                SendInput("{" btn "}")
                ; MsgBox("Disable Prayer switch hotkey: " btn)
            }
        }
    }
    ActivatePrayer(prayerKey) {
        currentMenu := this.FindActiveIngameMenu()
        conf := this.Config.Get(prayerKey)
        menuPrayerConf := this.Config.Get("menu-prayer")
        MouseGetPos(&mouseX, &mouseY)
    
        randX := Random(conf.Get("x")-5, conf.Get("x")+5)
        randY := Random(conf.Get("y")-5, conf.Get("y")+5)
        ;; TODO: New Arg for MouseMoveRandom to block physical mouse input if specified
        Send("{" menuPrayerConf.Get("keybind") "}")
        QuickSleep()
        MouseMoveRandom(randX, randY, {blockMouse: true, mode:"competitive"})
        ; QuickSleep()
        Click()
        QuickSleep()
        if (currentMenu != false) {
            Send("{" currentMenu.keybind "}")
        }
        ; MouseMoveRandom(mouseX, mouseY)
    }

    CreateFKeysOnCapslockKeybinds() {
        this.RemoveFKeysOnCapslockKeybinds()
        keys := ["1","2","3","4","5","6","7","8","9","0","+","´"]
        for (key in keys) {
            Hotkey("$" key, (btn) => this.FKey(btn), "On")
        }
        this.ActiveFKeys := true
    }

    RemoveFKeysOnCapslockKeybinds() {
        if (this.ActiveFKeys) {
            keys := ["1","2","3","4","5","6","7","8","9","0","+","´"]
            for (key in keys) {
                Hotkey("$" key, "Off")
            }
            this.ActiveFKeys := false
        }
    }

    FKey(btn) {
        caps := GetKeyState("CapsLock", "T")
        btn := StrReplace(btn, "$", "")
        if (caps) {
            if (btn == "0")
                btn := "10"
            else if (btn == "+")
                btn := "11"
            else if (btn == "´")
                btn := "12"
            btn := "F" . btn
            Send("{" . btn . "}")
        }
        else {
            Send(btn)
        }
    }

    FindActiveIngameMenu() {
        ; startTime := A_TickCount
        menuItems := ["menu-inv", "menu-prayer", "menu-magic", "menu-equip", "menu-combat", "menu-door", "menu-music","menu-quest", "menu-stats", "menu-friend", "menu-ignore", "menu-clan"]
        for (item in menuItems) {
            if (this.Config.Has(item)) {
                thisConf := this.Config.Get(item)
                coords := ExtractCoords(thisConf.Get("position"))
                colorFound := PixelGetColor(coords.x, coords.y)
                if (colorFound == thisConf.Get("colorOn")) {
                    ; endTime := A_TickCount
                    ; MyTip(endTime - startTime)
                    return {name: StrReplace(item, "menu-", ""), coords: coords, keybind: thisConf.Get("keybind")}
                }
            }
        }
        return false
    }

    GetLatestIngameMessage() {
        eventsUrl := this.Config.Has('httpPluginPathEvents') ? this.Config.Get('httpPluginPathEvents') : ""
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
        if (jsonRes.Has("latest msg")) {
            return jsonRes.Get("latest msg")
        }
        else {
            return ""
        }
    }

    GetHealthIngame() {
        eventsUrl := this.Config.Has('httpPluginPathEvents') ? this.Config.Get('httpPluginPathEvents') : ""
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
        if (jsonRes.Has("health")) {
            return jsonRes.Get("health")
        }
        else {
            return ""
        }
    }
    CheckHealthLow(minHealth:=false, maxDiff:=false) {
        if (!minHealth &&!maxDiff) {
            MsgBox("NEED TO SET EITHER MIN HEALTH OR MAX DIFF WHEN CHECKING HEALTH!")
            return
        }
        healthStr := this.GetHealthIngame()
        
        if (RegExMatch(healthStr, "(\d+)/(\d+)", &matches)) {
            currentHealth := matches[1]  
            maxHealth := matches[2]
            if (minHealth != false) {
                if (currentHealth < minHealth) {
                    return true
                }
                else {
                    return false
                }
            }
            else if (maxDiff != false) {
                if (maxHealth - currentHealth > maxDiff) {
                    return true
                }
                else {
                    return false
                }
            }
        }
    }

    GetInventoryIngame() {
        invUrl := this.GetConfigValue('httpPluginPathInv')
        if (invUrl == "")
            return

        oOptions := Map()
        oOptions["SslError"] := false
        oOptions["UA"] := "Autohotkey-lol"
        http := WinHttpRequest(oOptions)
        response := http.GET(invUrl)
        jsonRes := JSON.Load(response.Text)
        return jsonRes
    }

    IsInventoyFull() {
        inventorySlots := this.GetInventoryIngame()

        for (i, val in inventorySlots) {
            if (val.Get("id") == -1) {
                return false
            }
        }
        return true
    }

    EatFood(foodIds, mode:="really-slow", returnToPos:=false) {
        if (!IsObject(foodIds)) {
            ; Not object, probably string
            foodIds := foodIds.Split(",", " ")
        }
        ; Check inventory for food ids
        inventorySlots := this.GetInventoryIngame()

        this.FocusRuneliteWindow()
        foodInvSlot := 0
        for (i, val in inventorySlots) {
            foodIndex := foodIds.IndexOf(val.Get("id"))
            if (foodIndex) {
                foodInvSlot := i
                break
            }
        }
        if (foodInvSlot) {
            invSlot1Pos := this.GetConfigValue('invSlot1Pos')
            invSlot1Pos := ExtractCoords(invSlot1Pos)
            ; 40,40 per invslot
            row := Ceil(foodInvSlot / 4) - 1
            column := Mod(foodInvSlot - 1, 4)
            MouseGetPos(&mouseX, &mouseY)

            currentMenu := this.FindActiveIngameMenu()
            if (currentMenu && currentMenu.name != "inv") {
                invConf := this.GetConfigValue("menu-inv")
                Send("{" invConf.Get("keybind") "}")
                QuickSleep()
            }
            MouseMoveRandom(invSlot1Pos.x + (column * 37), invSlot1Pos.y + (row * 37), {blockMouse: true, mode:mode})
            QuickSleep()
            SpamClick(,3)
            QuickSleep()

            if (currentMenu && currentMenu.name != "inv") {
                Send("{" currentMenu.keybind "}")
            }
            if (returnToPos) {
                MouseMoveRandom(mouseX, mouseY, {blockMouse: true, mode:mode})
            }
            return true
        }
        return false
    }

    DropItems(items, mode:="really-slow", returnToPos:=false) {
        if (!IsObject(items)) {
            ; Not object, probably string
            items := items.Split(",", " ")
        }
        inventorySlots := this.GetInventoryIngame()
        this.FocusRuneliteWindow()
        dropItemSlots := []
        for (i, val in inventorySlots) {
            index := items.IndexOf(val.Get("id"))
            if (index) {
                dropItemSlots.Push(i)
            }
        }
        if (dropItemSlots.Length > 0) {
            invSlot1Pos := this.GetConfigValue('invSlot1Pos')
            invSlot1Pos := ExtractCoords(invSlot1Pos)
            MouseGetPos(&mouseX, &mouseY)
            currentMenu := this.FindActiveIngameMenu()
            if (currentMenu && currentMenu.name != "inv") {
                invConf := this.GetConfigValue("menu-inv")
                Send("{" invConf.Get("keybind") "}")
                QuickSleep()
            }
            Send("{Shift Down}")
            for (i, slot in dropItemSlots) {
                row := Ceil(slot / 4) - 1
                column := Mod(slot - 1, 4)
                MouseMoveRandom(invSlot1Pos.x + (column * 40), invSlot1Pos.y + (row * 37), {offsetX:5, blockMouse: true, mode:mode})
                Click()
                QuickSleep()
            }
            Send("{Shift Up}")
            QuickSleep()
            if (currentMenu && currentMenu.name != "inv") {
                Send("{" currentMenu.keybind "}")
            }
            if (returnToPos) {
                MouseMoveRandom(mouseX, mouseY, {blockMouse: false, mode:mode})
            }
        }
    }

}