sets
         flu 'all fluids in the inventory' /C1,C2,LN,MN,HN,LO,HO,RES,RGAS,COIL,CGAS,LOIL,REG,PRE,JET,FO/
         sell(flu) / PRE,REG,JET,FO,LOIL/
         crude(flu) /C1,C2/
         proddis(flu) 'products of distillation' /LN,MN,HN,LO,HO,RES/
         naptha(flu) 'napthas' /LN,MN,HN/
         oils(flu) /LO, HO/
         rawcrack(flu) /LO,HO,RES/
         prodcrack(flu) /COIL,CGAS,LOIL/
         oper 'operations in the refinery' / DIS, REF ,CRACK/
         prodref(flu) 'product of reforming' /RGAS/
         petrol(flu) 'petrols' /REG,PRE/
         price(sell)/ PRE 700, REG 600, JET 400, FO 350,LOIL 150/
         ;
parameters
         cap(oper) 'capacity of operation' /DIS 45000, REF 10000, CRACK 8000/
         yieldref(naptha) 'conversion reforming'/ LN 0.6, MN 0.52, HN 0.45/
         octane(flu) /LN 90, MN 80 , HN 70, RGAS 115, CGAS 105/
         vpress(flu) /LO 1.0 , HO 0.6, COIL 1.5 , RES 0.05/
         ;
         
table yieldcrack(rawcrack,prodcrack)
    COIL    CGAS    LOIL
LO  0.68    0.28
HO  0.75    0.2
RES                 0.5
;

table DISRAT(crude,proddis)
         LN      MN      HN      LO      HO      RES
C1       0.1     0.2     0.2     0.12    0.2     0.13
C2       0.15    0.25    0.18    0.08    0.19    0.12
;

positive variable frac1(flu) 'fraction of product going into blending from distialltion';
positive variable frac2(flu) 'fraction of product going into blending from other opers';
positive variable frac3(flu) 'fraction of product going into blending from other opers';
frac1.up(flu) = 1;
frac1.fx('COIL') = 0;

frac2.up(flu) = 1;
frac3.up(flu) = 1;
frac3.l(naptha) =0.5;

variable
         flow(flu)           'mass/barrel of each stream'
         DWASTE
         petoctane(petrol)  'octane number of petrols'
         jetpress           'vapor pressure of jet fuel'
         profit
         ;
flow.up(flu)$(not crude(flu)) =500000;
flow.up('C1')  = 20000;
flow.up('C2') = 30000;
flow.lo('LOIL') = 500 ;
flow.up('LOIL') = 1000;

petoctane.lo('REG') =84;
petoctane.up('REG') =94;
petoctane.lo('PRE') =94;
positive variable jetpress /l 0.7/;

equation
         disprod(proddis) 'calculate flowrates of distillation products'
         dislimit 'capacity limit on distillation'
         reforming 'mass balance for reforming'
         reflimit 'limit on reforming'
         cracking(prodcrack) 'mass balances in cracking'
         cracklimit 'limit on cracking'
*        petrolblend(flu) 'blending of petrol'
         jetblend  'blending of jet fuel'
         fuelblend  'blending of fuel oil'
         market 'profit calc equation'
         petrolblendREG
         petrolblendPRE
         gasolineproduction;
         ;


*variable initializations
frac1.l(flu) =0.5;
frac2.l(flu) =0.5;
frac3.l(flu) =0.5;

*distillation equations
disprod(proddis).. flow(proddis) =e= flow('C1')*DISRAT('C1',proddis) +  flow('C2')*DISRAT('C2',proddis) ;

dislimit..      sum(crude,flow(crude)) =l= cap("DIS");

*reforming
reforming..     flow('RGAS') =e= sum(naptha,(1-frac1(naptha))*flow(naptha)*yieldref(naptha));

reflimit..      sum(naptha,(1-frac1(naptha))*flow(naptha)) =l= cap('REF') ;

*cracking
cracking(prodcrack).. flow(prodcrack) =e= sum(rawcrack,(1-frac1(rawcrack))*flow(rawcrack)*yieldcrack(rawcrack,prodcrack));

cracklimit.. sum(oils,(1-frac1(oils))*flow(oils))=l= cap('CRACK');

*petrol blend

petrolblendREG..  flow('REG')*petoctane('REG')  =e=  sum(naptha,flow(naptha)*octane(naptha)*frac1(naptha)*frac3(naptha)) + flow('RGAS')*octane('RGAS')*frac3('RGAS')
                                                                                +  flow('CGAS')*octane('CGAS')*frac3('RGAS') ;
petrolblendPRE..  flow('PRE')*petoctane('PRE')  =e=  sum(naptha,flow(naptha)*octane(naptha)*frac1(naptha)*(1-frac3(naptha))) +
                                                                flow('RGAS')*octane('RGAS')*(1-frac3('RGAS')) +  flow('CGAS')*octane('CGAS')*(1-frac3('RGAS')) ;
                                                                                
*jetfuel blend

jetblend.. flow('JET')*jetpress =e= sum(oils,flow(oils)*frac1(oils)*(1-frac2(oils))*vpress(oils)) + flow('COIL')*vpress('COIL')*(1-frac2('COIL'))
                                                + flow('RES')*vpress('RES')*frac1('RES')*(1-frac2('RES'));

*fueloil blend

fuelblend..    10* flow('LO')*frac1('LO')*frac2('LO') + 4*flow('COIL')*frac2('COIL') + 3*flow('HO')*frac1('HO')*frac2('HO')
                                                        + flow('RES')*frac1('RES')*frac2('RES') =e= 18* flow('FO') ;                                            

*profit
market.. profit =e= sum(sell,flow(sell)*price(sell));

* minimum premium production
gasolineproduction.. flow('PRE') =g= 0.4*flow('REG') ;

model refinery /all/;
option limrow =50;

solve refinery using NLP maximizing profit;

