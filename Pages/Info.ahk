#Requires AutoHotkey v2.0

#Include <Gui/Page>

class InfoPage extends Page {
    __New(window:=false, name:="Info") {
        super.__New(window, name)
    }

    Init() {
        this.AddElement("Text", "x15 y15 w100 h25 +0x200 -Background", args:=Map("text","Info"))
    }

    Show() {
        super.Show()
    }
}