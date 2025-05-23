﻿#HotIf WinActive("ahk_class Kohan")

; all coordinates are for the default 1024x768 resolution and are scaled using ConverCoords()

; Kohan needs a small amount of delay between keystrokes to keep from getting overwhelmed
SetKeyDelay 1, 0

; calibrates the script for the current screen resolution
Calibrate(){
	WinGetClientPos(,, &W, &H,)
	; Assume the game is still in 4:3 aspect ratio
	if W/4 > H/3 {
		global OffSetX := (W - 4/3 * H) * 0.5
		global OffSetY := 0
		global Width := W - 2*OffSetX
		global Height := H
	} else {
		global OffSetX := 0
		global OffSetY := (H - 0.75 * W) * 0.5
		global Width := W 
		global Height := H- 2*OffSetY
	}
	;MsgBox Format( "Top-Left corner: {1}, {2}\nActive Area: {3} x {4}", OffSetX, OffSetY, Width, Height)
}

Recenter(){
	MouseMove( ConvertCoords( 500, 300 )* )
}

FindColor(x, y, color){ ; function to find a specific pixel color and compare with an input color to return true or false 
    coords := ConvertCoords( x, y )
	x1 := coords[1] - 2
	y1 := coords[2] - 2
	x2 := coords[1] + 2
	y2 := coords[2] + 2
	if( PixelSearch( &Px, &Py, x1, y1, x2, y2, color, 2 ) ){
		return true
	} else {
		return false
	}
}


ConvertCoords( x, y ){
	if( NOT isSet(Width) ){
		Calibrate()
	}
	coords := [ x * Width / 1024 + OffSetX, y * Height / 768 + OffSetY ]
	return coords
}

SelectSettlement( index ){
	Send( "{F1}" )
	sleep 2
	MouseMove( 5, 5, 2, "R") ; prevents cursor getting "stuck"
	Sleep( 2 )
	MouseMove( ConvertCoords( 250, 21 + index * 76 )* )
	Sleep 2
	Click( , , "Left", 2)
	Sleep 3
	Send( "{F1}" )
	Recenter()
}

; Pastes the given symbol and message into the chat
PingChat( symbol, message ){
	; SendEvent used to slightly delay each keystroke
	SendEvent( "{enter}" symbol message symbol "{enter}")
}

~c::Calibrate()

AwakeKohanAmulet() { ; 
if (FindColor( 406, 426, 0xB57531 ) ){ ; Detect confirmation to awake kohan
                send( "{enter}" )
				sleep 200
				Send( "{Lbutton}" )
            }
}

;-- group ████████████████████████████████████████████████████████████████████████████████████
!5::0
!1::6
!2::7
!3::8
!4::9


;-- select whole screen ████████████████████████████████████████████████████████████████████████████████████
^q::
{
coords := ConvertCoords( 1012, 600 )
x1 := coords[1], y1 := coords[2]
coords := ConvertCoords( 8, 8 )
x2 := coords[1], y2 := coords[2]
MouseMove(x1, y1)
Send ("{Lbutton down}")
sleep(10)
MouseMove(x2, y2)
Send ("{Lbutton up}")
sleep(10)
Recenter()
sleep(500)
}

