

### What is DIR2ISO?
   
This commandline application and AutoIT UDF helps you easily create and pack <br>
local directories to an [ISO image](https://en.m.wikipedia.org/wiki/Optical_disc_image) from AutoIT.

[Visit Microsoft's WinAPI Docs](https://learn.microsoft.com/en-us/windows/win32/api/imapi2fs/nn-imapi2fs-ifilesystemimage)

### **Minimum** supported client

> Windows Vista, Windows XP with SP2 [desktop apps only]



<hr>

## Commandline Version

### Switches.


|Switch| Input Type  | Description | Default Value|Sample Usage|
|--|--|--|--|--|
| -*i* | string | Specify a FQPN to a Source Directory.| *None* | -*i "E:\MyFolder"*|
|-*o*  | string|  Specifies the output .ISO Image File.| *None*| -*o "E:\MyFolder\MyISO.iso"*|
|-*l*| string| Sets the volume name for this file system image.<br>Expects a String that contains the volume name for this file system image. <br> The string is limited to **15 characters**.| Current Date in format YYYY/MM/DD | -*l "My Disk_2022"* |


## Return codes

|Value | Description|
|--|--|
|0 | Success. |
|4| An Invalid Source Directory is specified on *-i* switch.|
|5| An invalid Volume label And/or The length exceeds **15** characters.<br>Allowed characters are alphanumeric, underscore, colon and forward slash|


## Example

> CL-Dir2ISOfs.exe -i "E:\Pictures" -o BirthdayPics.iso -l "24th Birthday"
