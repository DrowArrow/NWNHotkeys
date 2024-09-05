#Requires Autohotkey v2
#SingleInstance Force
#NoTrayIcon
HotIfWinActive("ahk_exe nwmain.exe")

; INI file configuration
if FileExist("NWNHotkeys.ini"){
	QBHotkey := IniRead("NWNHotkeys.ini", "Hotkeys", "QBHotkey", "^f")
	QBLoop := IniRead("NWNHotkeys.ini", "Loops", "QBLoop")
	OpLevel := IniRead("NWNHotkeys.ini", "Options", "Opacity")
	AOTCheck := IniRead("NWNHotkeys.ini", "Options", "AlwaysOnTop", 0)
}
else {
	IniWrite "^f", "NWNHotkeys.ini", "Hotkeys", "QBHotkey"
	IniWrite 10, "NWNHotkeys.ini", "Loops", "QBLoop"
	IniWrite 255, "NWNHotkeys.ini", "Options", "Opacity"
	IniWrite 0, "NWNHotkeys.ini", "Options", "AlwaysOnTop"
	QBHotkey := IniRead("NWNHotkeys.ini", "Hotkeys", "QBHotkey", "^f")
	QBLoop := IniRead("NWNHotkeys.ini", "Loops", "QBLoop", 10)
	OpLevel := IniRead("NWNHotkeys.ini", "Options", "Opacity", 255)
	AOTCheck := IniRead("NWNHotkeys.ini", "Options", "AlwaysOnTop", 0)
}

{
	myGui := Constructor()
	myGui.Show("w300 h200")
}

Constructor()
{
	Global QBHotkey
	myGui := Gui()
	Tab := myGui.Add("Tab3", "x0 y0 w303 h210", ["Neverwinter Nights", "Options"])
	Tab.UseTab(1)
	myGui.AddHotkey("vQuickBuy Limit1 x8 y32 w120 h21", QBHotkey) ; "vQuickBuy": used to assign a variable name for the hotkey which can be called later on with gui.submit | "QBHotkey": A variable that holds the key combination for the hotkey which is defined as a Global variable at the top of the script
	myGui.Add("Text", "x136 y32 w120 h23 +0x200", "Quick Buy")
	UpdBtn1 := myGui.Add("Button", "x200 y32 w80 h21", "Update")
	myGui.AddEdit("vQBEdit Number x8 y64 w120 h21", QBLoop)
	myGui.Add("Text", "x136 y64 w120 h23 +0x200", "Buy Count")
	UpdBtn2 := myGui.Add("Button", "x200 y64 w80 h21", "Update")
	Tab.UseTab(2)
	AOT := myGui.AddCheckbox("vcb_aot x200 y180 Checked" AOTCheck, "Always on top?")
	Opacity := myGui.AddSlider("AltSubmit Center NoTicks ToolTipTop range100-255 x8 y55 w120 h21", OpLevel)
	myGui.Add("Text", "x30 y32 w120 h23 +0x200", "Transparency")
	Tab.UseTab()
	UpdBtn1.OnEvent("Click", UpdateHotkey) ; Calls the UpdateHotkey function when the update button is clicked.
	UpdBtn2.OnEvent("Click", UpdateLoop)
	AOT.OnEvent("Click", AlwaysOnTop)
	Opacity.OnEvent("Change", Op_Adjust)
	myGui.OnEvent('Close', ExitProcedure)
	myGui.Title := "Game Hotkeys"
	
	return myGui
}

;Startup Variables Read
WinWait("Game Hotkeys")
	WinSetTransparent(OpLevel)

	AOT_Startup := myGui.Submit(0).cb_aot
	if (AOT_Startup = 1)
		WinSetAlwaysOnTop 1
	else
		WinSetAlwaysOnTop 0

;Hotkey Update Function

UpdateHotkey(*) {
	Global QBHotkey
	QBHK := myGui.Submit(0).Quickbuy ; Grabs the updated hotkey from the hotkey gui box
	; assigns the updated Hotkey value from the gui to the QBHK variable

	ChangeHotkey(QBHK) {
		Hotkey(QBHotkey, QB, 'Off') ; Disables Hotkey
		QBHotkey := QBHK ; Updates the QBHotkey variable with the Hotkey value from the QBHK variable
		Hotkey(QBHotkey, QB) ; Enables hotkey with the newly assigned Hotkey combination
		IniWrite QBHotkey, "NWNHotkeys.ini", "Hotkeys", "QBHotkey"
	}

	if (QBHK != "") {
		ChangeHotkey(QBHK)
		ToolTip("Hotkey changed!")
		Sleep 1000
		ToolTip() ; Clear the tooltip
	}
}

;Buy Count Update Function

UpdateLoop(*) {
	Global QBLoop
	LoopCount := myGui.Submit(0).QBEdit ;grabs the value from the Buy Count GUI box and assigned it to the LoopCount variable 
	 ;assigns the updated buy count from the gui to the new loop variable

	ChangeLoop(LoopCount){
		QBLoop := LoopCount ; assigns the updated buy count to the QBLoop variable
		IniWrite QBLoop, "NWNHotkeys.ini", "Loops", "QBLoop" ;writes the new value of the QBLoop variable to the configuration file
	}

	if (LoopCount !=""){
		ChangeLoop(LoopCount)
		ToolTip("Buy Count Changed!")
		sleep 1000
		ToolTip()
	}
}

;Function for "ALways on Top?"" Checkbox

AlwaysOnTop(AOT, info){
	if (aot.Value = 1)
		WinSetAlwaysOnTop 1, "A"
	else
		WinSetAlwaysOnTop 0, "A"
}

Op_Adjust(Opacity, *){
	WinSetTransparent(Opacity.value)
	IniWrite(Opacity.value, "NWNHotkeys.ini", "Options", "Opacity")
}

Global DragDistance := 300

;Hotkeys

Hotkey(QBHotkey, QB)

; Quickbuy Function

QB(*) {
	MouseGetPos &StartX, &StartY
	Loop(QBLoop) { ; change the loop count to however many times you want it to make the purchase before stopping
		MouseClickDrag "right", StartX, StartY, StartX + DragDistance, StartY
		sleep 285 ; Edit the sleep time (milliseconds) to change how quick it makes each purchase
		}
	MouseMove StartX, StartY
}

ExitProcedure(AOTCheck){
	AOTCheck := mygui.Submit(0).cb_aot
	IniWrite(AOTCheck, "NWNHotkeys.ini", "Options", "AlwaysOnTop")
	ExitApp()
}

HotIf