; click on settlements in the F1 menu
`::SelectSettlement( 1 )

F2::SelectSettlement( 2 )

F3::SelectSettlement( 3 )

F4::SelectSettlement( 4 )

F5::SelectSettlement( 5 )

F6::SelectSettlement( 6 )


; Game speed controls███████████████████████████████████████████████████████████████████████████████████
~NumpadAdd::F4
~NumpadSub::F3

XButton1::Enter ; should be optional or mentioned somewhere
XButton2::Delete ; should be optional or mentioned somewhere


; recruit   ████████████████████████████████████████████████████████████████████████████████████

^e:: ;settler without kohan
{
    if( FindColor( 338, 726, 0x6365AD ) ){ ; recruit menu button 
        send( "{r}" )
        send( "{1}" ) ; use whatever key you binded short setler in save company
        send( "{enter}" )
        sleep 100
    }
}

^r:: ;settler with kohan
{
    if( FindColor( 338, 726, 0x6365AD ) ){ ; recruit menu button delay as been added so kohan handle the function proprely
        send( "{r}" )
		sleep 30
        send( "{1}" )
		sleep 30
        MouseMove( ConvertCoords( 365, 420 )* )
		sleep 30
        Send( "{Lbutton}" )
		sleep 30
        AwakeKohanAmulet()
		sleep 30
        Send( "{Lbutton}" )
		sleep 30
    	send( "{enter}" )
        sleep 300
    }
    else
    Send( "^r" )
}

; "r" works as {Enter} while in recruitment window
~r::
{
    if ( FindColor( 55, 320, 0x211431 ) ){ ; recruit menu side panel 
        	send( "{enter}" )
    }
}


; "e" removes the unit under the cursor from the company to be commissioned
~e::
{
    if ( FindColor( 55, 320, 0x211431 ) ){ ; recruit menu side panel 
		send( "{Lbutton down}" )
		Sleep( 3 ) ; delay added to make the function work proprely
		MouseMove( 50, 0, 2, "R" )
		send( "{Lbutton up}" )
		Sleep( 3 )
		MouseMove( -50, 0, 2, "R" )
    }
	; this part is to open build menu with E and build a blacksmith if build menu is open (since this part had none explaination)
    if (FindColor( 406, 733, 0x525552 )){ ; building button
	if (FindColor( 50, 177, 0x424142 )){ ; blacksmith button
 		send( "{e}" )
		sleep 500
    	}
	else {
		send( "{b}" )
	}
    }
}


; right click to add unit to company
~Rbutton up:: ; without the ~ or the up it mess with normal use of the Rbutton
{
    if ( FindColor( 55, 320, 0x211431 ) ){
        	send( "{Lbutton}" )
			send( "{Lbutton}" )
    }
    sleep 100
}

; Build outpost/settlement at cursor    ████████████████████████████████████████████████████████████████████████████████████

^f::
{
	isSettler := false
    if( FindColor( 515, 637, 0x946531 )  ){ ; checks for build menu button and opens build menu
        send( "{b}" )
		Sleep( 70 )
	}
	if( FindColor( 515, 637, 0xBD8A00 ) ){ ; check for company menu button (ie already in build menu)
		if( FindColor( 448, 640, 0x211431 ) ){ ; if background color (ie no button and therefore settler)
			Send( "s" )
			isSettler := true
		} else {
			Send( "o" )
		}
		Send( "{LButton}" ) ; click build cursor onto map
		Sleep 55 ; safety delay so the company isn't stuck into confirmation dialog
		if( FindColor( 554, 370, 0x424152 ) ){ ; if structure confirmation dialog opened (ie valid location)
			Send( "{Enter}b" )
			if( isSettler ){ ; always press settlers
				Send( "q" )
			}
		}
	}
	sleep 100
}

; add component     ████████████████████████████████████████████████████████████████████████████████████


~x:: ;library X
{
    if ( FindColor( 55, 368, 0x2961b5 ) ){ ; building menu open check library available color
        	send( "{l}" )
    }
}

; sell component     ████████████████████████████████████████████████████████████████████████████████████


SellAll(){ ; fast selling 
   ; while first component slot is NOT empty
	i := 0 ; safety to avoid infinite loop
    while( NOT FindColor( 345, 640, 0x101429 ) && (i < 20) ){ 
        MouseMove( ConvertCoords( 345, 640 )* )

        Send( "{s}" )
        Send( "{Lbutton}" )
		if (FindColor( 408, 405, 0x000000 ) ){ ; Detect confirmation dialog to be able to work with confirmation box option disable
                 send( "{enter}" )
             }
		 i := i+1 ; safety to avoid infinite loop
        sleep 225
    }
    return
}

^s:: ;sell all
{
    if ( FindColor( 456, 729, 0xF7BE5A ) ){ ; checks for sell button
        sleep 100
        SellAll()
    }
}

;instant delete ████████████████████████████████████████████████████████████████████████████████████

~Delete::
{
sleep 30
if (FindColor( 408, 405, 0x000000 ) ){ ; Detect confirmation dialog 
                 send( "{enter}" )
             }
}


; toggle zones     ████████████████████████████████████████████████████████████████████████████████████
~^z::
{
Send( "^x" )
Send( "^s" )
Send( "^p" )
Send( "^c" )
}

; multiplayer chat commands ▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚▚

!q::SendEvent( "{Enter}/r{Enter}" ) ; resources report /r

!e::PingChat( "^m", "Danger" ) ; ping danger

!r::PingChat( "^e", "Lair" ) ; ping lair

!a::PingChat( "^a", "Attack" ) ; ping Attack

!s::PingChat( "^e", "Spy" ) ; ping Spy

!d::PingChat( "^c", "Indies" ) ; ping indie

!f::PingChat( "^d", "Defend") ; def here

!w:: ; last event
{
	MouseMove( ConvertCoords( 239, 594 )* )
	Send( "{Lbutton}" )
	sleep 5 ; delay needed to work proprely
	MouseMove( ConvertCoords( 500, 300 )* )

	sleep 100
}


; cheat     ████████████████████████████████████████████████████████████████████████████████████

!F7:: ; scene 24
{
Send( "{enter}" )
SendEvent ( "scene 24" ) ; changing Send into SendEvent
Send( "{enter}" )
Return
}

!F8:: ; rentakohan
{
Send( "{enter}" )
SendEvent ( "rentakohan" )
Send( "{enter}" )
Return
}

!F9:: ; pyrite
{
Send( "{enter}" )
SendEvent ( "pyrite" )
Send( "{enter}" )
Return
}


