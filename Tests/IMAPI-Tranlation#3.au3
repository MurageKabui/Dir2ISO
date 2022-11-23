#NoTrayIcon


; Error monitoring. This will trap all COM errors while alive.
; This particular object is declared as local, meaning after the function returns it will not exist.
Local $oErrorHandler = ObjEvent("AutoIt.Error", "_ErrFunc")

;~ ' *** CD/DVD disc file system types
Const $FsiFileSystemNone     = 0
Const $FsiFileSystemISO9660  = 1
Const $FsiFileSystemJoliet   = 2
Const $FsiFileSystemUDF      = 4
Const $FsiFileSystemUnknown  = 1073741824

;~ ' *** Media Physical Type Enumeration
Const $IMAPI_MEDIA_TYPE_DISK = 12

Main()

Func Main()
    Dim $FSI                         ; Disc file system
    Dim $InputStream                 ; Data stream for the image
    Dim $OutputStream                ; Output file stream
    Dim $SourceDirectory             ; Input directory
    Dim $VolumeName
    Dim $OutputIsoName
    Dim $ResultImage
    Dim $ImageSize
    Dim $WrittenBytes
    Dim $sf

    $SourceDirectory = @ScriptDir & "\TestISO"
    $VolumeName = "MyVolume"
    $OutputIsoName = "MyImage.iso"

    ; Create a new file system image and retrieve root directory
    $FSI = ObjCreate("IMAPI2FS.MsftFileSystemImage")
    $FSI.ChooseImageDefaultsForMediaType($IMAPI_MEDIA_TYPE_DISK)
    $FSI.FileSystemsToCreate = $FsiFileSystemJoliet + $FsiFileSystemISO9660
    $FSI.VolumeName = "VolumeName"
    $FSI.Root.AddTree ($SourceDirectory, false) ;(string sourceDir, bool includeBaseDir)

    ; Create the Image and pass the IMAPI.IStream to an object that supports IStream
    $ResultImage = $FSI.CreateResultImage()
    $InputStream = ObjCreate("newObjects.utilctls.SFStream")
    ConsoleWrite(IsObj($InputStream) & @CRLF)
    $InputStream.SetStream($ResultImage.ImageStream)

    ; Create the output file and write the stream

    $sf = ObjCreate("newObjects.utilctls.SFMain") ;here you can use ADODB instead
    $OutputStream = $sf.CreateFile($OutputIsoName)
    $ImageSize = $InputStream.Size
    $WrittenBytes =$OutputStream.WriteBin($InputStream.ReadBin($ImageSize))
    $OutputStream.close
    ConsoleWrite($ImageSize & @CRLF)
    ConsoleWrite($WrittenBytes & @CRLF)
EndFunc



; User's COM error function. Will be called if COM error occurs
Func _ErrFunc($oError)
    ; Do anything here.
    ConsoleWrite(@ScriptName & " (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
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
