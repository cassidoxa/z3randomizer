;================================================================================
; Utility Functions
;================================================================================
; GetSpriteTile
; in:	A - Loot ID
; out:	A - Sprite GFX ID
;--------------------------------------------------------------------------------
GetSpriteID:
	JSR AttemptItemSubstitution
	CMP.b #$16 : BEQ .bottle ; Bottle
	CMP.b #$2B : BEQ .bottle ; Red Potion w/bottle
	CMP.b #$2C : BEQ .bottle ; Green Potion w/bottle
	CMP.b #$2D : BEQ .bottle ; Blue Potion w/bottle
	CMP.b #$3C : BEQ .bottle ; Bee w/bottle
	CMP.b #$3D : BEQ .bottle ; Fairy w/bottle
	CMP.b #$48 : BEQ .bottle ; Gold Bee w/bottle
	CMP.b #$6D : BEQ .server_F0 ; Server Request F0
	CMP.b #$6E : BEQ .server_F1 ; Server Request F1
	CMP.b #$6F : BEQ .server_F2 ; Server Request F2
	BRA .normal
		.bottle
			PHA : JSR.w CountBottles : CMP.l BottleLimit : !BLT +
				PLA : LDA.l BottleLimitReplacement
				JMP GetSpriteID
			+
			PLA : BRA .normal
		.server_F0
			JSL.l ItemVisualServiceRequest_F0
			BRA .normal
		.server_F1
			JSL.l ItemVisualServiceRequest_F1
			BRA .normal
		.server_F2
			JSL.l ItemVisualServiceRequest_F2
	.normal
		
	PHX
	PHB : PHK : PLB
	;--------
	TAX : LDA.l .gfxSlots, X ; look up item gfx
	PLB : PLX
	CMP.b #$F8 : !BGE .specialHandling
RTL
	.specialHandling
	CMP.b #$F9 : BNE ++ ; Progressive Magic
		LDA.l MagicConsumption : BNE +++
			LDA.b #$3B : RTL ; Half Magic
		+++
			LDA.b #$3C : RTL ; Quarter Magic
	++ CMP.b #$FA : BNE ++ ; RNG Item (Single)
		JSL.l GetRNGItemSingle : JMP GetSpriteID
	++ CMP.b #$FB : BNE ++ ; RNG Item (Multi)
		JSL.l GetRNGItemMulti : JMP GetSpriteID
	++ CMP.b #$FD : BNE ++ ; Progressive Armor
		LDA.l ArmorEquipment : CMP.l ProgressiveArmorLimit : !BLT + ; Progressive Armor Limit
			LDA.l ProgressiveArmorReplacement
			JMP GetSpriteID
		+
		LDA.b #$04 : RTL
	++ CMP.b #$FE : BNE ++ ; Progressive Sword
		LDA.l HighestSword
		CMP.l ProgressiveSwordLimit : !BLT + ; Progressive Sword Limit
			LDA.l ProgressiveSwordReplacement
			JMP GetSpriteID
		+ : CMP.b #$00 : BNE + ; No Sword
			LDA.b #$43 : RTL
		+ : CMP.b #$01 : BNE + ; Fighter Sword
			LDA.b #$44 : RTL
		+ : CMP.b #$02 : BNE + ; Master Sword
			LDA.b #$45 : RTL
		+ ; CMP.b #$03 : BNE + ; Tempered Sword
			LDA.b #$46 : RTL
		+
	++ : CMP.b #$FF : BNE ++ ; Progressive Shield
		LDA.l HighestShield
		CMP.l ProgressiveShieldLimit : !BLT + ; Progressive Shield Limit
			LDA.l ProgressiveShieldReplacement
			JMP GetSpriteID
		+ : CMP.b #$00 : BNE + ; No Shield
			LDA.b #$2D : RTL
		+ : CMP.b #$01 : BNE + ; Fighter Shield
			LDA.b #$20 : RTL
		+ ; Everything Else
			LDA.b #$2E : RTL
	++ : CMP.b #$F8 : BNE ++ ; Progressive Bow
		LDA.l BowEquipment : INC : LSR
		CMP.l ProgressiveBowLimit : !BLT +
			LDA.l ProgressiveBowReplacement
			JMP GetSpriteID
		+ : CMP.b #$00 : BNE + ; No Bow
			LDA.b #$29 : RTL
		+ ; Any Bow
			LDA.b #$2A : RTL
	++
