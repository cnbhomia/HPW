$title Refinery Optimization (REFINERY, SEQ =xx)
*          **          **          **          **          **          **          **          *
$ontext
This LP problem optimizes a refinery model to decide operation strategy for producing
Petrol, Jet Fuel, Fuel Oil and Lube Oil using two different variety of Crudes.
Some produts like petrol and jet fuel have an associated property which must be
within certain bounds in the product. The model consists of mass balances across
the units, and the process streams. 

Model Building in Mathematical Programming, Fifth Edition,
H. Paul Williams, Model 12.6 : Refinery
Wiley Publication, 2013
$offtext

Sets
    Fluid               'all process fluid in the refinery'
                        /CRD1,CRD2, LN,MN,HN,LO,HO,RES, RGAS, COIL,CGAS,LOIL,REG, PRE, JET, FUEL/
    Crude(fluid)        'Crude Oil'
                        /CRD1, CRD2/
                
    Sellfluid(fluid)    'Intermediate and final products that can be sold'
                        /LN,MN,HN,LO,HO,RES, RGAS, COIL,CGAS,LOIL, REG, PRE, JET, FUEL/  

    Products(fluid)     'Final products sold in the model'
                        /REG, PRE, JET, FUEL, LOIL/
                
    Process             'processes in the refinery'
                        / Dist, Refmr, Crckr, Rblnd, Pblnd, Jblnd, Fblnd/

    rxn(process)        'Reactive Processes in refinery'
                        /Dist, Refmr, Crckr/

    mix(process)        'Mixing Processes in refinery'
                        /Rblnd, Pblnd, Jblnd, Fblnd/

    crkoil(fluid)       'Oils sent to cracker'
                        /LO,HO/

    naptha(fluid)       'Naptha in the refinery'
                        /LN,MN,HN/
    ;

Alias (Fluid,f,g), (Crude,cr), (Process,p), (Products,prd),(Sellfluid,sf);

Set inmap(f,p)          'Process Inputs mapping '
                        / (CRD1,CRD2).Dist, (LN,MN,HN).Refmr, (LO,HO,RES).Crckr ,
                        (LN,MN,HN,CGAS,RGAS).(Rblnd,Pblnd),(LO,HO,RES,COIL).Jblnd , (LO,COIL,HO,RES).Fblnd /
    ;

Set outmap(p,f)         'Process Inputs mapping '
                        /Dist.(LN,MN,HN,LO,HO,RES), Refmr.(RGAS) ,Crckr.(COIL,CGAS,LOIL),
                        Rblnd.REG,Pblnd.PRE, Jblnd.(JET), Fblnd.FUEL /
    ;

Table Convert(f,rxn,g)  'Conversion Ratio, Input-Output for a Reactive Process'

            LN     MN      HN      LO      HO      RES     RGAS    COIL    CGAS    LOIL
CRD1.Dist   0.1    0.2     0.2     0.12    0.2     0.13
CRD2.Dist   0.15   0.25    0.18    0.08    0.19    0.12
LN.Refmr                                                    0.6
MN.Refmr                                                    0.52
HN.Refmr                                                    0.45
LO.Crckr                                                           0.68    0.28
HO.Crckr                                                           0.75    0.2
RES.Crckr                                                                           0.5
;

Parameter SellPr(sf)    'Selling Price of Products [$100]'
                        /PRE 7, REG 6, JET 4, FUEL 3.50, LOIL 1.5/
    ;
       
Parameter Octane(f)     'Octane Number of intermediate fluids'
                        / LN 90, MN 80, HN 70, RGAS 115, CGAS 105/
    ;

Parameter VPress(f)     'Octane Number of intermediate fluids'
                        / LO 1, HO 0.6, COIL 1.5, RES 0.05/
          Pmap(f,g)     'Property distribution (input-output)mapping for quality paramters'

          Capacity(rxn) 'Capacity of reactive processes'
                        /Dist 45000, Refmr 10000, Crckr 8000/
          ;
          
Pmap(f,g)$[sum(p,inmap(f,p)*outmap(p,g))] =1;

Positive Variables
    Zmade(f,p)      'Quantity generated from process'
    Zuse(f,p)       'Quantity going into Process'
    Zsell(sf)       'Quantity of fluid sold'
    ;
Variable Profit     'Net Profit'
    ;

Equation
    Massbal(f)        'Mass balance of the fluids, [barrels]'
    reactions(f,p)    'Mass of products from reactive processes, [barrels]'
    mixing(f,p)       'Mass of products from mixing/blending processes, [barrels]'  
    GasProdtn         'Minimum quanity of Premium Gasoline produced, [barrels]'
    RegOctane         'Octane number limit for Regular Gasoline'
    PreOctane         'Octane number limit for Premium Gasoline'
    JetPress          'Vapor Pressure limit for Jet Fuel'
    FuelMix           'Mixing Ratio constraint for Fuel Oil'
    DistilCap         'Capacity Constraint for distillation, [barrels]'
    ReformCap         'Capacity Constraint for Reformer, [barrels]'
    CrckrCap          'Capacity constraint for cracking oil, [barrels]'
    objfunc           'Objective function, Profit Calculation, [$100'
    ;

*Logical Zero Flow rates

Zmade.fx(cr,p) =0;
Zmade.fx(f,p)$(not outmap(p,f)) =0;
Zuse.fx(f,p)$(not inmap(f,p)) =0;

*Crude Availability
Zuse.up('CRD1',p) = 20000;
Zuse.up('CRD2',p) = 30000;


massbal(sf(f))..                        sum(p$outmap(p,sf),Zmade(sf,p)) =E= Zsell(sf) + sum(p$inmap(sf,p),Zuse(sf,p));

reactions(f,rxn(p))$outmap(rxn,f)..     Zmade(f,rxn) =E= sum(g$inmap(g,rxn), convert(g,rxn,f) * Zuse(g,rxn));

mixing(sf(f),mix(p))$outmap(mix,sf)..   Zmade(sf,mix)  =E= sum(g$inmap(g,mix), Zuse(g,mix));

GasProdtn..                             Zmade('PRE','Pblnd') =G= 0.4* Zmade('REG','Rblnd');

RegOctane ..                            Zmade('REG','Rblnd')*84 =L= sum(f$Pmap(f,'REG'), Zuse(f,'Rblnd')*octane(f));
                                        
PreOctane..                             Zmade('PRE','Pblnd')*94 =L= sum(f$Pmap(f,'PRE'), Zuse(f,'Pblnd')*octane(f));
                                        
JetPress..                              Zmade('JET','Jblnd')*1 =G= sum(f$Pmap(f,'JET'), Zuse(f,'Jblnd')*Vpress(f));
                                        
FuelMix..                               Zmade('FUEL','Fblnd') *18 =E= 10*Zuse('LO','Fblnd') +  4*Zuse('COIL','Fblnd')+ 3*Zuse('HO','Fblnd')
                                                                             + Zuse('RES','Fblnd');
DistilCap..                             sum(cr, Zuse(cr,'Dist')) =L= Capacity('Dist');
                                        
ReformCap..                             sum(nap, Zuse(nap,'Refmr')) =L= Capacity('Refmr');
                                        
CrckrCap..                              sum(crkoil, Zuse(crkoil,'Crckr')) =L= Capacity('Crckr');


*market demands
Zsell.lo('LOIL') =500;
Zsell.up('LOIL') =1000;

model refinery /all/;
solve refinery using LP max Profit;

