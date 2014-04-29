#Persistent
#SingleInstance force

Menu, Tray, Add ; separator
Menu, Tray, Add, About and Options, AboutOptions


/*
Format for PPM image file

P3
# example from the man page
4 4
15
 0  0  0    0  0  0    0  0  0   15  0 15
 0  0  0    0 15  7    0  0  0    0  0  0
 0  0  0    0  0  0    0 15  7    0  0  0
15  0 15    0  0  0    0  0  0    0  0  0

*/

; Default GUI options
FileSave = 0
InfoWindow = 1

; Default variables
TmpDir =c:\tmp
TmpFile =image_out
ImageFormat =pgm
TmpImageFormat =ppm ; This is the only format supported

; Program paths for dependencies
convert_path =c:\bin
mkbitmap_path =c:\bin
potrace_path =c:\bin
gocr_path =c:\bin
tesseract_path =c:\bin

; Default processing options

;   Image preprocessing
   
   ; mkbitmap
   mkb_s =3 ; scale and interpolate
   mkb_s1 =0 ;-2 linear scale
   mkb_s2 =1 ;-3 cubic scale
   mkb_i =0 ; -i invert
   mkb_f =4 ; highpassfilter
   mkb_t =0.45 ; threshold
   
   ; potrace
   pre_potrace = 1 ; Run bitmap thru potrace
   pot_z =minority ;how to resolve ambiguities in path decomposition
         ;black, white, right,  left,  minority|,  majority,  or  random
   pot_t =2 ;suppress speckles of up to this size (default 2)
   pot_a =4 ;corner threshold parameter (default 1)
   pot_n =0 ;-n turn off curve optimization
   pot_O =0.2 ;curve optimization tolerance (default 0.2)
   pot_u =10 ;Quantize output to 1/unit pixel
   pot_k =0.5 ; Black/white cutof
   pot_i =0 ;-i ; -i invert
   pot_r =0 ; Rotate clock wise degree
   
;   OCR
   ocr_d =-1 ; -d, Dust size
   ocr_s =0 ; -d, Spacewidth
   ocr_m =32 ; -m, operational modes
   ocr_n =0 ; -n, numbers only

;   OCR/TEXT postprocessing
   NoLineReturn = 1


; IniFile Functions
; To be done...

/*
IniRead,
   Bla Bla
Return

IniWrite:
   Bla bla
Return

*/