RTL

;DATA - Loot Identifier to Sprite ID
{
	.gfxSlots
    db $06, $44, $45, $46, $2D, $20, $2E, $09
    db $09, $0A, $08, $05, $10, $0B, $2C, $1B

    db $1A, $1C, $14, $19, $0C, $07, $1D, $2F
    db $07, $15, $12, $0D, $0D, $0E, $11, $17

    db $28, $27, $04, $04, $0F, $16, $03, $13
    db $01, $1E, $10, $00, $00, $00, $00, $00

    db $00, $30, $22, $21, $24, $24, $24, $23
    db $23, $23, $29, $2A, $2C, $2B, $03, $03

    db $34, $35, $31, $33, $02, $32, $36, $37
	db $2C, $43, $0C, $38, $39, $3A, $F9, $3C
	; db $2C, $06, $0C, $38, $FF, $FF, $FF, $FF

	;5x
	db $44 ; Safe Master Sword
	db $3D, $3E, $3F, $40 ; Bomb & Arrow +5/+10
	db $2C, $00, $00 ; 3x Programmable Item
	db $41 ; Upgrade-Only Silver Arrows
	db $24 ; 1 Rupoor
	db $47 ; Null Item
	db $48, $48, $48 ; Red, Blue & Green Clocks
	db $FE, $FF ; Progressive Sword & Shield

	;6x
	db $FD, $0D ; Progressive Armor & Gloves
	db $FA, $FB ; RNG Single & Multi
	db $F8, $F8 ; Progressive Bow x2
	db $FF, $FF, $FF, $FF ; Unused
	db $49, $4A, $49 ; Goal Item Single, Multi & Alt Multi
	db $39, $39, $39 ; Server Request F0, F1, F2

	;7x
	db $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21 ; Free Map

	;8x
	db $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16 ; Free Compass

	;9x
	db $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22 ; Free Big Key

	;Ax
	db $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F ; Free Small Key

	db $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49 ; Unused
	db $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49 ; Unused
	db $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49 ; Unused
	db $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49 ; Unused
	db $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49 ; Reserved
}
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; GetSpritePalette
; in:	A - Loot ID
; out:	A - Palette
;--------------------------------------------------------------------------------
GetSpritePalette:
	JSR AttemptItemSubstitution
	CMP.b #$16 : BEQ .bottle ; Bottle
	CMP.b #$2B : BEQ .bottle ; Red Potion w/bottle
	CMP.b #$2C : BEQ .bottle ; Green Potion w/bottle
	CMP.b #$2D : BEQ .bottle ; Blue Potion w/bottle
	CMP.b #$3C : BEQ .bottle ; Bee w/bottle
	CMP.b #$3D : BEQ .bottle ; Fairy w/bottle
	CMP.b #$48 : BEQ .bottle ; Gold Bee w/bottle
		BRA .notBottle
		.bottle
			PHA : JSR.w CountBottles : CMP.l BottleLimit : !BLT +
				PLA : LDA.l BottleLimitReplacement
				JMP GetSpritePalette
			+
		PLA : .notBottle
	PHX
	PHB : PHK : PLB
	;--------
	TAX : LDA.l GfxPalettes, X ; look up item gfx
	PLB : PLX
	CMP.b #$F8 : !BGE .specialHandling
