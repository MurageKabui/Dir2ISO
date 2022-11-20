#include-once


#cs

	Author   : Dennis Kabui
	Remarks  : Some more Test Cases

#ce



; *** IMAPI2 Media Types
$TYPE_UNKNOWN = 0 ; Media not present OR is unrecognized
$TYPE_CDROM = 1 ; CD-ROM
$TYPE_CDR = 2 ; CD-R
$TYPE_CDRW = 3 ; CD-RW
$TYPE_DVDROM = 4 ; DVD-ROM
$TYPE_DVDRAM = 5 ; DVD-RAM
$TYPE_DVDPLUSR = 6 ; DVD+R
$TYPE_DVDPLUSRW = 7 ; DVD+RW
$TYPE_DVDPLUSR_DUALLAYER = 8 ; DVD+R dual layer
$TYPE_DVDDASHR = 9 ; DVD-R
$TYPE_DVDDASHRW = 10 ; DVD-RW
$TYPE_DVDDASHR_DUALLAYER = 11 ; DVD-R dual layer
$TYPE_DISK = 12 ; Randomly writable

; *** IMAPI2 Data Media States
$STATE_UNKNOWN = 0
$STATE_INFORMATIONAL_MASK = 15
$STATE_UNSUPPORTED_MASK = 61532 ;0xfc00
$STATE_OVERWRITE_ONLY = 1
$STATE_BLANK = 2
$STATE_APPENDABLE = 4
$STATE_FINAL_SESSION = 8
$STATE_DAMAGED = 1024 ;0x400
$STATE_ERASE_REQUIRED = 2048 ;0x800
$STATE_NON_EMPTY_SESSION = 4096 ;0x1000
$STATE_WRITE_PROTECTED = 8192 ;0x2000
$STATE_FINALIZED = 16384 ;0x4000
$STATE_UNSUPPORTED_MEDIA = 32768 ;0x8000

; Interface Used to enumerate the CD and DVD devices installed on the computer.
Global $O_MS_DISKMASTER = 'IMAPI2.MsftDiscMaster2'
; Used for Various ops like ejecting media, closing tray
Global $O_MS_DISKREC2 = 'IMAPI2.MsftDiscRecorder2'


; Create an interface represents a physical device. Object Contains unique identifiers for PC devices.
$oDiscMaster = ObjCreate($O_MS_DISKMASTER)

For $oObj In $oDiscMaster
	ConsoleWrite(' Found a Object :' & $oObj & @CRLF)
	; Used and to perform operations such as closing the tray or eject the media.
	$oRecorder = ObjCreate($O_MS_DISKREC2)
	; Associates the object with the specified disc device.
	$res = $oRecorder.InitializeDiscRecorder($oObj)
	ConsoleWrite('$res = ' & $res & @CRLF)
Next

; Create an Interface to write data stream to a disc.
Global $oDataWriter = ObjCreate('IMAPI2.MsftDiscFormat2Data')
$oDataWriter.recorder = $oRecorder

If ($oDataWriter.IsRecorderSupported($oRecorder)) Then
	ConsoleWrite('Recorder ' & $oRecorder & ' IS supported.' & @CRLF)
Else
	ConsoleWrite('Recorder ' & $oRecorder & ' IS NOT supported.' & @CRLF)
EndIf

If ($oDataWriter.IsCurrentMediaSupported($oRecorder)) Then
	ConsoleWrite('> Current media IS supported' & @CRLF)
Else
	ConsoleWrite('> Current media IS NOT supported' & @CRLF)
EndIf

; Retrieves the friendly name of the client.
$fname = $oDataWriter.ClientName
$cstate = $oDataWriter.CurrentMediaStatus()

ConsoleWrite( _
		'ClientName          : ' & $fname & @CRLF & _
		'Current Media State : ' & $cstate & @CRLF)

$ret = Null
Select
	Case BitAND($cState, $STATE_UNKNOWN)
		$ret &= 'Media state is unknown.'
	Case BitAND($cState, $STATE_OVERWRITE_ONLY)
		$ret &= 'Currently, only overwriting is supported.'
	Case BitAND($cState, $STATE_APPENDABLE)
		$ret &= 'Media is currently appendable.'
	Case BitAND($cState, $STATE_FINAL_SESSION)
		$ret &= 'Media is in final writing session.'
	Case BitAND($cState, $STATE_DAMAGED)
		$ret &= 'Media is damaged.'
EndSelect
ConsoleWrite('Current Media info : ' & $ret & @CRLF)


$mediaType = $oDataWriter.CurrentPhysicalMediaType
ConsoleWrite("Current Media Type : " & $mediaType & @CRLF)



; Kill all objects
$oDiscMaster = Null
$oDataWriter = Null
