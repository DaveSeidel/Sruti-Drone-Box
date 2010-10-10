;-------------------------------------------------------------------------
;
;   Drone Instrument/Sruti Box
;   by Dave Seidel (dave at mysterybear dot com)
;   http://mysterybear.net
;
;   Copyright 2005, Dave Seidel. Some rights reserved.
;   This work is licensed under a Creative Commons "Attribution" License.
;   http://creativecommons.org/licenses/by/2.0/
;
;-------------------------------------------------------------------------

<CsoundSynthesizer>
<CsOptions>

;-+P3 -m0 -+O ; for CsoundAV realtime
;-o devaudio ; for MyCsound4 & flcsound (csoundgbs) realtime. Adding a -b1000 flag to this line may help performance.
-o dac ; for Csound5

</CsOptions>
<CsInstruments>

;-------------------------------------------------------------------------
; globals
;-------------------------------------------------------------------------

sr     = 44100
kr     = 441
ksmps  = 100
nchnls = 2

; basic offset value for Risset effect
giofs   init    .01

; zak channels
zakinit 16, 16

;-------------------------------------------------------------------------
; waveform tables
;-------------------------------------------------------------------------

giTblSz init    1048576

; pure sine wave
giFn1 ftgen   1, 0, giTblSz, 10, 1


; sawtooth wave – all partials (through 17) at a strength of 1/harmonic#
giFn2 ftgen   2, 0, giTblSz, 10, 1, .5, .3333, .25, .2, .1667, .1428, .125, .111, .1, .0909, .0833, .077, .0714, .0667, .0625, .0588

; first 13 partials, strength = 1/n + 1/(n-1)
giFn3 ftgen   3, 0, giTblSz, 10, 1, 1.5,  .8333, .58, .45, .367, .31, .268,  .236, .211, .1909, .1742, .1603


; square wave – odd partials (through 19) at a strength of 1/harmonic#
giFn4 ftgen   4, 0, giTblSz, 9,  1,1,0,  3,.3333,0, 5,.2,0,     7,.1428,0, 9,.111,0,  11,.0909,0,  13,.077,0,  15,.0667,0,  17,.0588,0,  19,.0526,0

; odd partials to 19, strength = 1/n, where n is ordinal to the odd set
giFn5 ftgen   5, 0, giTblSz, 9,  1,1,0,  3,.5,0,    5,.3333,0,  7,.25,0,   9,.2,0,    11,.1667,0,  13,.1429,0, 15,.125,0,   17,.1111,0,  19,.1,0


; prime partials to 23, strength = 1/n
giFn6 ftgen   6, 0, giTblSz, 9,  1,1,0,  2,.5,0,  3,.3333,0,  5,.2,0,    7,.143,0,  11,.0909,0,  13,.077,0,   17,.0588,0,  19,.0526,0, 23,.0435,0, 27,.037,0

; primes to 23, strength = 1/n, where n is ordinal to the prime set
giFn7 ftgen   7, 0, giTblSz, 9,  1,1,0,  2,.5,0,  3,.3333,0,  5,.25,0,   7,.20,0,   11,.1667,0,  13,.1429,0,  17,.125,0,   19,.1111,0, 23,.1,0,    27,.0909,0


; partials in the Fibonacci series to 89, strength = 1/n
giFn8 ftgen   8, 0, giTblSz, 9,  1,1,0,   2,.5,0,   3,.3333,0,  5,.2,0,   8,.125,0,  13,.0769,0,  21,.0476,0,  34,.0294,0,  55,.0182,0,  89,.0112,0 144,.0069,0

; fibs to 89, strength = 1/n, where n is ordinal to the fib set
giFn9 ftgen   9, 0, giTblSz, 9,  1,1,0,   2,.5,0,   3,.3333,0,  5,.25,0,  8,.2,0,    13,.1667,0,  21,.1429,0,  34,.125,0,   55,.1111,0,  89,.1,0,   144,.0909,0

; David First's "asymptotic sawtooth wave"
giFn10 ftgen 10, 0, giTblSz, 9,  1,1,0,   1.732050807568877,.5773502691896259,0,   2.449489742783178,.408248290463863,0,   3.162277660168379,.3162277660168379,0,   3.872983346207417,.2581988897471611,0,   4.58257569495584,.2182178902359924,0,   5.291502622129182,.1889822365046136,0, 6,.1666666666666667,0,   6.70820393249937,.1490711984999859,0,   7.416198487095663,.1348399724926484,0,   8.124038404635961,.1230914909793327,0,   9.539392014169456,.1048284836721918,0,  10.2469507659596,.0975900072948533,0,  10.95445115010332,.0912870929175277,0,   11.6619037896906,.0857492925712544,0


