#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Dir2ISOfs.ico
#AutoIt3Wrapper_Outfile=CL-Dir2ISOfs.exe
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Dir2ISOfs
#AutoIt3Wrapper_Res_Description=Run with -? for help.
#AutoIt3Wrapper_Res_Fileversion=1.0.2.25
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_ProductName=Dir2ISOfs
#AutoIt3Wrapper_Res_CompanyName=Zainahtech Services Consultants
#AutoIt3Wrapper_Res_LegalCopyright=Zainahtech Services Consultants
#AutoIt3Wrapper_Res_LegalTradeMarks=Zainahtech Services Consultants
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/reel /rel /kv 10 /sf
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/sv /so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include-once

; For regex
#include <string.au3>
; for sys time
#include <Date.au3>


; #FUNCTION# ====================================================================================================================
; Name...........: CL-Dir2ISOfs
; Description ...: Leveraging WinAPI's IMAPI2 interface to programmatically create and pack to a ISO file system.
; Author ........: Dennis Murage Kabui
; Link ..........; https://learn.microsoft.com/en-us/windows/win32/api/imapi2fs/nn-imapi2fs-ifilesystemimage
; Example .......; none
; ===============================================================================================================================

Global Enum $EXIT_SUCCESS, _
		$ERROR_SYNTAX, _
		$ERROR_OUTPUT_MISSING, $ERROR_INPUT_MISSING, _
		$ERROR_INVALID_VOLUME_LABEL

Global Const $KEYWORD_NULL_ = 2

Global Const $S_G_CMDARG1 = _CmdLine_GetValByIndex(1, '') ; arg1

Global Const $S_G_HELP = _
		@CRLF & '   This application helps you easily Pack Directories to a .ISO' & _
		@CRLF & '   file system. See API Docs at https://tinyurl.com/4ke4mtt3' & _
		@CRLF & '   ' & @ScriptName & ' [-i DirectoryPath] [-o OutputFile.iso]  ..' & _
		@CRLF & '                    [-l VolumeLabel]] [/debug-off]' & _
		@CRLF & _
		@CRLF & '   Switches' & _
		@CRLF & '           -i   Specify an Input Path to an existing Directory.' & _
		@CRLF & '           -o   Specify an Output path for the created .ISO file.' & _
		@CRLF & '           -l   Specify a volume label. [15 chars max; a-z, A-Z, 0-9]' & _
		@CRLF & _
		@CRLF & '   Flags' & _
		@CRLF & '           /v-off  Turn off STDOUT verbosity on errors.' & @CRLF & _
		@CRLF & '  Example' & _
		@CRLF & '   ' & @ScriptName & ' -i "E:\BDayPhotos" -o "E:\BDayPhotos.iso" -l "24th BDay"' & _
		@CRLF & @CRLF

Switch $S_G_CMDARG1
	Case '', '-?', '/?', '-h', '-help', '/help', 'help'
		ConsoleWrite('   ' & @ScriptName & ' v' & FileGetVersion(@ScriptFullPath) & ' by Murage Kabui.' & @CRLF & $S_G_HELP)
		Exit ($EXIT_SUCCESS)
EndSwitch

; Get current system time for using on the default disk volume label.
; Global $tCur = _Date_Time_GetSystemTime()
; Global Const $S_DEF_LABEL = _Date_Time_SystemTimeToDateTimeStr($tCur)


; Validate inputs
Global Const $S_G_INPUTFQPN = _CmdLine_Get('i', Null)
Global Const $S_G_OUTPUTFQPN = _CmdLine_Get('o', Null)
Global Const $S_G_VOLUME_LABEL = String(_CmdLine_Get('l', _NowCalcDate())) ; Sets a String that contains the volume name for this file system image
Global Const $B_G_VERSBOSITY = Not _CmdLine_KeyExists('v-off') ; Turn off STDOUT Verbosity.


If (IsKeyword($S_G_INPUTFQPN) = $KEYWORD_NULL_ Or IsKeyword($S_G_OUTPUTFQPN) = $KEYWORD_NULL_) Then
	If $B_G_VERSBOSITY Then ConsoleWriteError(' Error: Syntax is incorrect. Missing parameters, Run with -? for help.' & $S_G_HELP)
	Exit ($ERROR_SYNTAX)
EndIf


; Validate switches [-i Dir and -o file] are Specified, Exists and Valid.
If (Not _CmdLine_KeyExists('i') Or Not (Number(FileExists($S_G_INPUTFQPN) And StringInStr(FileGetAttrib($S_G_INPUTFQPN), "D", 2, 1) > 0))) Then

	If $B_G_VERSBOSITY Then ConsoleWriteError('Error : The Specified Directory "' & $S_G_INPUTFQPN & '" ' & (FileExists($S_G_INPUTFQPN) ? ('is INVALID.') : ('does not Exist.')) & @CRLF)
	Exit ($ERROR_SYNTAX + $ERROR_INPUT_MISSING)

ElseIf (Not _CmdLine_KeyExists('o')) Then
	If $B_G_VERSBOSITY Then ConsoleWriteError('Error : Output .iso File unspecified. Run With -? for help.' & @CRLF)
	Exit ($ERROR_SYNTAX + $ERROR_OUTPUT_MISSING)