~^LButton:: ;press ctrl + Left mouse button (for "start")

   stop=0
   
   ; ### Start, Get posisions to grab using window
   ; First method for positioning of screengrab
   CoordMode, Mouse, Screen
   CoordMode, Tooltip, Screen
   MouseGetPos, scan_x_start, scan_y_start
   currentXpos=%scan_x_start%
   currentYpos=%scan_y_start%
   ToolTip, ., scan_x_start, scan_y_start
   
   
   WinSet, Transparent, 100, ahk_class tooltips_class32
   
   Sleep, 800
   
   loop
   {
   
   
   MouseGetPos, scan_x, scan_y
   scan_x-=%currentXpos%
   scan_y-=%currentYpos%
   WinMove, ahk_class tooltips_class32, , , , %scan_x%, %scan_y%
   
   GetKeyState, state, LButton
   
   if state=d
   {
      if stop=0
      {
         tooltip
         break
      }
   }
   
   }
   
   MouseGetPos, scan_x_end, scan_y_end
   ; ### StopGet posisions to grab unsing window
   
   /*
   ; Alternate method for positioning of screengrab
   ^!e:: ;press ctrl-alt-e (for "end")
   CoordMode, Pixel, Screen
   CoordMode, Mouse, Screen
   MouseGetPos, scan_x_end, scan_y_end
   */
   
   ; Main scanning function
   TrayTip, , Scanning...., , 1
   
   CoordMode, Pixel, Screen
   CoordMode, Mouse, Screen
   MouseGetPos, scan_x_end, scan_y_end
   
   scan_current_y=%scan_y_start%
   scan_current_x=%scan_x_start%
   scan_current_line=
   scan_current_line_source=
   Loop
   {
      scan_current_x := scan_current_x + 1
      if scan_current_x > %scan_x_end%
      {
         scan_current_line =%scan_current_line%`n
         scan_current_line_source =%scan_current_line_source%`n
       
         scan_current_y := scan_current_y + 1
         if scan_current_y > %scan_y_end%
            break
         scan_current_x = %scan_x_start%
         continue
      }
      PixelGetColor, found_color, %scan_current_x%, %scan_current_y%
      
      StringMid, scan_rgb_r, found_color, 3, 2
      StringMid, scan_rgb_g, found_color, 5, 2
      StringMid, scan_rgb_b, found_color, 7, 2
      
      scan_current_line_source =%scan_current_line_source% %found_color%
   
      scan_rgb_r =0x%scan_rgb_r%
      scan_rgb_g =0x%scan_rgb_g%
      scan_rgb_b =0x%scan_rgb_b%
   
      SetFormat, integer, d
      scan_rgb_r -= 0
      scan_rgb_g -= 0
      scan_rgb_b -= 0
   
      scan_rgb_r := "   " . scan_rgb_r
      scan_rgb_g := "   " . scan_rgb_g
      scan_rgb_b := "   " . scan_rgb_b
   
      StringRight, scan_rgb_r, scan_rgb_r, 3
      StringRight, scan_rgb_g, scan_rgb_g, 3
      StringRight, scan_rgb_b, scan_rgb_b, 3
      
      found_color =%scan_rgb_r% %scan_rgb_g% %scan_rgb_b%
      
      ;scan_current_line=%scan_current_line% %found_color%
      ;/*
      if scan_current_x > %scan_x_start%
      {
        scan_current_line=%scan_current_line% %found_color%
      }
      else
      {
        scan_current_line=%scan_current_line%%found_color%
      }
      ;*/
   }
   
   ; Add Header for image file
   format :="P3"
   comment :="#File made in Autohotkey"
   hight :=scan_y_end - scan_y_start
   width :=scan_x_end - scan_x_start
   colors :="255"
      
   file_data =
   (
      %format%
      %comment%
      %width%
      %hight%
      %colors%
      %scan_current_line%
   )
   
   TrayTip, , Scan complete, , 1
   sleep, 1000
   TrayTip

   GoSub, MainProcess
   ;MsgBox, The MainProcess subroutine has returned (it is finished).
   return

   MainProcess:
   
   Gui Destroy

   ; File Save, function to allow save a file of the screengrab image
   if FileSave = 1
   {
      FileSelectFile, SelectedFile, 16, , Save image, (*.ppm)
      if SelectedFile =
      {
      MsgBox,,Save canceled, No image saved.
      }
      else
      {
      IfExist %SelectedFile%
      {
         FileDelete %SelectedFile%
         if ErrorLevel <> 0
         {   
            MsgBox The attempt to overwrite "%SelectedFile%" failed.
            return
         }
         else
         {
            FileAppend, %file_data%, *%SelectedFile%
         }
      }
      }
   }
   ; End function, File Save

   ; Cleaning, Functions for cleaning up temporary files from previus grabs
       IfExist %TmpDir%\%TmpFile%.ppm
        {
          FileDelete %TmpDir%\%TmpFile%.ppm
          if ErrorLevel <> 0
          {   
            MsgBox The attempt to remove "%TmpDir%\%TmpFile%.ppm" failed.
            return
          }
        }
   
        IfExist %TmpDir%\%TmpFile%.%ImageFormat%
        {
          FileDelete %TmpDir%\%TmpFile%.%ImageFormat%
          if ErrorLevel <> 0
          {   
            MsgBox The attempt to remove "%TmpDir%\%TmpFile%.%ImageFormat%" failed.
            return
          }
        }
       
        IfExist %TmpDir%\%TmpFile%.txt
        {
          FileDelete %TmpDir%\%TmpFile%.txt
          if ErrorLevel <> 0
          {   
            MsgBox The attempt to remove "%TmpDir%\%TmpFile%.txt" failed.
            return
          }
        }
   
        IfExist %TmpDir%\%TmpFile%.png
        {
          FileDelete %TmpDir%\%TmpFile%.png
          if ErrorLevel <> 0
          {   
            MsgBox The attempt to remove "%TmpDir%\%TmpFile%.png" failed.
            return
          }
        } 
   ; End Cleaning funtions
   
   ; Write, function to write the screengrab image to file
   FileAppend, %file_data%, *%TmpDir%\%TmpFile%.ppm
   
   ; Start Preprocessing image
   
   if mkb_i = 1
   {
      mkb_ii :="-i "
   }
   else
   {
      mkb_ii =
   }
   
   RunWait, %mkbitmap_path%\mkbitmap %mkb_ii% -f %mkb_f% -s %mkb_s% -t %mkb_t% -o %TmpFile%.pbm %TmpFile%.ppm, %TmpDir%, hide,
   
   IfNotExist %TmpDir%\%TmpFile%.pbm
   {
		MsgBox,
		(
		Running mkbitmap "%TmpDir%\%TmpFile%.pbm" failed.
		%mkbitmap_path%\mkbitmap %mkb_ii% -f %mkb_f% -s %mkb_s% -t %mkb_t% -o %TmpFile%.pbm %TmpFile%.ppm
        )
		return
   }
   
   If pre_potrace = 1
   {
      if pot_i = 1
      {
         pot_ii =-i
      }
      else
      {
         pot_ii =
      }
      if pot_n = 1
      {
         pot_nn :="-n "
      }
      else
      {
         pot_nn =
      }
		RunWait, cmd /c %potrace_path%\potrace %pot_ii%%pot_nn%-o %pot_o% -k %pot_k% -r %pot_r% -t %pot_t% -g -a %pot_a% -o %TmpFile%.pgm %TmpFile%.pbm, %TmpDir%, hide,
      IfNotExist %TmpDir%\%TmpFile%.pgm
		{
			MsgBox,
			(
			Running potrace "%TmpDir%\%TmpFile%.pgm" failed.
			cmd /c %potrace_path%\potrace %pot_ii%%pot_nn%-O %pot_o% -k %pot_k% -r %pot_r% -t %pot_t% -g -a %pot_a% -o %TmpFile%.pgm %TmpFile%.pbm
			)
			return
		}
      RunWait, cmd /c %convert_path%\convert %TmpFile%.pgm %TmpFile%.pbm, %TmpDir%, hide,
	}
	; End Preprocessing
   
	; Start OCR processing
	
	; Need to run gocr thru cmd, ???
	RunWait, cmd /c %gocr_path%\gocr -i %TmpDir%\%TmpFile%.pbm -s %ocr_s% -d %ocr_d% -m %ocr_m% -n %ocr_n% -o %TmpFile%.txt, %TmpDir%, hide,
   IfNotExist %TmpDir%\%TmpFile%.txt
	{
		MsgBox,
		(
		Running gocr "%TmpDir%\%TmpFile%.txt" failed.
		cmd /c %gocr_path%\gocr %TmpDir%\%TmpFile%.pbm -s %ocr_s% -d %ocr_d% -m %ocr_m% -n %ocr_n% -o %TmpFile%.txt
		)
		return
	}

   FileRead, ocr_text, %TmpDir%\%TmpFile%.txt
   
   ; Test Tesseract, a other OCR

   ; Tesseract needs a BMP image
   RunWait, cmd /c %convert_path%\convert %TmpFile%.pbm %TmpFile%.t.bmp, %TmpDir%, hide,

	; Start OCR processing
   RunWait, cmd /c %tesseract_path%\tesseract %TmpFile%.t.bmp %TmpFile%.t, %TmpDir%, hide,
   IfNotExist %TmpDir%\%TmpFile%.t.txt
	{
		MsgBox,
		(
		Running gocr "%TmpDir%\%TmpFile%.t.txt" failed.
      cmd /c %tesseract_path%\tesseract %TmpFile%.t.bmp output %TmpFile%.t.txt
		)
		return
	}
   
   FileRead, ocr_t_text, %TmpDir%\%TmpFile%.t.txt

   ; Save the raw OCR result into variable, could be useful
   ocr_raw =%ocr_text%
   ocr_t_raw =%ocr_t_text%

   ; End OCR processing
   
   ; Start OCR postprocessing
   
   
   ; Remove all CR+LF's from the contents
   If NoLineReturn = 1
   {
      StringReplace, ocr_text, ocr_text, `r`n, , All
   }
   
   ; Remove all underscors from the contents:
   StringReplace, ocr_text, ocr_text, _, " ", All
   
   ; Remove all spaces from the contents:
   StringReplace, ocr_text, ocr_text, %A_SPACE%, , All

   ; Remove all " from the contents:
   StringReplace, ocr_text, ocr_text, """, "", All

   /*
   ; Only allow characters in CharOK, not finished
   CharOk := "abc"
   Loop
   {
      IfInString, CharOK, `r`n
   }
   */

   ; End OCR postprocessing
   
   ; Copy postprocessed text to clipboard
   Clipboard =%ocr_text%
   

   /*
   ; Functions to post the result into a search
   #g::
     Send, ^c
     Run, http://www.google.com/search?q=%Clipboard%
   Return
   
   #w::
     Send, ^c
     Run, http://en.wikipedia.org/wiki/Special:Search?search=%Clipboard%
   Return
   */
   
   
   ; Start GUI info Windows, function to show what we got, and how. For debugging mainly
   If InfoWindow = 1
   {

   ; Print size data of screengrab
   Gui, +owner
   Gui, font, s10, Verdana  ; Set 10-point Verdana.
   Gui, Add, Text,, The hight is %hight%, %scan_y_start% - %scan_y_end%.
   Gui, Add, Text,, The width is %width%, %scan_x_start% - %scan_x_end%.
   
   ; Show asci of raw screengrab in hex and preprocessed to rgb
   
   ; Start Fix, Edit field seems to krasch if large
   ImageArea := hight * width
   
   hex =Grab to large to show all hex, show first 10000 chars ony
   rgb =Grab to large to show all rgb, show first 10000 chars ony


   
   If ImageArea < 1000
   {
      hex =%scan_current_line_source%
      rgb =%scan_current_line%
      gui, font,s2, Terminal   
      Gui, Add, Edit, w600 h100 -wrap +HScroll +VScroll, %hex%
      Gui, Add, Edit, w600 h100 -wrap +HScroll +VScroll, %rgb%
   }
   else
   {
      StringLeft, hex_short, scan_current_line_source, 10000
      StringLeft, rgb_short, scan_current_line, 10000

      Gui, font, s10, Verdana  ; Set 10-point Verdana.
      Gui, Add, Text,, %hex%
      gui, font,s2, Terminal   
      Gui, Add, Edit, w600 h100 -wrap +HScroll +VScroll, %hex_short%

      Gui, font, s10, Verdana  ; Set 10-point Verdana.
      Gui, Add, Text,, %rgb%
      gui, font,s2, Terminal   
      Gui, Add, Edit, w600 h100 -wrap +HScroll +VScroll, %rgb_short%
   }
   ; End fix

   
   Gui, font, s10, Verdana  ; Set 10-point Verdana.

   ; Convert images to compatible format for GUI, adjust size if large screengrab
   
   If ImageArea > 5000
   {
      ; convert options to resize image
      con_options =-resize 300x200
   }
   RunWait, cmd /c %convert_path%\convert %con_options% %TmpFile%.ppm %TmpFile%.bmp, %TmpDir%, hide,
   RunWait, cmd /c %convert_path%\convert %con_options% %TmpFile%.pbm %TmpFile%_ocr.bmp, %TmpDir%, hide,

   Gui, Add, Picture,, %TmpDir%\%TmpFile%.bmp
   Gui, Add, Picture,, %TmpDir%\%TmpFile%_ocr.bmp
   Gui, Add, Text,,
   (
      Text from OCR:
   )
   Gui, Add, Edit, xp+100, %Clipboard%
   Gui, Add, Edit, xp+150, %ocr_t_text%
   Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
   Gui, Add, Button, Default xp+60, Rerun
   Gui, Show, AutoSize,
   Return
   
   ButtonOK:
      GuiClose:
      GuiEscape:
      Gui Destroy
   Return
   
   ButtonRerun: 
      Gui, Submit
      Gosub, MainProcess
   Return

   }
   ; End GUI info Window
   
   /*
   ; Alternate method for positioning of screengrab
   ; press ctrl-alt-b (for "begin")
   ^!b::
      CoordMode, Mouse, Screen
      MouseGetPos, scan_x_start, scan_y_start
   return
   */
   
   ; Clean up tmp
   FileDelete %TmpDir%\%TmpFile%.ppm ; Color image, the raw screengrab picture
   FileDelete %TmpDir%\%TmpFile%.pgm ; Gray
   FileDelete %TmpDir%\%TmpFile%.pbm ; BW
   FileDelete %TmpDir%\%TmpFile%.txt
   
   Return

Return

AboutOptions:
Gui, 2:+owner  ; Make the main window (Gui #1) the owner of the "about box" (Gui #2).
Gui +Disabled  ; Disable main window.
Gui, font, s12, Verdana  ; Set 10-point Verdana.
Gui, 2:Add, Text,, Tool for Text extraction from Screen grabs
Gui, 2:Add, Text,, Options:
Gui, 2:Add, Text, xs+10, Image Preprocessing

Gui, 2:Add, Text, xs+20, mkbitmap:
Gui, font, s10, Verdana  ; Set 10-point Verdana.
Gui, 2:Add, Checkbox, vmkb_i checked%mkb_i% xs+25, Invert image
Gui, 2:Add, Edit, w35 vmkb_f xs+25, %mkb_f%
Gui, 2:Add, Text, xp+40, Highpassfilter
Gui, 2:Add, Edit, w35 vmkb_t xs+25, %mkb_t%
Gui, 2:Add, Text, xp+40, Threshold
Gui, 2:Add, Edit, w35 vmkb_s xs+25, %mkb_s%
Gui, 2:Add, Text, xp+40, Scale by integer factor
Gui, 2:Add, Radio, Group vmkb_s1 checked%mkb_s1% xs+25, Liner interpolation
Gui, 2:Add, radio, vmkb_s2 checked%mkb_s2% xs+25, Cubic interpolation

Gui, font, s12, Verdana  ; Set 10-point Verdana.
Gui, 2:Add, Text, xs+20, potrace:
Gui, font, s10, Verdana  ; Set 10-point Verdana.
Gui, 2:Add, Checkbox, vprepotrace checked%prepotrace% xs+25, Run thrue potrace
Gui, 2:Add, DropDownList, w100 vpot_z checked%pot_z% xs+25, black|white|right|left|minority||majority|random
Gui, 2:Add, Text, xp+110, Path decomposition
Gui, 2:Add, Edit, w35 vpot_t xs+25, %pot_t%
Gui, 2:Add, Text, xp+40, Speckles size to remove
Gui, 2:Add, Edit, w35 vpot_a xs+25, %pot_a%
Gui, 2:Add, Text, xp+40, Corner threshold
Gui, 2:Add, Checkbox, vpot_n checked%pot_n% xs+25, No curv optimization
Gui, 2:Add, Edit, w35 vpot_o xs+25, %pot_o%
Gui, 2:Add, Text, xp+40, Curve optimizion tolerance
Gui, 2:Add, Edit, w35 vpot_u xs+25, %pot_u%
Gui, 2:Add, Text, xp+40, Quantize output to 1/unit pixel
Gui, 2:Add, Edit, w35 vpot_k xs+25, %pot_k%
Gui, 2:Add, Text, xp+40, Black/white cutof
Gui, 2:Add, Checkbox, vpot_i checked%pot_i% xs+25, Invert image
Gui, 2:Add, Edit, w35 vpot_r xs+25, %pot_r%
Gui, 2:Add, Text, xp+40, Rotate image clockwise degree

Gui, 2:Add, Text,,

Gui, font, s12, Verdana  ; Set 10-point Verdana.
Gui, 2:Add, Text, xs+10, OCR
Gui, font, s10, Verdana  ; Set 10-point Verdana.
Gui, 2:Add, Text, xs+25, Operational Mode:
Gui, 2:Add, Edit, w35 vocr_m xp+100, %ocr_m%
Gui, 2:Add, Text, xp+40,
(
Operation mode:
4   Barcode
16   divide overlapping chars
32   context correction
64   char packing
)
Gui, 2:Add, Checkbox, vocr_n checked%ocr_n% xs+25, Only numbers
Gui, 2:Add, Text,,
Gui, 2:Add, Text, xs+10, OCR Postprocessing
Gui, 2:Add, Checkbox, vNoLineReturn checked%NoLineReturn% xs+25, Remove line returns.
Gui, 2:Add, Text,,

Gui, font, s12, Verdana  ; Set 10-point Verdana.
Gui, 2:Add, Text, xs+10, GUI
Gui, font, s10, Verdana  ; Set 10-point Verdana.
Gui, 2:Add, Checkbox, vFileSave checked%FileSave%, Allow FileSave
Gui, 2:Add, Checkbox, vInfoWindow checked%InfoWindow%, Show Info Window.
Gui, 2:Add, Text,,
Gui, 2:Add, Button, Default, OK
Gui, 2:Add, Button, Default xp+50, Save
Gui, 2:Add, Button, Default xp+50, Cancel
Gui, 2:Show, r x50
Return

2ButtonOK:
Gui, 1:-Disabled  ; Re-enable the main window (must be done prior to the next step).
Gui, Submit
Gui Destroy  ; Destroy the about box.
Return

2ButtonCancel:
Gui, 1:-Disabled  ; Re-enable the main window (must be done prior to the next step).
Gui Destroy  ; Destroy the about box.
Return

2ButtonSave:
Gui, Submit, NoHide
Gui, 1:-Disabled  ; Re-enable the main window (must be done prior to the next step).
Return

#^r:: ; Reload this script
   Reload
Return