;---------------------------------------------------------------------------
; orchestra macros
;---------------------------------------------------------------------------

; base pitch in specified octave above base
#define BOCT(O) #gkroot*(2^($O.))#

; for UI
#define XOFS    #50#
#define X(xx)   #($XOFS.+($xx.))#

#define YOFS    #0#
#define Y(yy)   #($YOFS.+($yy.))#

;-------------------------------------------------------------------------
; UI
;-------------------------------------------------------------------------

            FLpanel "Drone/Sruti Box [Dave Seidel 2005, release 2]", 530, 420, 100, 100

; per-drone settings, in vertical columns by drone

gkd1,gi1        FLbutton        "1",    1, 0, 2,            40,  30,  $X.(35),  35, -1
gkd2,gi2        FLbutton        "2",    1, 0, 2,            40,  30, $X.(138),  35, -1
gkd3,gi3        FLbutton        "3",    1, 0, 2,            40,  30, $X.(241),  35, -1
gkd4,gi4        FLbutton        "4",    1, 0, 2,            40,  30, $X.(344),  35, -1

gknu1,i1a       FLcount         " ",    1, 1500, 1, 10, 1,  98,  25,   $X.(6),  75, -1
                FLsetVal_i      1, i1a
gknu2,i2a       FLcount         " ",    1, 1500, 1, 10, 1,  98,  25, $X.(109),  75, -1
                FLsetVal_i      3, i2a
gknu3,i3a       FLcount         " ",    1, 1500, 1, 10, 1,  98,  25, $X.(212),  75, -1
                FLsetVal_i      2, i3a
gknu4,i4a       FLcount         " ",    1, 1500, 1, 10, 1,  98,  25, $X.(315),  75, -1
                FLsetVal_i      2, i4a

gkde1,i1b       FLcount         " ",    1, 1500, 1, 10, 1,  98,  25,   $X.(6), 105, -1
                FLsetVal_i      1, i1b
gkde2,i2b       FLcount         " ",    1, 1500, 1, 10, 1,  98,  25, $X.(109), 105, -1
                FLsetVal_i      2, i2b
gkde3,i3b       FLcount         " ",    1, 1500, 1, 10, 1,  98,  25, $X.(212), 105, -1
                FLsetVal_i      1, i3b
gkde4,i4b       FLcount         " ",    1, 1500, 1, 10, 1,  98,  25, $X.(315), 105, -1
                FLsetVal_i      1, i4b

gkoc1,i1c       FLcount         " ",    -7, 7, 1, 1, 1,     98,  25,   $X.(6), 150, -1
                FLsetVal_i      1, i1c
gkoc2,i2c       FLcount         " ",    -7, 7, 1, 1, 1,     98,  25, $X.(109), 150, -1
                FLsetVal_i      1, i2c
gkoc3,i3c       FLcount         " ",    -7, 7, 1, 1, 1,     98,  25, $X.(212), 150, -1
                FLsetVal_i      1, i3c
gkoc4,i4c       FLcount         " ",    -7, 7, 1, 1, 1,     98,  25, $X.(315), 150, -1
                FLsetVal_i      1, i4c

gkx1,gi1a       FLbutton        " mute",       1, 0, 3,     40,  40,  $X.(35), 190, -1
gkx2,gi2b       FLbutton        " mute",       1, 0, 3,     40,  40, $X.(138), 190, -1
gkx3,gi3c       FLbutton        " mute",       1, 0, 3,     40,  40, $X.(241), 190, -1
gkx4,gi4d       FLbutton        " mute",       1, 0, 3,     40,  40, $X.(344), 190, -1

; global settings and controls

;gkroot,iroot    FLcount         "Root (Hz)",  0.00, 440.00, .05, 5, 1,\
;                                                            124,  30, $X.(145), 235, -1
gkroot,iroot    FLtext           "Base pitch (Hz)",  0.00, 440.00, .05, 1,\
                                                            124,  30, $X.(145), 235
                FLsetVal_i      60.00, iroot