RTL
	.specialHandling
	CMP.b #$FD : BNE ++ ; Progressive Sword
		LDA.l HighestSword
		CMP.l ProgressiveSwordLimit : !BLT + ; Progressive Sword Limit
			LDA.l ProgressiveSwordReplacement
			JMP GetSpritePalette
		+ : CMP.b #$00 : BNE + ; No Sword
			LDA.b #$04 : RTL
		+ : CMP.b #$01 : BNE + ; Fighter Sword
			LDA.b #$04 : RTL
		+ : CMP.b #$02 : BNE + ; Master Sword
			LDA.b #$02 : RTL
		+ ; Everything Else
			LDA.b #$08 : RTL
	++ : CMP.b #$FE : BNE ++ ; Progressive Shield
		LDA.l HighestShield
		CMP.l ProgressiveShieldLimit : !BLT + ; Progressive Shield Limit
			LDA.l ProgressiveShieldReplacement
			JMP GetSpritePalette
		+ : CMP.b #$00 : BNE + ; No Shield
			LDA.b #$04 : RTL
		+ : CMP.b #$01 : BNE + ; Fighter Shield
			LDA.b #$02 : RTL
		+ ; Everything Else
			LDA.b #$08 : RTL
	++ : CMP.b #$FF : BNE ++ ; Progressive Armor
		LDA.l HighestMail
                CMP.l ProgressiveArmorLimit : !BLT + ; Progressive Armor Limit
			LDA.l ProgressiveArmorReplacement
			JMP GetSpritePalette
		+ : CMP.b #$00 : BNE + ; Green Tunic
			LDA.b #$04 : RTL
		+ ; Everything Else
			LDA.b #$02 : RTL
	++ : CMP.b #$FC : BNE ++ ; Progressive Gloves
		LDA.l GloveEquipment : BNE + ; No Gloves
			LDA.b #$02 : RTL
		+ ; Everything Else
			LDA.b #$08 : RTL
	++ : CMP.b #$F8 : BNE ++ ; Progressive Bow
		LDA.l BowEquipment : INC : LSR
		CMP.l ProgressiveBowLimit : !BLT +
			LDA.l ProgressiveBowReplacement
			JMP GetSpritePalette
		+ : CMP.b #$00 : BNE + ; No Bow
			LDA.b #$08 : RTL
		+ ; Any Bow
			LDA.b #$02 : RTL
	++ : CMP.b #$FA : BNE ++ ; RNG Item (Single)
		JSL.l GetRNGItemSingle : JMP GetSpritePalette
	++ : CMP.b #$FB : BNE ++ ; RNG Item (Multi)
		JSL.l GetRNGItemMulti : JMP GetSpritePalette
	++
RTL

