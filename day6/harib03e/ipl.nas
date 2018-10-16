; haribote-ipl
; TAB=4
CYLS	EQU		10
	ORG		0x7c00

	JMP		entry
	DB		0x90
	DB		"HARIBOTE"
	DW		512
	DB		1
	DW		1
	DB		2
	DW		224
	DW		2880
	DB		0xf0
	DW		9
	DW		18
	DW		2
	DD		0
	DD		2880
	DB		0,0,0x29
	DD		0xffffffff
	DB		"HARIBOTEOS "
	DB		"FAT12   "
	TIMES	18	DB	0x00

; main program

entry:
	MOV		AX,0
	MOV		SS,AX		; set segment register SS 0
	MOV		SP,0x7c00
	MOV		DS,AX		; set segment register DS 0x7c00

; reading disk
	MOV		AX,0x0820
	MOV		ES,AX		; set segment register ES 0x0820
	MOV		CH,0		; cylinder=0
	MOV		DH,0		; head=0
	MOV		CL,2		; sector=2

readloop:
	MOV		SI,0		; the regsiter that counts number of reading failure

retry:
	MOV		AH,0x02		; select mode : AH=0x02 -> reading disk
	MOV		AL,1		; number of sector that is read from disk
	MOV		BX,0		
	MOV		DL,0x00		; drive number(0x00 - 0x7f : FDD, 0x80 - 0xff ; HDD)
	INT		0x13		
	JNC		next		; when not carry, jump next address
	ADD		SI,1
	CMP		SI,5		
	JAE		error
	MOV		AH,0x00
	MOV		DL,0x00
	INT		0x13
	JMP		retry

next:
	MOV		AX,ES
	ADD		AX,0x0020
	MOV		ES,AX
	ADD		CL,1
	CMP		CL,18
	JBE		readloop
	MOV		CL,1
	ADD		DH,1
	CMP		DH,2
	JB		readloop
	MOV		DH,0
	ADD		CH,1
	CMP		CH,CYLS
	JB		readloop

	MOV		[0x0ff0],CH
	JMP		0xc200

error:
	MOV		SI,msg

putloop:
	MOV		AL,[SI]
	ADD		SI,1
	CMP		AL,0
	JE		fin
	MOV		AH,0x0e		; 1 character display function
	MOV		BX,15		; color code
	INT		0x10		; video BIOS call
	JMP		putloop

fin:
	HLT
	JMP		fin

msg:
	DB		0x0a, 0x0a
	DB		"load error"
	DB		0x0a
	DB		0

	TIMES	0x7dfe-0x7c00-($-$$)	DB	0x00
	DB		0x55, 0xaa

