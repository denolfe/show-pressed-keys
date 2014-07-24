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

imgDir := "img/wasd/"
posX := 0
posY := 0

; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit

; Create Gui for background and each key
Loop, 9
{
	; Create persistent background image
	Gui, %A_Index%: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
	Gui, %A_Index%: Show, NA
	hwnd%A_Index% := WinExist()
}

; Get a bitmap from the image
bGround :=  Gdip_CreateBitmapFromFile(imgDir "base.png")
btnQ :=     Gdip_CreateBitmapFromFile(imgDir "q.png")
btnW :=     Gdip_CreateBitmapFromFile(imgDir "w.png")
btnA :=     Gdip_CreateBitmapFromFile(imgDir "a.png")
btnS :=     Gdip_CreateBitmapFromFile(imgDir "s.png")
btnD :=     Gdip_CreateBitmapFromFile(imgDir "d.png")
btnE :=     Gdip_CreateBitmapFromFile(imgDir "e.png")
btnCtrl :=  Gdip_CreateBitmapFromFile(imgDir "ctrl.png")
btnSpace := Gdip_CreateBitmapFromFile(imgDir "space.png")

; Check to ensure we actually got a bitmap from the file, in case the file was corrupt or some other error occured
If !bGround
{
	MsgBox, 48, File loading error!, Could not load the image specified
	ExitApp
}

ShowPress(bGround, 1)
OnMessage(0x201, "WM_LBUTTONDOWN")
Gdip_DisposeImage(bGround)
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



~*q::     ShowPress(btnQ, 2)
~*w::     ShowPress(btnW, 3)
~*e::     ShowPress(btnE, 4)
~*a::     ShowPress(btnA, 5)
~*s::     ShowPress(btnS, 6)
~*d::     ShowPress(btnD, 7)
~*LCtrl:: ShowPress(btnCtrl, 8)
~*Space:: ShowPress(btnSpace, 9)

~q Up::     Gui, 2:  Cancel
~w Up::     Gui, 3:  Cancel
~e Up::     Gui, 4:  Cancel
~a Up::     Gui, 5:  Cancel
~s Up::     Gui, 6:  Cancel
~d Up::     Gui, 7:  Cancel
~LCtrl Up:: Gui, 8:  Cancel
~Space Up:: Gui, 9:  Cancel

ShowPress(img, guiNum)
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
	UpdateLayeredWindow(hwnd%GuiNum%, hdc, posX, posY, Width//2, Height//2)

	OnMessage(0x201, "WM_LBUTTONDOWN")

	Gosub, ClearObjects

	Gui %GuiNum%: Show, NA
	Return
}

; This function is called every time the user clicks on the gui
; The PostMessage will act on the last found window (this being the gui that launched the subroutine, hence the last parameter not being needed)
WM_LBUTTONDOWN()
{
	PostMessage, 0xA1, 2
}