;DATA - Loot Identifier to Sprite Palette
{
GfxPalettes:
	db $00, $04, $02, $08, $04, $02, $08, $02
	db $04, $02, $02, $02, $04, $04, $04, $08

	db $08, $08, $02, $02, $04, $02, $02, $02
	db $04, $02, $04, $02, $08, $08, $04, $02

	db $0A, $02, $04, $02, $04, $04, $00, $04
	db $04, $08, $02, $02, $08, $04, $02, $08

	db $04, $04, $08, $08, $08, $04, $02, $08
	db $02, $04, $08, $02, $04, $04, $02, $02

	db $08, $08, $02, $04, $04, $08, $08, $08
	db $04, $04, $04, $02, $08, $08, $08, $08
	; db $04, $0A, $04, $02, $FF, $FF, $FF, $FF

	db $04 ; Safe Master Sword
	db $08, $08, $08, $08 ; Bomb & Arrow +5/+10
	db $04, $00, $00 ; Programmable Items 1-3
	db $02 ; Upgrade-Only Silver Arrows
	db $06 ; 1 Rupoor
	db $02 ; Null Item
	db $02, $04, $08 ; Red, Blue & Green Clocks
	db $FD, $FE, $FF, $FC ; Progressive Sword, Shield, Armor & Gloves
	db $FA, $FB ; RNG Single & Multi
	db $F8, $F8 ; Progressive Bow
	db $00, $00, $00, $00 ; Unused
	db $08, $08, $08 ; Goal Item Single, Multi & Alt Multi
	db $04, $04, $04 ; Server Request F0, F1, F2
	
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08 ; Free Map
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04 ; Free Compass
	;db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08 ; *EVENT*
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08 ; Free Big Key
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08 ; Free Small Key
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08 ; Unused
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08 ; Unused
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08 ; Unused
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08 ; Unused
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08 ; Unused
}
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; IsNarrowSprite
; in:	A - Loot ID
; out:	Carry - 0 = Full, 1 = Narrow
;--------------------------------------------------------------------------------
IsNarrowSprite:
	PHA : PHX
	PHB : PHK : PLB
	JSR AttemptItemSubstitution
	;--------
	CMP.b #$16 : BEQ .bottle ; Bottle
	CMP.b #$2B : BEQ .bottle ; Red Potion w/bottle
	CMP.b #$2C : BEQ .bottle ; Green Potion w/bottle
	CMP.b #$2D : BEQ .bottle ; Blue Potion w/bottle
	CMP.b #$3C : BEQ .bottle ; Bee w/bottle
	CMP.b #$3D : BEQ .bottle ; Fairy w/bottle
	CMP.b #$48 : BEQ .bottle ; Gold Bee w/bottle
		BRA .notBottle
		.bottle
			JSR.w CountBottles : CMP.l BottleLimit : !BLT +
				LDA.l BottleLimitReplacement
				JSL.l IsNarrowSprite
				JMP .done
			+ : JMP .continue
		.notBottle
	CMP.b #$5E : BNE ++ ; Progressive Sword
		LDA.l HighestSword : CMP.l ProgressiveSwordLimit : !BLT + ; Progressive Sword Limit
			LDA.l ProgressiveSwordReplacement
			JSL.l IsNarrowSprite
			JMP .done
		+ : JMP .continue
	++ CMP.b #$5F : BNE ++ ; Progressive Shield
		LDA.l HighestShield : BNE + : JMP .done ; No Shield
		+ : CMP.l ProgressiveShieldLimit : !BLT .continue
			LDA.l ProgressiveShieldReplacement
			JSL.l IsNarrowSprite
			JMP .done
	++ CMP.b #$60 : BNE ++ ; Progressive Armor
		LDA.l HighestMail : CMP.l ProgressiveArmorLimit : !BLT .continue
			LDA.l ProgressiveArmorReplacement
			JSL.l IsNarrowSprite
			JMP .done
		+
	++ CMP.b #$62 : BNE ++ ; RNG Item (Single)
		JSL.l GetRNGItemSingle : JMP .continue
	++ CMP.b #$63 : BNE ++ ; RNG Item (Multi)
		JSL.l GetRNGItemMulti
	++ CMP.b #$64 : BEQ +               ; Progressive Bow
           CMP.b #$65 : BNE .continue       ; Progressive Bow (alt)
                + : LDA.l BowEquipment : INC : LSR
                CMP.l ProgressiveBowLimit : !BLT +
			LDA.l ProgressiveBowReplacement
			JSL.l IsNarrowSprite
                        JMP .done
	.continue
	;--------

	LDX.b #$00 ; set index counter to 0
	;----
	-
	CPX.b #$24 : !BGE .false ; finish if we've done the whole list
	CMP.l .smallSprites, X : BNE + ; skip to next if we don't match
	;--
	SEC ; set true state
	BRA .done ; we're done
	;--
	+
	INX ; increment index
	BRA - ; go back to beginning of loop
	;----
	.false
	CLC
	.done
	PLB : PLX : PLA
RTL

;DATA - Half-Size Sprite Markers
{
	.smallSprites
	db $04, $07, $08, $09, $0A, $0B, $0C, $13
	db $15, $18, $24, $2A, $34, $35, $36, $42
	db $43, $45, $59, $A0, $A1, $A2, $A3, $A4
	db $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC
	db $AD, $AE, $AF, $FF, $FF, $FF, $FF, $FF
}
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; PrepDynamicTile
; in:	A - Loot ID
;-------------------------------------------------------------------------------- 20/8477
PrepDynamicTile:
	PHA : PHX : PHY
	JSR.w LoadDynamicTileOAMTable
	JSL.l GetSpriteID ; convert loot id to sprite id
	JSL.l GetAnimatedSpriteTile_variable
	PLY : PLX : PLA
RTL
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; LoadDynamicTileOAMTable
; in:	A - Loot ID
;-------------------------------------------------------------------------------- 20/847B
LoadDynamicTileOAMTable:
	PHA : PHP

	PHA
		REP #$20 ; set 16-bit accumulator
		LDA.w #$0000 : STA.l SpriteOAM
		               STA.l SpriteOAM+2
		LDA.w #$0200 : STA.l SpriteOAM+6
		SEP #$20 ; set 8-bit accumulator
		LDA.b #$24 : STA.l SpriteOAM+4

	LDA.b $01,s

		JSL.l GetSpritePalette
		STA.l SpriteOAM+5 : STA.l SpriteOAM+13
	PLA
	JSL.l IsNarrowSprite : BCS .narrow

	BRA .done

	.narrow
	REP #$20 ; set 16-bit accumulator
	LDA.w #$0000 : STA.l SpriteOAM+7
	               STA.l SpriteOAM+14
	LDA.w #$0800 : STA.l SpriteOAM+9
	LDA.w #$3400 : STA.l SpriteOAM+11

	.done
	PLP : PLA
