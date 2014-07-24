; gdi+ ahk tutorial 3 written by tic (Tariq Porter)
; Requires Gdip.ahk either in your Lib folder as standard library or using #Include
;
; Tutorial to take make a gui from an existing image on disk
; For the example we will use png as it can handle transparencies. The image will also be halved in size

#SingleInstance, Force
SetWorkingDir %A_ScriptDir%
#NoEnv
SetBatchLines, -1

; Uncomment if Gdip.ahk is not in your standard library
;#Include, Gdip.ahk

; Menu
Menu, Tray, NoStandard
Menu, Tray, Add, Open Settings, OpenSettings
Menu, Tray, Add, Reload Settings, LoadSettings
Menu, Tray, Add, Save Position, SavePosition
Menu, Tray, Add, Reload Script, Reload
Menu, Tray, Add
Menu, Tray, Add, Exit, Exit

settings_file := "settings.ini"
Gosub, LoadSettings

imgDir := "img/" model "/"

; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit

; Create persistent background image
Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
Gui, 1: Show, NA
hwnd1 := WinExist()

; Create gui for showing the presses
Gui, 2: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
Gui, 2: Show, NA
hwnd2 := WinExist()

; If the image we want to work with does not exist on disk, then download it...
; If !FileExist("g400.png")
; 	msgbox, can't find the file

; Get a bitmap from the image
pBitmap := Gdip_CreateBitmapFromFile(imgDir "base.png")
btnLeft := Gdip_CreateBitmapFromFile(imgDir "left.png")
btnRight := Gdip_CreateBitmapFromFile(imgDir "right.png")
btnWheelUp := Gdip_CreateBitmapFromFile(imgDir "wheelup.png")
btnWheelDown := Gdip_CreateBitmapFromFile(imgDir "wheeldown.png")
btnM4 := Gdip_CreateBitmapFromFile(imgDir "m4.png")
btnM5 := Gdip_CreateBitmapFromFile(imgDir "m5.png")

; Check to ensure we actually got a bitmap from the file, in case the file was corrupt or some other error occured
If !pBitmap
{
	MsgBox, 48, File loading error!, Could not load the image specified
	ExitApp
}

; Get the width and height of the bitmap we have just created from the file
; This will be the dimensions that the file is
Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)

; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
; We are creating this "canvas" at half the size of the actual image
; We are halving it because we want the image to show in a gui on the screen at half its dimensions
hbm := CreateDIBSection(Width//2, Height//2)

; Get a device context compatible with the screen
hdc := CreateCompatibleDC()

; Select the bitmap into the device context
obm := SelectObject(hdc, hbm)

; Get a pointer to the graphics of the bitmap, for use with drawing functions
G := Gdip_GraphicsFromHDC(hdc)

; We do not need SmoothingMode as we did in previous examples for drawing an image
; Instead we must set InterpolationMode. This specifies how a file will be resized (the quality of the resize)
; Interpolation mode has been set to HighQualityBicubic = 7
Gdip_SetInterpolationMode(G, 7)

; DrawImage will draw the bitmap we took from the file into the graphics of the bitmap we created
; We are wanting to draw the entire image, but at half its size
; Coordinates are therefore taken from (0,0) of the source bitmap and also into the destination bitmap
; The source height and width are specified, and also the destination width and height (half the original)
; Gdip_DrawImage(pGraphics, pBitmap, dx, dy, dw, dh, sx, sy, sw, sh, Matrix)
; d is for destination and s is for source. We will not talk about the matrix yet (this is for changing colours when drawing)
Gdip_DrawImage(G, pBitmap, 0, 0, Width//2, Height//2, 0, 0, Width, Height)

; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
; So this will position our gui at (0,0) with the Width and Height specified earlier (half of the original image)
UpdateLayeredWindow(hwnd1, hdc, posX, posY, Width//2, Height//2)

OnMessage(0x201, "WM_LBUTTONDOWN")

Gosub, ClearObjects

; The bitmap we made from the image may be deleted
Gdip_DisposeImage(pBitmap)
Return

;#######################################################################

Exit:
	; gdi+ may now be shutdown on exiting the program
	Gdip_Shutdown(pToken)
	ExitApp
Return

ClearObjects:
	; Select the object back into the hdc
	SelectObject(hdc, obm)

	; Now the bitmap may be deleted
	DeleteObject(hbm)

	; Also the device context related to the bitmap may be deleted
	DeleteDC(hdc)

	; The graphics may now be deleted
	Gdip_DeleteGraphics(G)
Return


~LButton::		ShowPress(btnLeft)
~RButton::		ShowPress(btnRight)
~WheelUp::		SetTimer, WheelUp, -1
~WheelDown::	SetTimer, WheelDown, -1
~XButton1::		ShowPress(btnM4)
~XButton2::		ShowPress(btnM5)

~LButton Up::
~RButton Up::
~WheelUp Up::
~WheelDown Up::
~XButton1 Up::
~XButton2 Up::
		Gui, 2: Cancel
	Return

WheelUp:
	ShowScroll(btnWheelUp)
	Return

WheelDown:
	ShowScroll(btnWheelDown)
	Return

ShowScroll(img)
{
	ShowPress(img)
	Sleep 75
	Gui, 2: Cancel
}

ShowPress(img)
{
	global
	; Get the width and height of the bitmap we have just created from the file
	; This will be the dimensions that the file is
	Width := Gdip_GetImageWidth(img), Height := Gdip_GetImageHeight(img)

	; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
	; We are creating this "canvas" at half the size of the actual image
	; We are halving it because we want the image to show in a gui on the screen at half its dimensions
	hbm := CreateDIBSection(Width//2, Height//2)

	; Get a device context compatible with the screen
	hdc := CreateCompatibleDC()

	; Select the bitmap into the device context
	obm := SelectObject(hdc, hbm)

	; Get a pointer to the graphics of the bitmap, for use with drawing functions
	G := Gdip_GraphicsFromHDC(hdc)

	Gdip_SetInterpolationMode(G, 7)

	Gdip_DrawImage(G, img, 0, 0, Width//2, Height//2, 0, 0, Width, Height)

	; Update the second window. (Note hwnd2 not hwnd1.)
	UpdateLayeredWindow(hwnd2, hdc, posX, posY, Width//2, Height//2)

	OnMessage(0x201, "WM_LBUTTONDOWN")

	Gosub, ClearObjects

	Gui 2: Show, NA
	Return
}

; This function is called every time the user clicks on the gui
; The PostMessage will act on the last found window (this being the gui that launched the subroutine, hence the last parameter not being needed)
WM_LBUTTONDOWN()
{
	PostMessage, 0xA1, 2
}

SavePosition:
	WinGetPos, winX, winY, , , mouse-overlay.ahk
	path := ini_load(ini, settings_file)
	ini_replaceValue(ini, "Mouse", "posX", winX)
	ini_replaceValue(ini, "Mouse", "posY", winY)
	posX := winX
	posY := winY
	ini_save(ini, settings_file)
	msgbox, Position Saved.
	Return

Reload:
	Reload
	Return

OpenSettings:
	Run % settings_file
	Return

LoadSettings:
	If FileExist(settings_file)
	{
		path := ini_load(ini, settings_file)
		model := ini_getValue(ini, "Mouse", "model")
		posX := ini_getValue(ini, "Mouse", "posX")
		posY := ini_getValue(ini, "Mouse", "posY")
	}
	Else
	{
		Msgbox, settings.ini not found!
		ExitApp
	}
	Return