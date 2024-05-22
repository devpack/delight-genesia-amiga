* _________________________________________________________________ / / /_
*                                                                  / / /
* Flashtro.com                                              ____  / / /
* cracktro source                                           \   \/ / /
* ________________________________________ powered by AMIGA _\ \ \/ /_____
*                                                             \_\_\/
* Delight intro by Paranormal
*  
* original module "synth" by Doh
* 
* resourced by VrS!
* New Startup Code 08/2006

;ASMONE
ORIG

* ------------------------------------- 
PT	; sound/noise/protracker

	IFND	ASMONE
	opt	c-,ow-,o+ 
	ENDC

	IFD	ASMONE
	incdir	"dh0:genesia/"
	ENDC
	
* -------------------------------------
	section paranormal,code

	rsreset
ptAlloc1	rs.l	1
ptAlloc2	rs.l	1
ptBpText	rs.l	1
* ---
ptBpVector1	rs.l	1
ptBpVector2	rs.l	1
deltaX		rs.w	1
deltaY		rs.w	1
deltaZ		rs.w	1
cosX		rs.w	1
sinX		rs.w	1
cosY		rs.w	1
sinY		rs.w	1
cosZ		rs.w	1
sinZ		rs.w	1
ptPlan		rs.l	1
* ---
ptTabNumPts	rs.w	1
ptXoffset	rs.l	1
ptYoffset	rs.l	1
* ---
ptText		rs.w	1
cntWriter	rs.w	1
flagnewchar	rs.w	1
posX		rs.w	1
posY		rs.w	1
VARSIZE2	rs.w	0

WRASTER=302	; waitraster

	bra.s	Start

	dc.b	'Flashtro.com - resourced by VrS! '
	dc.b	'on 08/2006'
	even
	include	"mystartup.i"
* --------------------------------------------------------
* ---------------------------------------------- MAIN PROG
* --------------------------------------------------------
MAIN	
	lea	Vars(pc),a5
	movea.l	4.w,a6
	move.l	#44*283*3,d0
	move.l	#$10002,d1
	jsr	AllocMem(a6)
	move.l	d0,ptAlloc1(a5)
	beq	noMem1
	move.l	d0,ptBpVector1(a5)
	move.l	#44*283*3,d0
	move.l	#$10002,d1
	jsr	AllocMem(a6)
	move.l	d0,ptAlloc2(a5)
	beq.s	noMem2
	move.l	d0,ptBpVector2(a5)
	move.l	#44*283,d0
	move.l	#$10002,d1
	jsr	AllocMem(a6)
	move.l	d0,ptBpText(a5)
	beq.s	noMem3

	bsr	InitAll
	bsr	InitMusic

	lea	Vars(pc),a5
	lea	$dff000,a6

	lea	NewCopper,a0
	move.l	a0,$80(a6)
	move.w	#0,$88(a6)

	lea	newVBL(pc),a0
	lea	VBLpt(pc),a1
	move.l	a0,(a1)

loop	btst	#6,$BFE001
	bne	loop

	bsr	StopMusic
	
	lea	Vars(pc),a5
	movea.l	4.w,a6

	move.l	#44*283,d0
	movea.l	ptBpText(a5),a1
	jsr	FreeMem(a6)

noMem3	move.l	#44*283*3,d0
	movea.l	ptAlloc2(a5),a1
	jsr	FreeMem(a6)

noMem2	move.l	#44*283*3,d0
	movea.l	ptAlloc1(a5),a1
	jsr	FreeMem(a6)
noMem1	rts
* --------------------------------------------
newVBL	lea	Vars(pc),a5
	lea	$dff000,a6
	bsr	CubenSphere
	bsr	Writer
	bsr	PlayMusic
	lea	Vars(pc),a5
	bsr	waitblitter
	movem.l	ptBpVector1(a5),d0-d1
	exg	d0,d1
	movem.l	d0-d1,ptBpVector1(a5)
	move.l	ptBpVector2(a5),d0
	lea	CLvect,a0
	moveq	#3-1,d1
	move.l	#44*283,d2
	bsr	Inst_Plans
	rts
* --------------------------------------------
InitAll:
	lea	Vars(pc),a5
	lea	$dff000,a6

	move.w	#$c00,$106(a6)	; AGA fix
	move.w	#0,$1fc(a6)
	move.w	#$11,$10c(a6)

* - inst bitplans
	move.l	ptBpVector1(a5),d0
	lea	CLvect,a0
	moveq	#3-1,d1
	move.l	#44*283,d2
	bsr	Inst_Plans

	move.l	ptBpText(a5),d0
	lea	CLtext,a0
	moveq	#0,d1
	moveq	#0,d2
	bsr	Inst_Plans

