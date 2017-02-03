package com.viacom.brbpl.constants
{
	public class CharacterMapping
	{
		/*
		0010 0000	32	20	(SP)	0011 0000	48	30	0
		0010 0001	33	21	!		0011 0001	49	31	1
		0010 0010	34	22	"		0011 0010	50	32	2
		0010 0011	35	23	#		0011 0011	51	33	3
		0010 0100	36	24	$		0011 0100	52	34	4
		0010 0101	37	25	%		0011 0101	53	35	5
		0010 0110	38	26	&		0011 0110	54	36	6
		0010 0111	39	27	’		0011 0111	55	37	7
		0010 1000	40	28	(		0011 1000	56	38	8
		0010 1001	41	29	)		0011 1001	57	39	9
		0010 1010	42	2A	á		0011 1010	58	3A	:
		0010 1011	43	2B	+		0011 1011	59	3B	;
		0010 1100	44	2C	,		0011 1100	60	3C	<
		0010 1101	45	2D	-		0011 1101	61	3D	=
		0010 1110	46	2E	.		0011 1110	62	3E	>
		0010 1111	47	2F	/		0011 1111	63	3F	?
		
		Binary	Decimal	Hex	Glyph    
		0100 0000	64	40	@		0101 0000	80	50	P
		0100 0001	65	41	A		0101 0001	81	51	Q
		0100 0010	66	42	B		0101 0010	82	52	R
		0100 0011	67	43	C		0101 0011	83	53	S
		0100 0100	68	44	D		0101 0100	84	54	T
		0100 0101	69	45	E		0101 0101	85	55	U
		0100 0110	70	46	F		0101 0110	86	56	V
		0100 0111	71	47	G		0101 0111	87	57	W
		0100 1000	72	48	H		0101 1000	88	58	X
		0100 1001	73	49	I		0101 1001	89	59	Y
		0100 1010	74	4A	J		0101 1010	90	5A	Z
		0100 1011	75	4B	K		0101 1011	91	5B	[
		0100 1100	76	4C	L		0101 1100	92	5C	é
		0100 1101	77	4D	M		0101 1101	93	5D	]
		0100 1110	78	4E	N		0101 1110	94	5E	í
		0100 1111	79	4F	O		0101 1111	95	5F	ó
	
		Binary	Decimal	Hex	Glyph
		0110 0000	96	60	ú		0111 0000	112	70	p
		0110 0001	97	61	a		0111 0001	113	71	q
		0110 0010	98	62	b		0111 0010	114	72	r
		0110 0011	99	63	c		0111 0011	115	73	s
		0110 0100	100	64	d		0111 0100	116	74	t
		0110 0101	101	65	e		0111 0101	117	75	u
		0110 0110	102	66	f		0111 0110	118	76	v
		0110 0111	103	67	g		0111 0111	119	77	w
		0110 1000	104	68	h		0111 1000	120	78	x
		0110 1001	105	69	i		0111 1001	121	79	y
		0110 1010	106	6A	j		0111 1010	122	7A	z
		0110 1011	107	6B	k		0111 1011	123	7B	ç
		0110 1100	108	6C	l		0111 1100	124	7C	÷
		0110 1101	109	6D	m		0111 1101	125	7D	Ñ
		0110 1110	110	6E	n		0111 1110	126	7E	ñ
		0110 1111	111	6F	o		0111 1111	127	7F	SB
		
		Special Characters
		Binary	Decimal	Hex	Glyph
		0011 0000	48	30	®
		0011 0001	49	31	°
		0011 0010	50	32	½
		0011 0011	51	33	¿
		0011 0100	52	34	™
		0011 0101	53	35	¢
		0011 0110	54	36	£
		0011 0111	55	37	♪
		0011 1000	56	38	à
		0011 1001	57	39	TS
		0011 1010	58	3A	è
		0011 1011	59	3B	â
		0011 1100	60	3C	ê
		0011 1101	61	3D	î
		0011 1110	62	3E	ô
		0011 1111	63	3F	û
		
		*/
		//SB represents a solid block.
		private static var nonUnicodeMapping:Object = { "32":" ", "42":"á","92":"é","94":"í", "95":"ó", "96": "ú", "123":"ç", "124":"÷", "125":"Ñ", "126":"ñ", "127":"█"}
		private static var specialCharacter:Object = {"48":"®","49":"°","50":"½", "51":"¿", "52": "™", 
														"53":"¢", "54":"£", "55":"♪", "56":"à", "57":"&nbsp;", //&#160; &nbsp; non breaking space
														"58":"è", "59":"â", "60":"ê", "61":"î", "62":"ô",
														"63":"û"}
		/*  Extended Port/German/Dutch
			0010 0000	32	20	Ã  	0011 0000	48	30	Ä
			0010 0001	33	21	ã  	0010 0001	49	31	ä
			0010 0010	34	22	Í	0011 0010	50	32	Ö
			0010 0011	35	23	Ì	0011 0011	51	33	ö
			0010 0100	36	24	ì 	0011 0100	52	34	ß
			0010 0101	37	25	Ò	0011 0101	53	35	¥
			0010 0110	38	26	ò	0011 0110	54	36	¤
			0010 0111	39	27	Õ	0011 0111	55	37	¦
			0010 1000	40	28	õ	0011 1000	56	38	Å
			0010 1001	41	29	{	0011 1001	57	39	å
			0010 1010	42	2A	}	0011 1010	58	3A	Ø
			0010 1011	43	2B	\	0011 1011	59	3B	ø									
			0010 1100	44	2C	^	0011 1100	60	3C	+ --->  ┘	┐	┌	└
			0010 1101	45	2D	_
			0010 1110	46	2E	|
			0010 1111	47	2F	~
		
			*/
		
		private static var extendedPortGermanDutchCharacters:Object = {"32":"Ã","33":"ã","34":"Í","35":"Ì","36":"ì",
																		"37":"Ò","38":"ò","39":"Õ","40":"õ",
																		"41":"{","42":"}","43":"\\","44":"^","45":"_",
																		"46":"|","47":"~","48":"Ä", "49":"ä","50":"Ö", 
																		"51":"ö", "52": "ß","53":"¥", "54":"¤", "55":"¦", 
																		"56":"Å", "57":"å", "58":"Ø", "59":"ø", "60":"┌", 
																		"61":"┐", "62":"└","63":"┘"};
		/* 
		Extended Spanish/French

		0010 0000	32	20	Á	0011 0000	48	30	À
		0010 0001	33	21	É	0010 0001	49	31	Â
		0010 0010	34	22	Ó	0011 0010	50	32	Ç
		0010 0011	35	23	Ú	0011 0011	51	33	È
		0010 0100	36	24	Ü	0011 0100	52	34	Ê
		0010 0101	37	25	ü	0011 0101	53	35	Ë
		0010 0110	38	26	´	0011 0110	54	36	ë
		0010 0111	39	27	¡	0011 0111	55	37	Î
		0010 1000	40	28	*	0011 1000	56	38	Ï
		0010 1001	41	29	'	0011 1001	57	39	ï
		0010 1010	42	2A	-	0011 1010	58	3A	Ô
		0010 1011	43	2B	©	0011 1011	59	3B	Ù
		0010 1100	44	2C	SM	0011 1100	60	3C	ù
		0010 1101	45	2D	·	0011 1101	61	3D	Û
		0010 1110	46	2E	"	0011 1110	62	3E	«
		0010 1111	47	2F	"	0011 1111	63	3F	»
		*/
		private static var extendedSpanishFrenchCharacters:Object = {"32":"Á","33":"É","34":"Ó","35":"Ú","36":"Ü",
																		"37":"ü","38":"´","39":"¡","40":"*",
																		"41":"'","42":"-","43":"©","44":"℠","45":"·",
																		"46":"\"","47":"\"","48":"À", "49":"Â","50":"Ç", 
																		"51":"È", "52":"Ê","53":"Ë", "54":"ë", "55":"Î", 
																		"56":"Ï", "57":"ï", "58":"Ô", "59":"Ù", "60":"ù", 
																		"61":"Û", "62":"«","63":"»"};
		//00010011
		public static const GERMAN_DUTCH:uint = 0x13;
		//00010010
			public static const SPANISH_FRENCH:uint = 0x12;
		public function CharacterMapping()
		{
		}
		
		public static function getCharacter(charCode:uint):String
		{
			var character:String = '';
			//Mapping only the non unicode chatacters
			if(nonUnicodeMapping.hasOwnProperty(charCode.toString()))
			{
				character = nonUnicodeMapping[charCode.toString()];
			}
			else
			{
				character = String.fromCharCode(charCode);
				if(character == "\u0000")
				{
					//This is the null character, so lets not send anything
					character = '';
				}
			}
			return character;
		}
		
		public static function getSpecialCharacter(charCode:uint):String
		{
			return specialCharacter[charCode.toString()];
		}
		
		public static function getExtendedSpecialCharacter(charCode:uint, charset:uint):String
		{
			return (charset == GERMAN_DUTCH)? extendedPortGermanDutchCharacters[charCode.toString()]:
												extendedSpanishFrenchCharacters[charCode.toString()];
		}
	}
}