EndIf

; From Docs:
; Set the volume name for this file system image. If no volume name, a default volume name
; is generated using the system date and time when the result object is created.
; See (https://learn.microsoft.com/en-us/windows/win32/api/imapi2fs/nf-imapi2fs-ifilesystemimage-put_volumename)
; The volume label string is limited to 15 characters.
;     - For ISO 9660 discs, the volume name can use : [A-Z] ,[0-9] , [_]
;     - For Joliet and UDF discs                    : [a-z] ,[A-Z] , [0-9], [_], [.]


; '^[\s\da-zA-Z_.]*$' - for For Joliet and UDF discs
If Not (StringRegExp($S_G_VOLUME_LABEL, '^[\s\da-zA-Z_:/]*$') = 1) Then
	If $B_G_VERSBOSITY Then ConsoleWriteError('Error : Volume Label "' & $S_G_VOLUME_LABEL & '" is Invalid. Allowed characters are alphanumeric, underscore and period.' & @CRLF)
	Exit ($ERROR_SYNTAX + $ERROR_INVALID_VOLUME_LABEL)
EndIf

If (StringLen($S_G_VOLUME_LABEL) >= 16) Then
	If $B_G_VERSBOSITY Then ConsoleWriteError('Error : Volume Label "' & $S_G_VOLUME_LABEL & '" Provided exceeds 15 characters.' & @CRLF)
	Exit ($ERROR_SYNTAX + $ERROR_INVALID_VOLUME_LABEL)
EndIf



; Error monitoring. This will trap all COM errors while alive.
Global $oErrorHandler = ObjEvent("AutoIt.Error", "_ErrFunc")
Global $oFS = ObjCreate("IMAPI2FS.MsftFileSystemImage")

$oFS.FreeMediaBlocks = 0
$oFS.VolumeName = $S_G_VOLUME_LABEL
$oFS.Root.AddTree($S_G_INPUTFQPN, False)

Global $oRImage = $oFS.CreateResultImage()

Global $oImgStream = ObjCreateInterface($oRImage.ImageStream(), _
		'{0000000c-0000-0000-C000-000000000046}', _
		"D1 hresult();D2 hresult();D3 hresult();D4 hresult();CopyTo hresult(ptr;UINT64;UINT64*;UINT64*);" & _
		"D8 hresult();D9 hresult();D10 hresult();D11 hresult();Stat hresult(struct*;dword);")

Global $tSTATSTG = DllStructCreate("byte[" & (@AutoItX64 ? 80 : 72) & "]")

$oImgStream.Stat($tSTATSTG, 0x1)
Global $icbSize = (DllStructCreate("UINT64 cbSize", DllStructGetPtr($tSTATSTG) + (@AutoItX64 ? 16 : 8))).cbSize
Global $pFileStream = __MD_SHCreateStreamOnFile($S_G_OUTPUTFQPN)
Global $iRead, $iWritten
$oImgStream.CopyTo($pFileStream, $icbSize, $iRead, $iWritten)


Exit ($EXIT_SUCCESS)



;Create File Stream
Func __MD_SHCreateStreamOnFile($sFilePath, $igrfMode = 0x00001001)
	Local $aCall = DllCall("shlwapi.dll", "long", "SHCreateStreamOnFileW", "wstr", $sFilePath, "dword", $igrfMode, "ptr*", 0)
	If $aCall[0] = 0 Then
		Return $aCall[3]
	EndIf
	Return 0
EndFunc   ;==>__MD_SHCreateStreamOnFile


Func _CmdLine_Get($sKey, $mDefault = Null)
	For $i = 1 To $CmdLine[0]
		If $CmdLine[$i] = "/" & $sKey Or $CmdLine[$i] = "-" & $sKey Then             ; Or $CmdLine[$i] = "--" & $sKey
			If $CmdLine[0] >= $i + 1 Then
				Return $CmdLine[$i + 1]
			EndIf
		EndIf
	Next
	Return $mDefault
EndFunc   ;==>_CmdLine_Get



Func _CmdLine_GetValByIndex($iIndex, $mDefault = Null)
	If $CmdLine[0] >= $iIndex Then
		Return $CmdLine[$iIndex]
	Else
		Return $mDefault
	EndIf
EndFunc   ;==>_CmdLine_GetValByIndex

Func _CmdLine_KeyExists($sKey)
	For $i = 1 To $CmdLine[0]
		If $CmdLine[$i] = "/" & $sKey Or $CmdLine[$i] = "-" & $sKey Or $CmdLine[$i] = "--" & $sKey Then
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>_CmdLine_KeyExists


; User's COM error function. Will be called if COM error occurs
Func _ErrFunc($oError)
	; Do anything here.
	If $B_G_VERSBOSITY Then ConsoleWriteError('    ' & @ScriptName & " (" & $oError.scriptline & ") : ==> A COM Error was intercepted !" & @CRLF & _
			@TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
			@TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
			@TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
			@TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
			@TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
			@TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
			@TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
			@TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
			@TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>_ErrFunc