* - init var
	lea	Logo(pc),a0
	movea.l	ptBpText(a5),a1
	adda.l	#11518,a1
	moveq	#5-1,d7
.copy	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	adda.l	#44,a1
	dbf	d7,.copy

	lea	Xoffset,a0
	move.l	a0,ptXoffset(a5)
	lea	Yoffset(pc),a0
	move.l	a0,ptYoffset(a5)
	rts
* --------------------------------------------------------
* - Writer
* --------------------------------------------------------
Writer:
	btst	#0,flagnewchar(a5)
	beq.s	.ok
	cmpi.w	#500,cntWriter(a5)
	bne	.skip
	clr.w	cntWriter(a5)
	bclr	#0,flagnewchar(a5)
	clr.w	posX(a5)
	clr.w	posY(a5)
.ok	movea.l	ptBpText(a5),a0
	adda.l	#44*97+4,a0
	lea	Text(pc),a1
	lea	font(pc),a2
	move.w	ptText(a5),d0
	move.b	(a1,d0.w),d0
	andi.w	#255,d0
	cmp.b	#-1,d0
	bne.s	.notyet
	clr.w	ptText(a5)
	bra.s	Writer

.notyet	subi.b	#'A',d0
	adda.w	d0,a2
	moveq	#7,d7
	cmpi.w	#36,posX(a5)
	bne.s	.nomaxX
	clr.w	posX(a5)

	addi.w	#44*9,posY(a5)
.nomaxX	cmpi.w	#44*9*10,posY(a5)
	bne.s	.nomaxY
	bset	#0,flagnewchar(a5)
	bra	Writer
.nomaxY	adda.w	posX(a5),a0
	adda.w	posY(a5),a0
.copychar
	move.b	(a2),(a0)
	adda.l	#28,a2
	adda.l	#44,a0
	dbf	d7,.copychar
	addq.w	#1,posX(a5)
	addq.w	#1,ptText(a5)
	rts
.skip	addq.w	#1,cntWriter(a5)
	rts
