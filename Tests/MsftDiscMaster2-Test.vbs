;Create Needed Objects
oDiscMaster = CreateObject("IMAPI2.MsftDiscMaster2")
ForEach ID in oDiscMaster ;If you know the Drive ID/number, no need for the loop
oRecorder=CreateObject("IMAPI2.MsftDiscRecorder2")
oRecorder.InitializeDiscRecorder( ID )
Next
oDataWriter = CreateObject ("IMAPI2.MsftDiscFormat2Data")
oDataWriter.recorder = oRecorder
If oDataWriter.IsRecorderSupported(oRecorder)
cOut=cOut:"--- Current recorder IS supported. ---":@CRLF
Else
cOut=cOut:"Current recorder IS NOT supported.":@CRLF
Endif
If oDataWriter.IsCurrentMediaSupported(oRecorder)
cOut=cOut:"--- Current media IS supported. ---":@CRLF
Else
cOut=cOut:"Current media IS NOT supported.":@CRLF
Endif
cOut=cOut:"ClientName = ":oDataWriter.ClientName:@CRLF:@CRLF:"Current Media State":@CRLF
cState=oDataWriter.CurrentMediaStatus
If STATE_UNKNOWN & cState
cOut=cOut:" Media state is unknown.":@CRLF
Endif
If STATE_OVERWRITE_ONLY & cState
cOut=cOut:" Currently, only overwriting is supported.":@CRLF
Endif

If STATE_APPENDABLE & cState
cOut=cOut:" Media is currently appendable.":@CRLF
Endif

If STATE_FINAL_SESSION & cState
cOut=cOut:" Media is in final writing session.":@CRLF
Endif

If STATE_DAMAGED & cState
cOut=cOut:" Media is damaged.":@CRLF
Endif
cOut=cOut:@CRLF:"Current Media Type":@CRLF
mediaType = oDataWriter.CurrentPhysicalMediaType
Select mediaType
Case TYPE_UNKNOWN
cOut=cOut:" Empty device or an unknown disc type.":@CRLF
Break
Case TYPE_CDROM
cOut=cOut:" CD-ROM":@CRLF
Break
Case TYPE_CDR
cOut=cOut:" CD-R":@CRLF
Break
Case TYPE_CDRW
cOut=cOut:" CD-RW":@CRLF
Break
Case TYPE_DVDROM
cOut=cOut:" Read-only DVD drive and/or disc":@CRLF
Break
Case TYPE_DVDRAM
cOut=cOut:" DVD-RAM":@CRLF
Break
Case TYPE_DVDPLUSR
cOut=cOut:" DVD+R":@CRLF
Break
Case TYPE_DVDPLUSRW
cOut=cOut:" DVD+RW":@CRLF
Break
Case TYPE_DVDPLUSR_DUALLAYER
cOut=cOut:" DVD+R Dual Layer media":@CRLF
Break
Case TYPE_DVDDASHR
cOut=cOut:" DVD-R":@CRLF
Break
Case TYPE_DVDDASHRW
cOut=cOut:" DVD-RW":@CRLF
Break
Case TYPE_DVDDASHR_DUALLAYER
cOut=cOut:" DVD-R Dual Layer media":@CRLF
Break
Case TYPE_DISK
cOut=cOut:" Randomly-writable, hardware-defect managed media type ":@CRLF
cOut=cOut:" that reports the 'Disc' profile as current.":@CRLF
EndSelect
oData=nothing
oRecordset=nothing
oDiscMaster=nothing
Message("Recordable Device",cOut)
Exit