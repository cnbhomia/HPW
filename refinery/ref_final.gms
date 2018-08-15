$title Refinery Production Strategy (REFINERY, SEQ =xx)

$ontext
This LP problem uses a refinery model to decide operation strategy for producing Petrol, Jet Fuel, Fuel Oil
and Lube Oil using two different variety of Crudes.
Some produts like petrol and jet fuel have an associated property which must be within certain bounds in the product.
The model consists of mass balances across the units, and the process streams. 

Model Building in Mathematical Programming, Fifth Edition,
H. Paul Williams, Model 12.5 : Refinery
Wiley Publication, 2013
$offtext

Sets
    Crude   'crude oil available'  /C1,C2/
    ;

Positive Variables
*following variables are mass flow rates in Barrels
    C1      'Crude 1 available for refining'
    C2      'Crude 2 available for refining'
       
    LN      'Light Naptha produced at distillation'
    MN      'Medium Naptha produced at distillation'
    HN      'Heavy Naptha produced at distillation'
    LO      'Light Oil produced at distillation'
    HO      'Heavy Oil produced at distillation'
    RS      'Residue produced at distillation'
    RG      'Reformed Gasoline produced in the reformer'
    LN2REF  'LN sent to Reformer'
    LN2PRE  'LN for blending for Premium Petrol'
    LN2REG  'LN for blending for Regular Petrol'
    MN2REF  'MN sent to Reformer'
    MN2PRE  'MN used for Premium Petrol'
    MN2REG  'MN used for Regular Petrol'
    HN2REF  'HN sent to Reformer'
    HN2PRE  'HN used for Premium Petrol'
    HN2REG  'HN used for Regular Petrol'

    RG2REG  'Reformed Gas for Regular Petrol' 
    RG2PRE  'Reformed Gas for Premium Petrol' 
    LO2CRK  'LO sent to cracking'
    LO2COL  'part of LO2CRK used for making crack oil'
    LO2CGS  'part of LO2CRK used for making crack gas'
    LO2BJF  'LO sent to Jet Fuel(JF) Blending'
    LO2BFO  'LO sent to Fuel Oil(FO) Blending'
    HO2CRK  'HO sent to cracking'
    HO2COL  'part of HO2CRK used for making crack oil'
    HO2CGS  'part of HO2CRK used for making crack gas'
    HO2BJF  'HO sent to Jet Fuel(JF) Blending'
    HO2BFO  'HO sent to Fuel Oil(FO) Blending'
    RS2CRK  'Residuum sent for cracking'
    RS2BJF  'Residuum sent for Jet Fuel(JF) Blending'
    RS2BFO  'Residuum sent for Jet Fuel(FO) Blending'
    CRKGAS  'Cracked Gasoline(CRKGAS/CG) produced in cracking'
    CG2PRE  'Cracked Gasoline used for Premium Petrol'
    CG2REG  'Cracked Gasoline used for Regular Petrol'
    
    CRKLOL  'Lube Oil (LO) produced by cracker'
    CO2BJF  'Cracked Oil to blending of jet fuel'
    CO2BFO  'Cracked Oil to blending of fuel oil'
    REGPET  'Regular Petrol from blending'
    PREPET  'Premium Petrol from blending'
    JETFUL  'Jet Fuel from blending'
    FULOIL  'Fuel Oil from blending'
    ;
Free Variable PROFIT  'Objective Variable, to be maximized,[Pounds/Barrel]'
    ;

Equations
    LNaptha 'Production of Light Naptha by distillation column'
    MNaptha 'Production of Medium Naptha by distillation column'
    HNaptha 'Production of Heavy Naptha by distillation column'
    LightOL 'Production of Light Oilby distillation column'
    HeavyOL 'Production of Heavy Oilby distillation column'
    Residum ' Production of Residuum by distillation column'
    Reformr 'Reformer Mass Balance' 

    CrkrLOP 'Mass balance for Light oil sent for cracking'
    CrkrHOP 'Mass balance for Heavy oil sent for cracking'
    CrkrRSP 'Mass balance for Residumm sent for cracking'
    CrkrOIL 'Total cracked oil produced'
    CrkrGAS 'Total cracked gas produced'
   

    BlenPRE 'Mass balance, blending motor fuels to make Premiun(PREPET) petrol'
    BlenREG 'Mass balance, blending motor fuels to make Regular(REGPET) petrol'
    BlendJF 'Mass balance, blending jet fuel '
    
*    BlendFO 'Mass balance, blending fuel oil '
    DistCap 'Capacty of Distillation'
    RefrCap 'Capacity of Reformer'
    CrkrCap 'Capacity of Cracker'
    PetBlen 'Petrol, minimum Premium petrol production'
    PREOcNo 'Limits on Octane number for premium petrol'
    REGOcNo 'Limits on Octane number for Regular petrol'
    JETPres 'Vapor Pressure contraint on Jet Fuel'
    ObjEqtn 'Objective Equation, maximization of Profit'


    LNbal
    MNbal
    HNbal
    LObal
    HObal
    RSbal
    RGbal
    ;

*flow rate bounds
C1.up = 20000;
C2.up = 30000;
CRKLOL.lo = 500;
CRKLOL.up = 1000;

*distillation column balances
LNbal.. LN =E= LN2REF + LN2REG + LN2PRE ;
MNbal.. MN =E= MN2REF + MN2REG + MN2PRE ;
HNbal.. HN =E= HN2REF + HN2REG + HN2PRE ;
LObal.. LO =E= LO2CRK + LO2BJF + (10/18)* FULOIL ;
HObal.. HO =E= HO2CRK + HO2BJF + (3/18)* FULOIL ;
RSbal.. RS =E= RS2CRK + RS2BJF + (1/18)* FULOIL ;
RGbal.. RG =E= RG2PRE + RG2REG ;

