sets
    crude   /CRD1,CRD2/
    distil  / LN,MN,HN,LO,HO,RES/
    reform(distil) /LN,MN,HN/
    cracking(distil) /LO,HO,RES/
    intermediates /RGAS, COIL,CGAS,LOIL/
    gasblendD(distil)/LN,MN,HN/
    jetblendD(distil)   /LO,HO,RES/
    fuelblendD(distil) / LO, HO, RES/
    gasblendI(intermediates) /RGAS,CGAS/
    jetblendI(intermediates) / COIL/
    fuelblendI(intermediates) /COIL/
    gasoline    /REG,PRE/
    ;


parameters
    octaneD(gasblendD) / LN 90, MN 80, HN 70/
    octaneI(gasblendI) /RGAS 115, CGAS 105/
    octane(gasoline) /REG 84 , PRE 94/
    vapPresD(jetblendD) /LO 1.0,HO 0.6, RES 0.05/
    vapPresI(jetblendI) / COIL 1.5/

    ;
             
table Dratio(crude,distil)
         LN      MN      HN      LO      HO      RES
CRD1     0.1     0.2     0.2     0.12    0.2     0.13
CRD2     0.15    0.25    0.18    0.08    0.19    0.12
;

parameter yieldRef(distil) 'yield in reforming' /LN 0.6 , MN 0.52, HN 0.45/ ;

table yieldcrack(cracking,intermediates)
    COIL    CGAS    LOIL
LO  0.68    0.28
HO  0.75    0.2
RES                 0.5
;
positive variables
    mCrude(crude)       'mass of crude'
    mDistil(distil)        'mass of distillation products'
    mReform(distil)     'mass of distillation products to reformer'
    mCrack(distil)      'mass of distillation products to cracking'
    mGasblendD(distil)       "mass of distialltion product to gasoline blending"
    mJetblendD(distil)   'mass of distillation product to jet ful blending'
    mFuelblendD(distil)  'mass of distillation product to fuel oil blending'
    mInter(intermediates) 'mass of intermediates produced'
    mGasblendI(intermediates) 'mass of intermediates for gasoline blending'
    mJetblendI(intermediates) 'mass of intermediates for jet fuel blending'
    mFuelblendI(intermediates) 'mass of intermediates fuel oil blending'

    mGasblendPRE
    mGasblendREG
    mGasSell(gasoline)    'mass of gasoline produced'
    mJetfuel
    mFueloil
    mLOILsell
    ;
variable profit
    ;

mCrude.up('CRD1') = 20000; 
mCrude.up('CRD2') = 30000;
mInter.up('LOIL') = 1000;
mInter.lo('LOIL') = 500;



equation
    distillation(distil) "mass balance for distillation"
    massbalance1(distil) "mass balance for distiallates between processes"
    mbalreform(intermediates)           'mass balance for reforming'
    mbalcrack(intermediates)
*    mbalGasblend(gasoline)

    massbalance2(intermediates) "mass balance for intermediates between processses"
    gasblending         "mass balance inside gas blender"
    gasblendratio   "ratio of PRE to REG"
    jetblending     "mass balance jetfuel blending"
    fuelblending    "mass balance fuel oil blending"
    decisions   
    distillimit     "limit on crude distillation capacity"
    reformlimit     "limit on crude distillation capacity"
    cracklimit      "limit on crude distillation capacity"
    ;


distillation(distil).. mDistil(distil) =e= sum(crude,Dratio(crude,distil)*mCrude(crude))    ;


massbalance1(distil).. mDistil(distil) =e= mReform(distil)$reform(distil) + mCrack(distil)$cracking(distil)
                                           +  mGasblendD(distil)$gasblendD(distil) +mJetblendD(distil)$jetblendD(distil)
                                             + mFuelblendD(distil)$fuelblendD(distil)  ;

mbalreform(intermediates)$(ord(intermediates)=1).. mInter(intermediates) =e= sum(distil, mReform(distil)* yieldRef(distil));

mbalcrack(intermediates)$(ord(intermediates)>1).. mInter(intermediates) =e=
                                                    sum(cracking, mCrack(cracking)*yieldcrack(cracking,intermediates));


$ontext
mbalGasblend(gasoline).. sum((gasoline),mGassell(gasoline)) =e=
                                            sum(distil,mGasblendD(distil)) + sum(gasblendI,mInter(gasblendI))
$offtext


massbalance2(intermediates).. mInter(intermediates) =e= mGasblendI(intermediates)$gasblendI(intermediates)
                                                            +  mJetblendI(intermediates)$jetblendI(intermediates)
                                                            + mFuelblendI(intermediates)$fuelblendI(intermediates)
                                                            + mLOILsell$(ord(intermediates) = 4);

*gasoline production

gasblending(gasoline).. mGasSell(gasoline)*octane(gasoline) =e= sum(gasblendD,mGasblendD(gasblendD,gasoline)*octaneD(gasblendD)) +
                                                                sum(gasblendI,mGasblendI(gasblendI,gasoline)*octaneI(gasblendI)) ;

                                                            

gasblendratio.. mGassell('PRE') =g= 0.4 * mGassell('REG');

jetblending.. mJetfuel =l= sum(jetblendD,mJetblendD(jetblendD)*vapPresD(jetblendD))
                                                        + sum(jetblendI,mJetblendI(jetblendI)*vapPresI(jetblendI)) ;

fuelblending.. 18* mFueloil =e= 10*mFuelblendD('LO') + 3*mFuelblendD('HO') + mFuelblendD('RES') + mFuelblendI('COIL')*4 ;

distillimit.. sum(crude,mCrude(crude)) =l= 45000;

reformlimit.. sum(reform,mReform(reform)) =l= 10000 ;

cracklimit.. sum(cracking,mCrack(cracking)) =l= 8000;

decisions.. profit =e= mGassell('PRE')*700 + mGassell('REG')*600 + mJetfuel*400 + mFueloil*350 + mLOILsell* 150;

model refinery /all/

option limrow =10;

solve refinery using LP maximizing profit;