RTS
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; DrawDynamicTile
; in:	A - Loot ID
; out:  A - OAM Slots Taken
;--------------------------------------------------------------------------------
; This wastes two OAM slots if you don't want a shadow - fix later - I wrote "fix later" over a year ago and it's still not fixed (Aug 6, 2017) - lol (May 25th, 2019)
;-------------------------------------------------------------------------------- 2084B8
DrawDynamicTile:
	JSL.l IsNarrowSprite : BCS .narrow

	.full
	LDA.b #$01 : STA.b Scrap06
	LDA.b #$0C : JSL.l OAM_AllocateFromRegionC
	LDA.b #$02 : PHA
	BRA .draw

	.narrow
	LDA.b #$02 : STA.b Scrap06
	LDA.b #$10 : JSL.l OAM_AllocateFromRegionC
	LDA.b #$03 : PHA

	.draw
	LDA.b #SpriteOAM>>0 : STA.b Scrap08
	LDA.b #SpriteOAM>>8 : STA.b Scrap09
	STZ.b Scrap07
	LDA.b #$7E : PHB : PHA : PLB
		LDA.b #$01 : STA.l SpriteSkipEOR
		JSL Sprite_DrawMultiple_quantity_preset
		LDA.b #$00 : STA.l SpriteSkipEOR
	PLB

	LDA.b $90 : !ADD.b #$08 : STA.b $90 ; leave the pointer in the right spot to draw the shadow, if desired
	LDA.b $92 : INC #2 : STA.b $92
	PLA
RTL
;--------------------------------------------------------------------------------
DrawDynamicTileNoShadow:
	JSL.l IsNarrowSprite : BCS .narrow

	.full
	LDA.b #$01 : STA.b Scrap06
	LDA.b #$04 : JSL.l OAM_AllocateFromRegionC
	BRA .draw

	.narrow
	LDA.b #$02 : STA.b Scrap06
	LDA.b #$08 : JSL.l OAM_AllocateFromRegionC

	.draw
	LDA.b #SpriteOAM>>0 : STA.b Scrap06
	LDA.b #SpriteOAM>>8 : STA.b Scrap06
	STZ.b Scrap07
	LDA.b #$7E : PHB : PHA : PLB
		LDA.b #$01 : STA.l SpriteSkipEOR
		JSL Sprite_DrawMultiple_quantity_preset
		LDA.l Bob : BNE + : LDA.b #$00 : STA.l SpriteSkipEOR : + ; Bob fix is conditional
	PLB

	LDA.b $90 : !ADD.b #$08 : STA.b $90
	LDA.b $92 : INC #2 : STA.b $92
RTL
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
LoadModifiedTileBufferAddress:
	PHA
	LDA.l TileUploadOffsetOverride : BEQ +
		TAX
    	LDY.w #$0002
		LDA.w #$0000 : STA.l TileUploadOffsetOverride
		BRA .done
	+
    LDX.w #$2D40
    LDY.w #$0002
	.done
	PLA
RTL
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Sprite_IsOnscreen
; in:	X - Sprite Slot
; out:	Carry - 1 = On Screen, 0 = Off Screen
;--------------------------------------------------------------------------------
Sprite_IsOnscreen:
    JSR _Sprite_IsOnscreen_DoWork
	BCS +
		REP #$20
		LDA.b BG2H : PHA : !SUB.w #$0F : STA.b BG2H
		LDA.b BG2V : PHA : !SUB.w #$0F : STA.b BG2V
		SEP #$20
			JSR _Sprite_IsOnscreen_DoWork
		REP #$20
		PLA : STA.b BG2V
		PLA : STA.b BG2H
		SEP #$20
	+
