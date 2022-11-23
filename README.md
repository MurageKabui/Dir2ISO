
<p align="center">
	Run with -? for help.
	<hr>
</p>

CL-DIR2ISOfs

### Commandline Switches.


|Switch| Type  | Description | Default Value|Sample Usage|
|--|--|--|--|--|
| -*i* | string | Specify a FQPN to a Source Directory.| *None* | -*i "E:\MyFolder"*|
|-*o*  | string|  Specify the .ISO File Output.| *None*| -*o "E:\MyFolder\MyISO.iso"*|
|-*l*| string| Specify the .ISO Volume label. <br> **15** chars MAX| Current system date and time | -*l "My Disk_2022"* |

<hr>

## Return codes

|Value | Description|
|--|--|
| 0 | Success. |
| 5| Volume Label Provided on *-l* is Invalid. Allowed characters are alphabets, digits and underscore.|
|2| 