il12            FLbox           "Waveforms", 1, 1, 14,      70,  25,  $X.(12), 295
gktbl,itbl      FLbutBank       1,10, 1,                   300,  25,  $X.(90), 295, -1, 0
                FLsetVal_i      0, itbl
                FLsetText       "0=Sine  1,2=Sawtooth  3,4=Square  5,6=Prime  7,8=Fibonacci  9=Asymptotic sawtooth", itbl

gkdall,giAll    FLbutton        "Play",   1, 0, 2,          60,  30,  $X.(30), 355, -1
gkdoff,giOff    FLbutton        "Stop",   1, 0, 2,          60,  30,  $X.(93), 355, -1
gkOfs,iR        FLbutton        "Harmonic arpeggio", 1, 0, 3,\
                                                           140,  30, $X.(170), 355, -1

        FLpanelEnd
        FLrun

;---------------------------------------------------------------------------------------
; drone scheduler (thanks to Art Hunkins)
;---------------------------------------------------------------------------------------

        instr   3

gkdoff1 trigger         gkdoff,         .5, 0
        schedkwhen      gkdoff1,        0,  0,  5, 0, 1
gkdall1 trigger         gkdall,         .5, 0
        schedkwhen      gkdall1,        0,  0,  6, 0, 1

DRONE1:
        if gkx1 == 1 kgoto DRONE2
kd1     trigger         gkd1,           .5, 0
        schedkwhen      kd1,            0,  0,  4.1, 0, -1, 1300, gktbl+1, 2, $BOCT.(gkoc1), gknu1, gkde1, giofs
kd1a    trigger         gkd1,           .5, 1
        schedkwhen      kd1a,           0,  0, -4.1, 0, 0

DRONE2:
        if gkx2 == 1 kgoto DRONE3
kd2     trigger         gkd2,           .5, 0
        schedkwhen      kd2,            0,  0,  4.2, 0, -1, 1300, gktbl+1, 3, $BOCT.(gkoc2), gknu2, gkde2, giofs
kd2a    trigger         gkd2,           .5, 1
        schedkwhen      kd2a,           0,  0, -4.2, 0, 0

DRONE3:
        if gkx3 == 1 kgoto DRONE4
kd3     trigger         gkd3,           .5, 0
        schedkwhen      kd3,            0,  0,  4.3, 0, -1, 1300, gktbl+1, 4, $BOCT.(gkoc3), gknu3, gkde3, giofs
kd3a    trigger         gkd3,           .5, 1
        schedkwhen      kd3a,           0,  0, -4.3, 0, 0

DRONE4:
        if gkx4 == 1 kgoto DONE
kd4     trigger         gkd4,           .5, 0
        schedkwhen      kd4,            0,  0,  4.4, 0, -1, 1300, gktbl+1, 5, $BOCT.(gkoc4), gknu4, gkde4, giofs
kd4a    trigger         gkd4,           .5, 1
        schedkwhen      kd4a,           0,  0, -4.4, 0, 0

DONE:
        endin


; turn off drone buttons when Stop button is pressed
        instr   5
        FLsetVal_i      0, giAll
        FLsetVal_i      0, gi1
        FLsetVal_i      0, gi2
        FLsetVal_i      0, gi3
        FLsetVal_i      0, gi4
        endin

; turn on drone buttons when All button is pressed
        instr   6
gkdoff1 =       0
gkd1    =       1
gkd2    =       1
gkd3    =       1
gkd4    =       1
        FLsetVal_i      0, giOff
        FLsetVal_i      1, gi1
        FLsetVal_i      1, gi2
        FLsetVal_i      1, gi3
        FLsetVal_i      1, gi4
        endin

;---------------------------------------------------------------------------
; Risset harmonic arpeggio instrument, adapted from:
; ACCCI:      02_43_1.ORC
; timbre:     tibetan chant
; synthesis:  additive same units(02)
;             basic instrument with minimal differences in frequency(43)
;             arpeggio instrument by Risset
; source:     Phase6, Lorrain(1980); Boulanger(1990): risset1.orc
; coded:      jpg 9/93
;---------------------------------------------------------------------------

                instr   4

idur    =       p3                              ; duration
iamp    =       p4/9                            ; amplitude
ifn     =       p5                              ; function table number (waveform)
izch    =       p6                              ; zak output channel
inum    =       p8
iden    =       p9
ifrac   =       inum/iden
ibase   =       p7
ifreq   =       ibase*ifrac                     ; pitch (base * (n/m))
                print   inum, iden, ifrac, ibase, ifreq