RTL

_Sprite_IsOnscreen_DoWork:
    LDA.w SpritePosXLow, X : CMP.b BG2H
    LDA.w SpritePosXHigh, X : SBC.b $E3 : BNE .offscreen

    LDA.w SpritePosYLow, X : CMP.b BG2V
    LDA.w SpritePosYHigh, X : SBC.b $E9 : BNE .offscreen
	SEC
RTS
	.offscreen
	CLC
RTS
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Sprite_GetScreenRelativeCoords:
; out:	$00.w Sprite Y
; out:	$02.w Sprite X
; out:	$06.b Sprite Y Relative
; out:	$07.b Sprite X Relative
;--------------------------------------------------------------------------------
; Copied from bank $06
;--------------------------------------------------------------------------------
Sprite_GetScreenRelativeCoords:
	STY.b Scrap0B

	STA.b Scrap08

	LDA.w SpritePosYLow, X : STA.b Scrap00
	!SUB.b BG2V       : STA.b Scrap06
	LDA.w SpritePosYHigh, X : STA.b Scrap01

	LDA.w SpritePosXLow, X : STA.b Scrap02 
	!SUB.b BG2H       : STA.b Scrap07
	LDA.w SpritePosXHigh, X : STA.b Scrap03
RTL
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; SkipDrawEOR - Shims in Bank05.asm : 2499
;--------------------------------------------------------------------------------
SkipDrawEOR:
	LDA.l SpriteSkipEOR : BEQ .normal
	LDA.w #$0000 : STA.l SpriteSkipEOR
	LDA.w Scrap04 : AND.w #$F0FF : STA.w Scrap04
	.normal
	LDA.b ($08), Y : EOR.w Scrap04 ; thing we wrote over
RTL
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; HexToDec
; in:	A(w) - Word to Convert
; out:	HexToDecDigit1 - HexToDecDigit5 (high - low)
;--------------------------------------------------------------------------------
HexToDec:
	PHA
	PHA
		LDA.w #$9090
		STA.b Scrap04 : STA.b Scrap06 ; temporarily store our decimal values here for speed
	PLA
	-
		CMP.w #1000 : !BLT +
		INC.b Scrap04
		!SUB.w #1000 : BRA -
	+ -
		CMP.w #100 : !BLT +
		INC.b Scrap05
		!SUB.w #100 : BRA -
	+ -
		CMP.w #10 : !BLT +
		INC.b Scrap06
		!SUB.w #10 : BRA -
	+ -
		CMP.w #1 : !BLT +
		INC.b Scrap07
		!SUB.w #1 : BRA -
	+
	LDA.b Scrap04 : STA.l HexToDecDigit2 ; move to digit storage
	LDA.b Scrap06 : STA.l HexToDecDigit4
	PLA
RTL

;--------------------------------------------------------------------------------
; CountBits
; in: A(b) - Byte to count bits in
; out: A(b) - sum of bits
; caller is responsible for setting 8-bit mode and preserving X and Y
;--------------------------------------------------------------------------------
;CountBits:
;	PHX
;	TAX                      ; Save a copy of value
;	LSR #4                   ; Shift down hi nybble, Leave <3> in C
;	PHA                      ; And save <7:4> in Stack
;	TXA                      ; Recover value
;	AND.b #$07               ; Put out <2:0> in X
;	TAX                      ; And save in X
;	LDA.l NybbleBitCounts, X ; Fetch count for <2:0>
;	PLX                      ; get <7:4>
;	ADC.l NybbleBitCounts, X ; Add count for S & C
;	PLX
;RTL

; Look up table of bit counts in the values $00-$0F
NybbleBitCounts:
db #00, #01, #01, #02, #01, #02, #02, #03, #01, #02, #02, #03, #02, #03, #03, #04