* ---------------------------------------------------------
* - Lightsourced Vector
* ---------------------------------------------------------
CubenSphere:
	bsr	ClearDotsPlan
	bsr	ClearVectorPlans
	bsr	RotateVector
	bsr	DoRotation
	bsr	Projection
	bsr	DrawVector
	bsr	FillVector
	bsr	DotsSphere	; precalculated :(
	rts
* -
ClearVectorPlans:
	lea	adScreen(pc),a0
	move.l	ptBpVector1(a5),(a0)
;
	lea	SaveStack(pc),a0
	move.l	sp,(a0)
	lea	Empty(pc),sp
	movem.l	(sp),d0-d6/a0-a6
	movea.l	adScreen(pc),sp
	adda.l	#44*236,sp
	moveq	#13-1,d7
.cpuclr	movem.l	d0-d6/a0-a6,-(sp) ; 12*56*13
	movem.l	d0-d6/a0-a6,-(sp)
	movem.l	d0-d6/a0-a6,-(sp)
	movem.l	d0-d6/a0-a6,-(sp)
	movem.l	d0-d6/a0-a6,-(sp)
	movem.l	d0-d6/a0-a6,-(sp)
	movem.l	d0-d6/a0-a6,-(sp)
	movem.l	d0-d6/a0-a6,-(sp)
	movem.l	d0-d6/a0-a6,-(sp)
	movem.l	d0-d6/a0-a6,-(sp)
	movem.l	d0-d6/a0-a6,-(sp)
	movem.l	d0-d6/a0-a6,-(sp)
	dbf	d7,.cpuclr
	movea.l	SaveStack(pc),sp
;
	lea	Vars(pc),a5
	lea	$dff000,a6
	movea.l	ptBpVector1(a5),a1
	adda.l	#44*283+44*234+32,a1
	
	bsr	waitblitter
	move.l	#$1000002,BltCon0(a6)
	move.l	#-1,BltAfwm(a6)
	move.w	#44-24,BltDmod(a6)
	move.l	a1,BltDpth(a6)
	move.w	#184*64+24/2,BltSize(a6)
	rts
* -
FillVector:
	movea.l	ptBpVector1(a5),a0
	adda.l	#235*44+32,a0

	bsr	waitblitter
	moveq	#-1,d0
	move.l	#$9F00012,BltCon0(a6)
	move.l	d0,BltAfwm(a6)
	move.l	a0,BltApth(a6)
	move.l	a0,BltDpth(a6)
	move.l	#$140014,BltAmod(a6)	; 44-24
	move.w	#184*64+24/2,BltSize(a6)

	bsr	waitblitter
	adda.l	#44*283,a0
	move.l	a0,BltApth(a6)
	move.l	a0,BltDpth(a6)
	move.w	#184*64+24/2,BltSize(a6)
	rts
* -
RotateVector:
	lea	Coords(pc),a0
	lea	rotatedCoords(pc),a1
	lea	TabCos(pc),a2
	lea	TabSin(pc),a3
	move.w	deltaX(a5),d3
	move.w	deltaY(a5),d4
	move.w	deltaZ(a5),d5
	add.w	d3,d3		; *2
	add.w	d4,d4
	add.w	d5,d5
	move.w	(a2,d3.w),cosX(a5)
	move.w	(a3,d3.w),sinX(a5)
	move.w	(a2,d4.w),cosY(a5)
	move.w	(a3,d4.w),sinY(a5)
	move.w	(a2,d5.w),cosZ(a5)
	move.w	(a3,d5.w),sinZ(a5)
	moveq	#8-1,d7
.loop	movem.w	(a0),d0-d2	; xn,yn,zn
	movem.w	(a0)+,d3-d5	;
	move.w	cosX(a5),d6
	muls.w	d6,d0		; x*cos(xgrad)
	muls.w	d6,d1		; y*cos(xgrad)
	move.w	sinX(a5),d6
	muls.w	d6,d3		; x*sin(xgrad)
	muls.w	d6,d4		; y*sin(xgrad)
	sub.l	d4,d0
	add.l	d3,d1
	asr.l	#8,d0
	asr.l	#8,d1
	asr.l	#1,d0
	asr.l	#1,d1
	move.l	d0,d3
	move.l	d1,d4
	move.l	d2,d5

	move.w	cosY(a5),d6
	muls.w	d6,d0
	muls.w	d6,d2
	move.w	sinY(a5),d6
	muls.w	d6,d3
	muls.w	d6,d5
	sub.l	d5,d0
	add.l	d3,d2
	asr.l	#8,d0
	asr.l	#8,d2
	asr.l	#1,d0
	asr.l	#1,d2
	move.l	d0,d3
	move.l	d1,d4
	move.l	d2,d5

	move.w	cosZ(a5),d6
	muls.w	d6,d1
	muls.w	d6,d2
	move.w	sinZ(a5),d6
	muls.w	d6,d4
	muls.w	d6,d5
	sub.l	d5,d1
	add.l	d4,d2
	asr.l	#8,d1
	asr.l	#8,d2
	asr.l	#1,d1
	asr.l	#1,d2
	move.w	d0,(a1)+	; xr
	move.w	d1,(a1)+	; yr
	move.w	d2,(a1)+	; zr
	dbf	d7,.loop
	rts
* -
Projection:
	lea	rotatedCoords(pc),a0
	lea	TabCoords(pc),a1
	moveq	#8-1,d7
.loop	movem.w	(a0)+,d0-d2	; x,y,z
	sub.l	Z(pc),d2
	lsl.l	#8,d0
	lsl.l	#8,d1
	divs.w	d2,d0
	divs.w	d2,d1
	neg.w	d1
	addi.l	#352/2,d0	; +cx
	addi.l	#282/2,d1	; +cy
	move.w	d0,(a1)+	; x
	move.w	d1,(a1)+	; y
	dbf	d7,.loop
	rts
* -
DoRotation:
	cmpi.w	#360,deltaX(a5)
	bne.s	.y
	clr.w	deltaX(a5)
.y	addq.w	#1,deltaX(a5)
	cmpi.w	#360,deltaY(a5)
	bne.s	.z
	clr.w	deltaY(a5)
.z	addq.w	#2,deltaY(a5)
	cmpi.w	#360,deltaZ(a5)
	bne.s	.skip
	clr.w	deltaZ(a5)
.skip	addq.w	#3,deltaZ(a5)
	rts
* -
DrawVector:
	movea.l	ptBpVector1(a5),a0
	lea	StructCube(pc),a1
	lea	TabCoords(pc),a2
	move.w	NbVect(pc),d7
	
	bsr	waitblitter
	moveq	#-1,d0
	move.w	d0,BltAfwm(a6)
	move.l	#$FFFF8000,BltBdat(a6)
	moveq	#44,d0
	move.w	d0,BltCmod(a6)
	move.w	d0,BltDmod(a6)
.loopvect
; calc. normal/lightsource
	move.w	18(a1),d0	; P1
	move.w	16(a1),d1	; P2
	move.w	20(a1),d2	; P3
	movem.w	(a2,d0.w),d5-d6	; x1,y1
	move.w	(a2,d1.w),d3	; x2
	sub.w	d5,d3		; x2-x1
	move.w	2(a2,d2.w),d4	; y3
	sub.w	d6,d4		; y3-y1
	muls.w	d4,d3		; (x2-x1)*(y3-y1)
	move.w	2(a2,d1.w),d4	; y2
	sub.w	d6,d4		; y2-y1
	move.w	(a2,d2.w),d6	; x3
	sub.w	d5,d6		; x3-x1
	muls.w	d6,d4		; (y2-y1)*(x3-x1)
	sub.l	d4,d3		; (x2-x1)*(y3-y1)-(y2-y1)*(x3-x1)
	bgt.s	.show		; >0 visible
	move.w	(a1),d0
	addq.w	#2,d0
	add.w	d0,d0
	addi.w	#14,d0
	adda.w	d0,a1
	dbf	d7,.loopvect
	rts
.show
	move.w	(a1)+,d6	; num points
	movem.l	(a1)+,a3-a4	; palette-coppercol
	moveq	#10,d4
	lsr.w	d4,d3		; normal/10
	add.w	d3,d3
	move.w	(a3,d3.w),(a4)	; change color
	move.l	(a1)+,ptPlan(a5)	; plan #
	cmpi.l	#-1,ptPlan(a5)
	bne.s	.draw
	bra.s	.plan1n2
.draw
	move.w	(a1)+,d4	; p1
	move.w	(a1),d5		; p2
	movem.w	(a2,d4.w),d0-d1	; x1,y1
	movem.w	(a2,d5.w),d2-d3	; x2,y2
	bsr	DrawLine
	dbf	d6,.draw
	addq.w	#2,a1
	dbf	d7,.loopvect
	rts
.plan1n2
	clr.l	ptPlan(a5)		; plan 1
	move.w	(a1)+,d4
	move.w	(a1),d5
	movem.w	(a2,d4.w),d0-d1
	movem.w	(a2,d5.w),d2-d3
	movem.w	d0-d3,-(sp)
	bsr	DrawLine
	movem.w	(sp)+,d0-d3
	move.l	#44*283,ptPlan(a5)	; plan 2
	bsr	DrawLine
	dbf	d6,.plan1n2
	addq.l	#2,a1
	dbf	d7,.loopvect
	rts
* -
DrawLine:
	cmp.w	d1,d3
	bgt.s	.y2Gy1
	exg	d0,d2
	exg	d1,d3
	beq.s	.exit
.y2Gy1	moveq	#0,d4
	move.w	d1,d4
	mulu.w	#44,d4
	move.w	d0,d5
	add.l	a0,d4
	add.l	ptPlan(a5),d4	; draw to plan x
	asr.w	#3,d5
	add.w	d5,d4
	moveq	#0,d5
	sub.w	d1,d3
	sub.w	d0,d2
	bpl.s	.x2Gx1
	moveq	#1,d5
	neg.w	d2
.x2Gx1	move.w	d3,d1
	add.w	d1,d1
	cmp.w	d2,d1
	dbhi	d3,*+4
	move.w	d3,d1
	sub.w	d2,d1
	bpl.s	.dyGdx
	exg	d2,d3
.dyGdx	addx.w	d5,d5
	add.w	d2,d2
	move.w	d2,d1
	sub.w	d3,d2
	addx.w	d5,d5
	andi.w	#$F,d0
	ror.w	#4,d0
	ori.w	#$A4A,d0

	bsr	waitblitter
	move.w	d2,BltAptl(a6)
	sub.w	d3,d2
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d0,BltCon0(a6)
	move.b	octants(pc,d5.w),BltCon1+1(a6)
	move.l	d4,BltCpth(a6)
	move.l	d4,BltDpth(a6)
	movem.w	d1-d2,BltBmod(a6)
	move.w	d3,BltSize(a6)
.exit	rts

octants	dc.b	3,$43,$13,$53,$B,$4B,$17,$57
* ---------------------------------------------------------
* - Dots Sphere - precalculated :((
* ---------------------------------------------------------
ClearDotsPlan:
	movea.l	ptBpVector1(a5),a1
	adda.l	#44*283*2+44*38+9,a1

	bsr	waitblitter
	move.l	#$1000000,BltCon0(a6)
	move.l	#-1,BltAfwm(a6)
	move.w	#44-28,BltDmod(a6)
	move.l	a1,BltDpth(a6)
	move.w	#207*64+28/2,BltSize(a6)
	rts
* --
DotsSphere:
	lea	TabNumPts(pc),a0
	movea.l	ptBpVector1(a5),a1
	adda.l	#44*283*2,a1	; in plan 3
	move.w	ptTabNumPts(a5),d0
	move.w	(a0,d0.w),d7
	tst.w	d7
	bne.s	.notyet
	clr.w	ptTabNumPts(a5)
	move.l	#Yoffset,ptYoffset(a5)
	move.l	#Xoffset,ptXoffset(a5)
	bra.s	DotsSphere
.notyet
	subq.w	#1,d7
	movea.l	ptYoffset(a5),a0
	movea.l	ptXoffset(a5),a2
.loop	move.w	(a0)+,d0
	move.b	(a2)+,d1
	bset	d1,(a1,d0.w)
	dbf	d7,.loop
	addq.w	#2,ptTabNumPts(a5)
	move.l	a0,ptYoffset(a5)
	move.l	a2,ptXoffset(a5)
	rts
* ---------------------------------------------------------
	ifd	PT
	 include	"ptreplay.s"
	endc
* ---------------------------------------------------------
Vars	ds.b	VARSIZE2
	even
SaveStack dc.l	0
adScreen dc.l	0
Empty	ds.l	14
* --- 
Logo	dc.l $F39E39E,$39E7E398
	dc.l $8C10C3,$C1030C0
	dc.l $F7DE7DB,$6DE6B7D8
	dc.l $C6DB6DB,$6DB6B6D8
	dc.l $C6DB6DB,$39B6B6DF
	dc.l $FFF
* --- vector
TabCoords
	ds.w	8*2
Coords	dc.w	99,99,99
	dc.w	-99,99,99
	dc.w	-99,-99,99
	dc.w	99,-99,99
	dc.w	99,99,-99
	dc.w	-99,99,-99
	dc.w	-99,-99,-99
	dc.w	99,-99,-99
NbVect	dc.w	5
StructCube:
; face 1
	dc.w	3			; num points
	dc.l	 pal1			; lightsource palette
	dc.l	 CLcol1+2		; copper list color
	dc.l	 0			; plan 1
	dc.w	 0,1*4,2*4,3*4,0	; points
; face 2
	dc.w	3
	dc.l	pal1
	dc.l	CLcol1+2
	dc.l	0	; plan 1
	dc.w	$1C,$18,$14,$10,$1C
; face 3
	dc.w	3
	dc.l	pal2
	dc.l	CLcol2+2
	dc.l	44*283	; plan 2
	dc.w	16,0,12,$1C,16
; face 4
	dc.w	3
	dc.l	pal2
	dc.l	CLcol2+2
	dc.l	44*283	; plan 2
	dc.w	4,$14,$18,8,4
; face 5
	dc.w	3
	dc.l	pal3
	dc.l	CLcol3+2
	dc.l	-1	; plan 1+2
	dc.w	12,8,$18,$1C,12
; face 6
	dc.w	3
	dc.l	pal3
	dc.l	CLcol3+2
	dc.l	-1	; plan 1+2
	dc.w	16,$14,4,0,16
; palettes
pal1	dc.w	$24,$24,$24,$24,$24,$135,$246,$357
	dc.w	$468,$579,$68A,$79B,$8AC,$9BD,$ACE,$BDF
pal2	dc.w	$42,$42,$42,$42,$42,$153,$264,$375
	dc.w	$486,$597,$6A8,$7B9,$8CA,$9DB,$AEC,$BFD
pal3	dc.w	$402,$402,$402,$402,$402,$513,$624,$735
	dc.w	$846,$957,$A68,$B79,$C8A,$D9B,$EAC,$FBD
rotatedCoords
	ds.w	28
Z	dc.l	512
TabCos
 dc.w $0200,$01ff,$01ff,$01ff,$01fe,$01fe,$01fd,$01fc,$01fb,$01f9
 dc.w $01f8,$01f6,$01f4,$01f2,$01f0,$01ee,$01ec,$01e9,$01e6,$01e4
 dc.w $01e1,$01dd,$01da,$01d7,$01d3,$01d0,$01cc,$01c8,$01c4,$01bf
 dc.w $01bb,$01b6,$01b2,$01ad,$01a8,$01a3,$019e,$0198,$0193,$018d
 dc.w $0188,$0182,$017c,$0176,$0170,$016a,$0163,$015d,$0156,$014f
 dc.w $0149,$0142,$013b,$0134,$012c,$0125,$011e,$0116,$010f,$0107
 dc.w $0100,$00f8,$00f0,$00e8,$00e0,$00d8,$00d0,$00c8,$00bf,$00b7
 dc.w $00af,$00a6,$009e,$0095,$008d,$0084,$007b,$0073,$006a,$0061
 dc.w $0058,$0050,$0047,$003e,$0035,$002c,$0023,$001a,$0011,$0008
 dc.w $ffff,$fff7,$ffee,$ffe5,$ffdc,$ffd3,$ffca,$ffc1,$ffb8,$ffaf
 dc.w $ffa7,$ff9e,$ff95,$ff8c,$ff84,$ff7b,$ff72,$ff6a,$ff61,$ff59
 dc.w $ff50,$ff48,$ff40,$ff37,$ff2f,$ff27,$ff1f,$ff17,$ff0f,$ff07
 dc.w $feff,$fef8,$fef0,$fee9,$fee1,$feda,$fed3,$fecb,$fec4,$febd
 dc.w $feb6,$feb0,$fea9,$fea2,$fe9c,$fe95,$fe8f,$fe89,$fe83,$fe7d
 dc.w $fe77,$fe72,$fe6c,$fe67,$fe61,$fe5c,$fe57,$fe52,$fe4d,$fe49
 dc.w $fe44,$fe40,$fe3b,$fe37,$fe33,$fe2f,$fe2c,$fe28,$fe25,$fe22
 dc.w $fe1e,$fe1b,$fe19,$fe16,$fe13,$fe11,$fe0f,$fe0d,$fe0b,$fe09
 dc.w $fe07,$fe06,$fe04,$fe03,$fe02,$fe01,$fe01,$fe00,$fe00,$fe00
 dc.w $fdff,$fe00,$fe00,$fe00,$fe01,$fe01,$fe02,$fe03,$fe04,$fe06
 dc.w $fe07,$fe09,$fe0b,$fe0d,$fe0f,$fe11,$fe13,$fe16,$fe19,$fe1b
 dc.w $fe1e,$fe22,$fe25,$fe28,$fe2c,$fe2f,$fe33,$fe37,$fe3b,$fe40
 dc.w $fe44,$fe49,$fe4d,$fe52,$fe57,$fe5c,$fe61,$fe67,$fe6c,$fe72
 dc.w $fe77,$fe7d,$fe83,$fe89,$fe8f,$fe95,$fe9c,$fea2,$fea9,$feb0
 dc.w $feb6,$febd,$fec4,$fecb,$fed3,$feda,$fee1,$fee9,$fef0,$fef8
 dc.w $feff,$ff07,$ff0f,$ff17,$ff1f,$ff27,$ff2f,$ff37,$ff40,$ff48
 dc.w $ff50,$ff59,$ff61,$ff6a,$ff72,$ff7b,$ff84,$ff8c,$ff95,$ff9e
 dc.w $ffa7,$ffaf,$ffb8,$ffc1,$ffca,$ffd3,$ffdc,$ffe5,$ffee,$fff7
 dc.w $ffff,$0008,$0011,$001a,$0023,$002c,$0035,$003e,$0047,$0050
 dc.w $0058,$0061,$006a,$0073,$007b,$0084,$008d,$0095,$009e,$00a6
 dc.w $00af,$00b7,$00bf,$00c8,$00d0,$00d8,$00e0,$00e8,$00f0,$00f8
 dc.w $00ff,$0107,$010f,$0116,$011e,$0125,$012c,$0134,$013b,$0142
 dc.w $0149,$014f,$0156,$015d,$0163,$016a,$0170,$0176,$017c,$0182
 dc.w $0188,$018d,$0193,$0198,$019e,$01a3,$01a8,$01ad,$01b2,$01b6
 dc.w $01bb,$01bf,$01c4,$01c8,$01cc,$01d0,$01d3,$01d7,$01da,$01dd
 dc.w $01e1,$01e4,$01e6,$01e9,$01ec,$01ee,$01f0,$01f2,$01f4,$01f6
 dc.w $01f8,$01f9,$01fb,$01fc,$01fd,$01fe,$01fe,$01ff,$01ff,$01ff
 dc.w $0200
TabSin
 dc.w $0000,$0008,$0011,$001a,$0023,$002c,$0035,$003e,$0047,$0050
 dc.w $0058,$0061,$006a,$0073,$007b,$0084,$008d,$0095,$009e,$00a6
 dc.w $00af,$00b7,$00bf,$00c8,$00d0,$00d8,$00e0,$00e8,$00f0,$00f8
 dc.w $0100,$0107,$010f,$0116,$011e,$0125,$012c,$0134,$013b,$0142
 dc.w $0149,$014f,$0156,$015d,$0163,$016a,$0170,$0176,$017c,$0182
 dc.w $0188,$018d,$0193,$0198,$019e,$01a3,$01a8,$01ad,$01b2,$01b6
 dc.w $01bb,$01bf,$01c4,$01c8,$01cc,$01d0,$01d3,$01d7,$01da,$01dd
 dc.w $01e1,$01e4,$01e6,$01e9,$01ec,$01ee,$01f0,$01f2,$01f4,$01f6
 dc.w $01f8,$01f9,$01fb,$01fc,$01fd,$01fe,$01fe,$01ff,$01ff,$01ff
 dc.w $0200,$01ff,$01ff,$01ff,$01fe,$01fe,$01fd,$01fc,$01fb,$01f9
 dc.w $01f8,$01f6,$01f4,$01f2,$01f0,$01ee,$01ec,$01e9,$01e6,$01e4
 dc.w $01e1,$01dd,$01da,$01d7,$01d3,$01d0,$01cc,$01c8,$01c4,$01bf
 dc.w $01bb,$01b6,$01b2,$01ad,$01a8,$01a3,$019e,$0198,$0193,$018d
 dc.w $0188,$0182,$017c,$0176,$0170,$016a,$0163,$015d,$0156,$014f
 dc.w $0149,$0142,$013b,$0134,$012c,$0125,$011e,$0116,$010f,$0107
 dc.w $0100,$00f8,$00f0,$00e8,$00e0,$00d8,$00d0,$00c8,$00bf,$00b7
 dc.w $00af,$00a6,$009e,$0095,$008d,$0084,$007b,$0073,$006a,$0061
 dc.w $0058,$0050,$0047,$003e,$0035,$002c,$0023,$001a,$0011,$0008
 dc.w $0000,$fff7,$ffee,$ffe5,$ffdc,$ffd3,$ffca,$ffc1,$ffb8,$ffaf
 dc.w $ffa7,$ff9e,$ff95,$ff8c,$ff84,$ff7b,$ff72,$ff6a,$ff61,$ff59
 dc.w $ff50,$ff48,$ff40,$ff37,$ff2f,$ff27,$ff1f,$ff17,$ff0f,$ff07
 dc.w $ff00,$fef8,$fef0,$fee9,$fee1,$feda,$fed3,$fecb,$fec4,$febd
 dc.w $feb6,$feb0,$fea9,$fea2,$fe9c,$fe95,$fe8f,$fe89,$fe83,$fe7d
 dc.w $fe77,$fe72,$fe6c,$fe67,$fe61,$fe5c,$fe57,$fe52,$fe4d,$fe49
 dc.w $fe44,$fe40,$fe3b,$fe37,$fe33,$fe2f,$fe2c,$fe28,$fe25,$fe22
 dc.w $fe1e,$fe1b,$fe19,$fe16,$fe13,$fe11,$fe0f,$fe0d,$fe0b,$fe09
 dc.w $fe07,$fe06,$fe04,$fe03,$fe02,$fe01,$fe01,$fe00,$fe00,$fe00
 dc.w $fdff,$fe00,$fe00,$fe00,$fe01,$fe01,$fe02,$fe03,$fe04,$fe06
 dc.w $fe07,$fe09,$fe0b,$fe0d,$fe0f,$fe11,$fe13,$fe16,$fe19,$fe1b
 dc.w $fe1e,$fe22,$fe25,$fe28,$fe2c,$fe2f,$fe33,$fe37,$fe3b,$fe40
 dc.w $fe44,$fe49,$fe4d,$fe52,$fe57,$fe5c,$fe61,$fe67,$fe6c,$fe72
 dc.w $fe77,$fe7d,$fe83,$fe89,$fe8f,$fe95,$fe9c,$fea2,$fea9,$feb0
 dc.w $feb6,$febd,$fec4,$fecb,$fed3,$feda,$fee1,$fee9,$fef0,$fef8
 dc.w $feff,$ff07,$ff0f,$ff17,$ff1f,$ff27,$ff2f,$ff37,$ff40,$ff48
 dc.w $ff50,$ff59,$ff61,$ff6a,$ff72,$ff7b,$ff84,$ff8c,$ff95,$ff9e
 dc.w $ffa7,$ffaf,$ffb8,$ffc1,$ffca,$ffd3,$ffdc,$ffe5,$ffee,$fff7
 dc.w $ffff,$0000
* --- writer
Text:	dc.b	'\\\\\\\\\\\\D\E\L\I\G\H\T\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
	dc.b '\\\\\\\\\\\\\\\\\\\\\\\IS\PROUD\TO\PRESENT\\\\\\\\\\\\\\\\'
	dc.b '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\GENESIA\\PRE\ENGLISH\VERSI'
	dc.b 'ON\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\CRACKED\'
	dc.b 'TO\PERFECTION\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
	dc.b '\\\\\\\NOT\AS\YOUR\VERSION\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
	dc.b '\\\\\\\\\\\\\\\\\\\\\\\\\\CREDITS\\\\\\\\\\\\\\\\\\\\\\\\\'
	dc.b '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
	dc.b '\\\\CRACKED\\\\\\\\\\\\\\BABYDOCK\OF\PDXCODING\\\\\\\\\\\\'
	dc.b '\\\\\\\\PARANORMALGRAPHICS\\\\\\\\\\\\\\\\\\\\\\QUARTZMUSI'
	dc.b 'C\\\\\\\\\\\\\\\\\\\\\DOH\OF\CRB\\\\\\\\\\\\\\\\\\\\\\\\\\'
	dc.b '\\\\\\\\\\\\\\\\\\\\\\\PLEASE\GIVE\\\\\\\\\\\\\\\\\\\\\\A\'
	dc.b 'CALL\TO\OUR\BBS\\\\\\\\\'
	dc.b	-1  
	even
font	incbin	"font.rw"
	even
* --- dots sphere
TabNumPts:
 dc.w $00bd,$00ba,$00b2,$00ba,$00bd,$00be,$00bf,$00c6,$00cd,$00d0
 dc.w $00d4,$00e3,$00ed,$00f9,$00f9,$00fe,$0103,$010c,$010b,$0111
 dc.w $0116,$0114,$0113,$0117,$011d,$011d,$011a,$011d,$0123,$0122
 dc.w $0121,$0122,$0127,$0127,$0124,$0123,$012a,$0129,$0125,$011f
 dc.w $0127,$012a,$012b,$0123,$0126,$0127,$0127,$0121,$0124,$0125
 dc.w $0123,$0120,$0120,$011f,$011f,$011b,$011b,$0118,$0116,$0116
 dc.w $0111,$010f,$010b,$010b,$0104,$0103,$00fd,$00fb,$00ee,$00e5
 dc.w $00d2,$00ce,$00ce,$00c6,$00c0,$00be,$00bd,$00bb,$00b3,$00b9
 dc.w $00bd,$00b9,$00b3,$00bb,$00bd,$00be,$00c0,$00c6,$00ce,$00ce
 dc.w $00d2,$00e4,$00ed,$00fa,$00fc,$0102,$0103,$010a,$010a,$010e
 dc.w $0110,$0115,$0115,$0117,$011a,$011a,$011e,$011e,$011f,$011f
 dc.w $0122,$0124,$0123,$0120,$0126,$0126,$0125,$0122,$012a,$0129
 dc.w $0126,$011e,$0124,$0128,$0129,$0122,$0123,$0126,$0126,$0121
 dc.w $0120,$0121,$0122,$011c,$0119,$011c,$011c,$0116,$0112,$0113
 dc.w $0115,$0110,$010a,$010b,$0102,$00fd,$00f8,$00f8,$00ec,$00e2
 dc.w $00d4,$00d0,$00cd,$00c6,$00be,$00be,$00bd,$00ba,$00b2,$00ba
 dc.w $0000
Yoffset	incbin	"DotsYoff"
Xoffset	incbin	"DotsXoff"
	even
* ---------------------------------------------------------- COPPERLISTS
	section	copper,data_c	
Newcopper:
	dc.w	$106,$c00,$1fc,0,$10c,$11
	dc.w	$8e,$1c71,$90,$37d1
	dc.w	$92,$30,$94,$d4
	dc.w	$108,0,$10a,0
	dc.w	$102,0,$104,$24
* -- main screen
CLvect	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$ec,0,$ee,0
CLtext	dc.w	$e8,0,$ea,0
	dc.w	$180,0,$188,0
	dc.w	$100,$4200
	dc.w	$9c,$8010	; interruption copper

	dc.w	$3001,$fffe,$180,$fff,$188,$fff
	dc.w	$3101,$fffe,$180,$345,$188,$345
	dc.w	$3201,$fffe,$180,$345
CLcol1	dc.w	$182,$33f
CLcol2	dc.w	$184,$22a
CLcol3	dc.w	$186,$116
	dc.w	$188,$fff,$18a,$fff,$18c,$fff,$18e,$fff
	dc.w	$190,$fff,$192,$fff,$194,$fff,$196,$fff
	dc.w	$198,$fff,$19a,$fff,$19c,$fff,$19e,$fff

	dc.w	$ffdf,$fffe
	dc.w	$2101,$fffe,$182,$eee
	dc.w	$2801,$fffe,$180,$fff,$188,$fff
	dc.w	$2901,$fffe,$180,0,$188,0

	dc.l	-2
	dc.l	-2
* -----------------------------------------------------
Module:
mt_data:
	ifd	PT
	incbin	"synth.mod"
	endc


;	section	bss,bss_c	;-> allocmem
;BpVector1 ds.b	44*283*3
;BpVector2 ds.b	44*283*3
;BpText	ds.b	44*283
	END
