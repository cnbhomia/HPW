$title Refinery Optimization (REFINERY, SEQ =xx)

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
    fluids      'all process fluids in the refinery'
                 /CRD1,CRD2, LN,MN,HN,LO,HO,RES, RGAS, COIL,CGAS,LOIL
                  REG, PRE, JET, FUEL/

    crude(fluids)   /CRD1, CRD2/
                
    inter(fluids)   'intermediate fluids' /LN,MN,HN,LO,HO,RES, RGAS, COIL,CGAS,LOIL/

    products(fluids)        'final products'    /REG, PRE, JET, FUEL, LOIL/
                
    process         'processes in the refinery'     / Dist, Refmr, Crckr, Rblnd, Pblnd, Jblnd, Fblnd/

    rxn(process)    /Dist, Refmr, Crckr/

    mix(process)    /Rblnd, Pblnd, Jblnd, Fblnd/

    property        /octane, vpress/

    ;

Alias (fluids, f,g,f1), (crude,cr), (process,p), (products,prd) ;

*Set fmap(f,p,g) /(CRD1,CRD2).Dist.(LN,MN,HN,LO,HO,RES), (LN,MN,HN).Refmr.(RGAS) ,
*                          (LO,HO,RES).Crckr.(COIL,CGAS,LOIL) , (LN,MN,HN).(Rblnd,Pblnd).(REG,PRE),
*                           (LO,HO,RES,COIL).Jblnd.(JET), (LO,COIL,HO,RES).Fblnd.FUEL /
;
Set fmap(f,mix,g) /(LN,MN,HN).Rblnd.(REG),(LN,MN,HN).(Pblnd).(PRE)
                           (LO,HO,RES,COIL).Jblnd.(JET), (LO,COIL,HO,RES).Fblnd.FUEL /
;
Table convert(f,rxn,g)
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

Parameter SellPr(prd)
            /PRE 700, REG 600, JET 400, FUEL 350, LOIL 150/
       ;

Table quality(property,f)
            LN      MN  HN  LO   HO  COIL    RES    REG     PRE     JET 
octane      90      80  70                           84     94
vpress                      1   0.6   1.5   0.05                     1.0
;
Positive Variables
    Zmade(f,p)      'Quantity generated from process'
    Zuse(f,p)       'Quantity going into Process'
        ;
Variable Profit
    ;
Zuse.up(cr,p) = 100;
Zmade.fx(cr,p) = 0;

*Zmade.up(f,p) = 100;
*Zuse.up(f,p) = 100;
*Zmade.up(prd,mix)$[not sum(inter,fmap(inter,mix,prd))] =0;
*Zmade.up(inter,mix)$[not sum(g,fmap(g,rxn,prd))] =0;
*
*Zuse.up(inter,mix)$[not sum(prd,fmap(inter,mix,prd))] =0;
*Zuse.up(inter,rxn)$[not sum(g,convert(inter,rxn,g))] =0;


Equation
    conversions(g,p)        'Amount of intermediate (inter(g)) produced by process p , rxn(p)'
    splitbalance(f)

    mixingbal(f,p)
    Qgasoline(property,f)
*    Qjet(property,f)
    obj
    ;


*Zmade.fx(f,p)$(not fmap(,p,f)) =0;

*conversions(inter,rxn(p)).. Zmade(inter,p) =E= sum(f,convert(f,rxn,inter) * Zuse(f,rxn)) ;

conversions(inter(g),rxn(p)).. Zmade(g,rxn) =E= sum(f,convert(f,rxn,g) * Zuse(f,rxn)) ;

splitbalance(inter)..  sum(p, Zmade(inter,p)) =E= sum(p, Zuse(inter,p));

mixingbal(prd,mix(p))$[sum(f,fmap(f,mix,prd))]..   sum(f$fmap(f,mix,prd), Zuse(f,mix) ) =E= Zmade(prd,mix) ;

Qgasoline(property,prd(f))$quality(property,prd)..   sum(mix,Zmade(prd,mix) * quality(property,prd)) =E=
                                                            sum((inter,mix)$[fmap(inter,mix,prd)], Zuse(inter,mix)*quality(property,inter)); 





*mixingbal(prd,mix(p))..   sum(f$fmap(f,mix,prd), Zuse(f,mix) ) =E= Zmade(prd,mix) ;

*Qgasoline(property,prd(f))$quality(property,prd)..   sum((inter,mix)$[fmap(inter,mix,prd)],Zmade(prd,mix) * quality(property,prd)) =E=
*                                                            sum((inter,mix)$[fmap(inter,mix,prd)], Zuse(inter,mix)*quality(property,inter)); 



*Qjet(property,prd(f))$quality(property,prd)..   sum(mix,Zmade(prd,mix) * quality(property,prd)) =G=
*                                                            sum((inter,mix)$[fmap(inter,mix,prd)], Zuse(inter,mix)*quality(property,inter)); 


obj.. Profit =e= sum((prd,mix)$[sum(f,fmap(f,mix,prd))], Zmade(prd,mix) *SellPr(prd)) + Zmade('LOIL','Crckr')* SellPr('LOIL');

model ref /all/;
solve ref using LP max Profit;