;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; HexToDec
; in:	A(w) - Word to Convert
; out:	HexToDecDigit1 - HexToDecDigit5 (high - low)
;--------------------------------------------------------------------------------
;HexToDec:
;	PHA
;	PHA
;		LDA.w #$9090
;		STA.l HexToDecDigit1 : STA.l HexToDecDigit3 : STA.l HexToDecDigit4 ; clear digit storage
;	PLA
;	-
;		CMP.w #10000 : !BLT +
;		PHA : SEP #$20 : LDA.l HexToDecDigit1 : INC : STA.l HexToDecDigit1 : REP #$20 : PLA
;		!SUB.w #10000 : BRA -
;	+ -
;		CMP.w #1000 : !BLT +
;		PHA : SEP #$20 : LDA.l HexToDecDigit2 : INC : STA.l HexToDecDigit2 : REP #$20 : PLA
;		!SUB.w #1000 : BRA -
;	+ -
;		CMP.w #100 : !BLT +
;		PHA : SEP #$20 : LDA.l HexToDecDigit3 : INC : STA.l HexToDecDigit3 : REP #$20 : PLA
;		!SUB.w #100 : BRA -
;	+ -
;		CMP.w #10 : !BLT +
;		PHA : SEP #$20 : LDA.l HexToDecDigit4 : INC : STA.l HexToDecDigit4 : REP #$20 : PLA
;		!SUB.w #10 : BRA -
;	+ -
;		CMP.w #1 : !BLT +
;		PHA : SEP #$20 : LDA.l HexToDecDigit5 : INC : STA.l HexToDecDigit5 : REP #$20 : PLA
;		!SUB.w #1 : BRA -
;	+
;	PLA
;RTL
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; WriteVRAMStripe
; in:	A(w) - VRAM Destination
; in:	X(w) - Length in Tiles
; in:	Y(w) - Word to Write
;--------------------------------------------------------------------------------
WriteVRAMStripe:
	PHX
		LDX $1000 ; get pointer
		AND.w #$7F : STA.w $1002, X : INX #2 ; set destination
	PLA : ASL : AND.w #$7FFF : ORA.w #$7000 : STA.w $1002, X : INX #2 ; set length and enable RLE
	TYA : STA.w $1002, X : INX #2 ; set tile
	SEP #$20 ; set 8-bit accumulator
		LDA.b #$FF : STA.w $1002, X
		STX.w $1000
		LDA.b #01 : STA.b $14
	REP #$20 ; set 16-bit accumulator
RTL
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; WriteVRAMBlock
; in:	A(w) - VRAM Destination
; in:	X(w) - Length in Tiles
; in:	Y(w) - Address of Data to Copy
;--------------------------------------------------------------------------------
WriteVRAMBlock:
        PHX
                LDX.w $1000 ; get pointer
        AND.w #$7F : STA.w $1002, X : INX #2 ; set destination
        PLA : ASL : AND.w #$3FFF : STA.w $1002, X : INX #2 ; set length

        PHX
                TYX ; set X to source
                PHA
                        TXA : !ADD #$1002 : TAY ; set Y to dest
                PLA
                ;A is already the value we need for mvn
                MVN $7F7E ; currently we transfer from our buffers in 7F to the vram buffer in 7E

                !ADD 1, s ; add the length in A to the stack pointer on the top of the stack
        PLX : TAX ; pull and promptly ignore, copying the value we just got over it

        SEP #$20 ; set 8-bit accumulator
                LDA.b #$FF : STA.w $1002, X
                STX.w $1000
                LDA.b #01 : STA.w $14
        REP #$20 ; set 16-bit accumulator
RTL
;--------------------------------------------------------------------------------
;Byte 1   byte 2  Byte 3   byte 4
;Evvvvvvv vvvvvvv DRllllll llllllll
;
;E if set indicates that this is not a header, but instead is the terminator byte. Only the topmost bit matters in that case.
;The v's form a vram address.
;if D is set, the dma will increment the vram address by a row per word, instead of incrementing by a column (1).
;R if set enables a run length encoding feature
;the l's are the number of bytes to upload minus 1 (don't forget this -1, it is important)
;
;This is then followed by the bytes to upload, in normal format.

;RLE feature:
;This feature makes it easy to draw the same tile repeatedly. If this bit is set, the length bits should be set to 2 times the number of copies of the tile to upload. (Without subtracting 1!)
;It is followed by a single tile (word).  Combining this this with the D bit makes it easy to draw large horizontal or vertical runs of a tile without using much space. Geat for erasing or drawing horizontal or verical box edges.
;================================================================================