LNaptha.. LN =E= 0.10 * C1 + 0.15 * C2;
MNaptha.. MN =E= 0.20 * C1 + 0.25 * C2;
HNaptha.. HN =E= 0.20 * C1 + 0.18 * C2;
LightOL.. LO =E= 0.12 * C1 + 0.08 * C2;
HeavyOL.. HO =E= 0.20 * C1 + 0.19 * C2;
Residum.. RS =E= 0.13 * C1 + 0.12 * C2;

*reforming and cracking balances
Reformr.. RG =E= 0.60 * LN2REF + 0.52 * MN2REF + 0.45 * HN2REF ;
CrkrLOP.. LO2CRK  =E=  LO2COL + LO2CGS ;
*CrkrHOP.. HO2CRK  =E=  HO2COL + HO2CGS ;
CrkrHOP.. HO2CRK  =E=  HO2COL + HO2CGS ;
CrkrOIL.. CO2BJF + (4/18)* FULOIL =E= 0.68 * LO2COL + 0.75 * HO2COL ;
CrkrGAS.. CG2PRE + CG2REG  =E= 0.28 * LO2CGS + 0.20 * HO2CGS ;
CrkrRSP.. CRKLOL =E= RS2CRK*0.5  ;

*blending balances
BlenPRE.. PREPET =E= RG2PRE + LN2PRE + MN2PRE + HN2PRE + CG2PRE ;
BlenREG.. REGPET =E= RG2REG + LN2REG + MN2REG + HN2REG + CG2REG ;
BlendJF.. JETFUL =E= LO2BJF + HO2BJF + CO2BJF + RS2BJF ;

*BlendFO.. FULOIL =E= LO2BFO + HO2BFO + CO2BFO + RS2BFO ; 

*contraints and capacitites
DistCap.. C1 + C2 =L= 45000;
RefrCap.. LN2REF +  MN2REF + HN2REF =L= 10000 ;
CrkrCap.. LO2CRK + HO2CRK =L= 8000;
PetBlen.. PREPET =G= 0.4*REGPET ;
PREOcNo.. 115 * RG2PRE + 90 * LN2PRE + 80 * MN2PRE + 70 * HN2PRE + 105 * CG2PRE =G= 94*PREPET ;
REGOcNo.. 115 * RG2REG + 90 * LN2REG + 80 * MN2REG + 70 * HN2REG + 105 * CG2REG =G= 84*REGPET ;
JETPres.. 1.0* LO2BJF + 0.6* HO2BJF + 1.5* CO2BJF + 0.05* RS2BJF =L= 1.0* JETFUL ;

ObjEqtn.. PROFIT =E= PREPET*7 +  REGPET*6 + JETFUL*4 + FULOIL*3.5 + CRKLOL*1.50 ;

*initilizations
C1.l = 15000;
C2.l = 30000;
LN.l = 6000;
MN.l = 10500;
HN.l = 8400;
LO.l = 4200;
HO.l = 8700;      
RS.l = 5550;      
RG.l = 2433      
LN2REF.l = 0;  
LN2PRE.l = 0;  
LN2REG.l = 6000;  
MN2REF.l = 0;  
MN2PRE.l = 3537;  
MN2REG.l = 6962;  
HN2REF.l = 5407;
HN2PRE.l = 0;
HN2REG.l = 2993;  
RG2REG.l = 1089;
RG2PRE.l = 1344;
LO2CRK.l = 4200;
LO2COL 
LO2CGS  
LO2BJF.l = 0;  
LO2BFO.l = 0;  
HO2CRK.l = 3800;  
HO2COL  
HO2CGS  
HO2BJF.l = 4900;  
HO2BFO.l = 0;  
RS2CRK.l = 1000; 
RS2BJF.l = 4550;  
RS2BFO.l = 0;  
CRKGAS.l = 1936;  
CG2PRE  
CG2REG  

CRKLOL.l = 500;
CO2BJF.l = 5706;   
CO2BFO.l = 0;
REGPET.l = 17044;  
PREPET.l = 6818;  
JETFUL.l = 15156;  
FULOIL.l = 0;  






$ontext
*initial points
LN2REF.L = 0;
MN2REF.L = 0;
HN2REF.L = 5406.85;

C1.L=15000;
C2.L=30000;
LO.L =4200;
HO.L = 8700;
LN.L =6000;
RS.L = 5550;
LN2REG.L = 6000;
LN2PRE.L = 0;
MN.L=10500;
HN.L=8400;

MN2PRE.L = 3537;
MN2REG.L = 6962;
HN2PRE.L = 0;
HN2REG.L = 2993 ;

RG2PRE.L = 1344 ;
RG2REG.L = 1089 ;
RG.L = 2433;

CG2PRE.L = 1936 ;
CG2REG.L=0 ;
HO2BJF.L = 4900 ;
RS2BJF.L = 4550 ;

LO2CRK.L = 4200 ;
HO2CRK.L = 3800 ;

CO2BJF.L = 5706 ;
RS2CRK.L = 1000 ;

CRKLOL.L = 500;
FULOIL.L = 0;

PREPET.L = 6818;
REGPET.L = 17044;
JETFUL.L = 15156 ; 
$offtext
Model refinery /all/;

solve refinery using LP maximizing PROFIT;