iflag   =       i(gkOfs)
                if iflag == 1 igoto USE_OFS
ioff    =       0
iamp2   =       .75                             ; scale down output if no offsets
                igoto   SET_OFS

USE_OFS:
iamp2   =       1
;ioff   =       p10                             ; same offset for all
;ioff   =       ifrac*p10                       ; proportional to interval
ioff    =       ((iden*2)/inum)*p10             ; inversely proportional to ratio
                print   ioff

SET_OFS:
ioff1   =       ioff                            ; oscillator offset for arpeggio
ioff2   =       2*ioff                          ; .
ioff3   =       3*ioff                          ; .
ioff4   =       4*ioff                          ; .

                if gkdoff1 == 0 goto skip
                turnoff
skip:
                FLsetVal_i      0, giOff
ae              linenr  iamp, 1, 3, .03          ; simple envelope

a1              oscil   ae, ifreq, ifn
a2              oscil   ae, ifreq+ioff1, ifn    ; nine oscillators with the same envelope
a3              oscil   ae, ifreq+ioff2, ifn    ; and waveform, but slightly different
a4              oscil   ae, ifreq+ioff3, ifn    ; frequencies, create harmonic arpeggio
a5              oscil   ae, ifreq+ioff4, ifn
a6              oscil   ae, ifreq-ioff1, ifn
a7              oscil   ae, ifreq-ioff2, ifn
a8              oscil   ae, ifreq-ioff3, ifn
a9              oscil   ae, ifreq-ioff4, ifn

zaw             (a1+a2+a3+a4+a5+a6+a7+a8+a9)*iamp2, izch

                endin

;---------------------------------------------------------------------------
; mixer (adapted from Mikelson, "Modelling a Multieffects Processor")
;   added 4 more channels and a simple reverb at the end
;---------------------------------------------------------------------------

        instr   3099

asig1   zar     p4
igl1    init    p5*p6
igr1    init    p5*(1-p6)

asig2   zar     p7
igl2    init    p8*p9
igr2    init    p8*(1-p9)

asig3   zar     p10
igl3    init    p11*p12
igr3    init    p11*(1-p12)

asig4   zar     p13
igl4    init    p14*p15
igr4    init    p14*(1-p15)

asig5   zar     p16
igl5    init    p17*p17
igr5    init    p17*(1-p18)

asig6   zar     p19
igl6    init    p20*p21
igr6    init    p20*(1-p21)

asig7   zar     p22
igl7    init    p23*p24
igr7    init    p23*(1-p24)

asig8   zar     p25
igl8    init    p26*p27
igr8    init    p26*(1-p27)

asigl   =       asig1*igl1 + asig2*igl2 + asig3*igl3 + asig4*igl4 + asig5*igl5 + asig6*igl6 + asig7*igl7 + asig8*igl8
asigr   =       asig1*igr1 + asig2*igr2 + asig3*igr3 + asig4*igr4 + asig5*igr5 + asig6*igr6 + asig7*igr7 + asig8*igr8

irvtime =       p28
irvfqc  =       p29
irvlev  =               p30
aoutl   nreverb asigl, irvtime, irvfqc
aoutr   nreverb asigr, irvtime, irvfqc

        outs    asigl+(aoutl/irvlev), asigr+(aoutr/irvlev)
        ;out     asigl+(aoutl/irvlev) + asigr+(aoutr/irvlev)

                zacl    0, 16

        endin

</CsInstruments>
<CsScore>

;---------------------------------------------------------------------------
; score
;---------------------------------------------------------------------------

; mixer
;
;       channel 1: unused
;       channel 2-5: drones
;       channel 6-8: unused
;
;i 3099 0 3600 \
;  1 4   .5   \
;  2 1.5 .80  \
;  3 1.5 .20  \
;  4 1.5 .75  \
;  5 1.5 .40  \
;  6 0   .5   \
;  7 0   .5   \
;  8 0   .5   \
;  5 .3 6

i 3099 0 3600 \
  1 4   .5   \
  2 1.5 .5  \
  3 1.5 .5  \
  4 1.5 .5  \
  5 1.5 .5  \
  6 0   .5   \
  7 0   .5   \
  8 0   .5   \
  5 .3 6

i 3 0 3600
e

</CsScore>
</CsoundSynthesizer>

