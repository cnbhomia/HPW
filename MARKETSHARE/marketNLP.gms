$title Market Sharing (MARKET, SEQ =xx)

$ontext
The model covers distribution of 23 retailers in the market to two suppliers
D1 and D2. Each retailer has access to certain distribution points in three regions,
with respective oil and spirit demand. The distribution is required to be done
in a 40-60 ratio over the distribution points, and oil and spirit demand.
The model is smaller version of market sharing problem faced by British Oil and
Shell,1972.
The data for the model is imported from excel. The model demostrated use of
DataEx Tool GDXXRW, $gdxin and $include feature.

Model Building in Mathematical Programming, Fifth Edition,
H. Paul Williams, Model 12.13 : Market Sharing
Wiley Publication, 2013
$offtext

$include "data_import.gms"

set
         Category       'Categories for 40-60 split'
                        /TotDP  'Total Distribution Points for each supplier'
                        Spirit  'Overall Spirit Market'
                        OilR1   'Oil Market in Region Ri'
                        OilR2   'Oil Market in Region Ri'
                        OilR3   'Oil Market in Region Ri'
                        RetA    'Retailer in Group A' 
                        RetB    'Retailer in GroupB'/
         DevRet(Category)    /RetA,RetB/
         ;

Alias (Retailers, R), (GrCat,G), (Suppliers,S), (Regions,Rg),(Category,Cat);

Parameter
         NumRet(G)      'Number of retailers in each group'
         Target(S)      'Target distribution' /D1 0.4, D2 0.6/
         TotDPoint      'Total Distribution Points in the market'
         TotSpirit      'Total Spirit Market, [10^6 Gallon]'
         TotOil(Rg)     'Total oil market per region, [10^6 Gallon]'
         
;

NumRet(G) = sum(R$ RGrps(R,G), 1);
TotDPoint = sum(R, Dpoints(R));
TotSpirit = sum(R, DSpirit(R));
TotOil(Rg)= sum(R$RRegs(R,Rg),Doil(R));

Binary Variables
         RetMap(S,R)            'Mapping for retailers to suppliers , 40-60 in each group'
         ;                      
Variables                       
         DisPoint(S)            'Number of distribution points with each supplier'
         SupSpirit(S)           'Spirit Level for each supplier [10^6 Gallon]'
         SupOil(S,Rg)           'Oil Level for each supplier in each region [10^6 Gallon]'
         Deviations(Cat,S)      'Deviations, variable over all split categories'
         Z(Cat)                 'Absolute Deviation in each category'
         MinTotDev              'Minimum Total Deviation'
         NetDev
         ;

*group ratio 40-60 ratio limits on NRet

Equations
*Equations for retailers 40-60 in each group ( no. 6,7, from Aspect List)
         RetailAssign(G)        'Accounting retailers in each group'
         EnsureRetAssign(R)     'Ensuring each retailer is assigned to one supplier'
         MaxRetailD1(G)         'Max number of reatailers for D1 in each group'
         MinRetailD1(G)         'Min Number of retailers for D1 in each group'
         DevRetailAllotA(cat,S) '% Deviations in Alloting Retailers in 40-60 ratio'
*         DevRetailAllotB(cat,S) '% Deviations in Alloting Retailers in 40-60 ratio'
         
*Equations for total distribution points
         CalcDPoints(S)         'Calculating Distribution points for each supplier'
         MaxDPpointsD1          'Maximum Number of Distribution Points'
         MinDPpointsD1          'Minimum Number of Distribution Points'
         TotalDPoint            'Calculating total distribution points'
         DevDPAllot             '% Deviations in Alloting Distribution Points in 40-60 ratio'

*Equations for Spirit Market Control
         CalcSpirit(S)          'Calculating Spirit Market for each supplier'
         MaxSpiritD1            'Maximum spirit market for D1'
         MinSpiritD1            'Minimum spirit market for D1'
         TotalSpirit            'Calculating total distribution points'
         DevSpiritAllot         '% Deviations in Alloting Spirit Market in 40-60 ratio in group A'
        
*Equations for Oil Market Control for each region
         CalcOil(S,Rg)          'Calculating Oil Market for each supplier in each region'
         MaxOilD1(Rg)           'Maximum spirit market for D1'
         MinOilD1(Rg)           'Minimum spirit market for D1'
         TotalOil(Rg)           'Calculating total distribution points'
         DevOilAllotR1          '% Deviations in Alloting Spirit Market in 40-60 ratio'
         DevOilAllotR2          '% Deviations in Alloting Spirit Market in 40-60 ratio'
         DevOilAllotR3          '% Deviations in Alloting Spirit Market in 40-60 ratio'

*         ObjNetDev1
         ObjNetDev2
         ;


RetailAssign(G)..        sum((S,R)$RGrps(R,G), RetMap(S,R)) =E= NumRet(G) ;
EnsureRetAssign(R)..     sum(S,RetMap(S,R)) =E= 1    ;
MaxRetailD1(G)..         sum(R$RGrps(R,G), RetMap('D1',R)) =L= 0.45*NumRet(G) ;
MinRetailD1(G)..         sum(R$RGrps(R,G), RetMap('D1',R)) =G= 0.35*NumRet(G) ;
DevRetailAllotA(devret(cat),s)$(ord(S)<2).. Deviations(devret,'D1') =E= sum(R$RGrps(R,'A'),RetMap(S,R))/NumRet('A') - Target('D1') ;
*DevRetailAllotA(cat,s)$..        Deviations('RetA','D1') =E= sum(R$RGrps(R,'A'),RetMap(S,R))/NumRet('A') - Target('D1') ;
*DevRetailAllotB(cat,s)$..        Deviations('RetB','D1') =E= sum(R$RGrps(R,'B'),RetMap(S,R))/NumRet('B') - Target('D1') ;


CalcDPoints(S)..         DisPoint(S) =E= sum(R, RetMap(S,R) * Dpoints(R)) ;
MaxDPpointsD1..          DisPoint('D1') =L= 0.45*TotDPoint ;
MinDPpointsD1..          DisPoint('D1') =G= 0.35*TotDPoint ;
TotalDPoint ..           sum(S,DisPoint(S)) =E= TotDPoint ;
DevDPAllot..             Deviations('TotDP','D1') =E= DisPoint('D1')/TotDPoint - Target('D1') ;
                         
                         
CalcSpirit(S)..          SupSpirit(S) =E= sum(R, RetMap(S,R) * DSpirit(R)) ;
MaxSpiritD1..            SupSpirit('D1') =L= 0.45*TotSpirit ;
MinSpiritD1..            SupSpirit('D2') =G= 0.35*TotSpirit ;
TotalSpirit ..           sum(S,SupSpirit(S)) =E= TotSpirit ;
DevSpiritAllot..         Deviations('Spirit','D1') =E= SupSpirit('D1')/TotSpirit - Target('D1') ;
                         
                         
CalcOil(S,Rg)..          SupOil(S,Rg) =E= sum(R$RRegs(R,Rg), RetMap(S,R) * Doil(R));
MaxOilD1(Rg)..           SupOil('D1',Rg) =L= 0.45*TotOil(Rg);
MinOilD1(Rg)..           SupOil('D1',Rg) =G= 0.35*TotOil(Rg);
TotalOil(Rg)..           sum(S,SupOil(S,Rg)) =E= TotOil(Rg);
DevOilAllotR1..          Deviations('OilR1','D1') =E= SupOil('D1','R1')/TotOil('R1') - Target('D1') ;
DevOilAllotR2..          Deviations('OilR2','D1') =E= SupOil('D1','R2')/TotOil('R2') - Target('D1') ;
DevOilAllotR3..          Deviations('OilR3','D1') =E= SupOil('D1','R3')/TotOil('R3') - Target('D1') ;
*objNetDev1..             NetDev =E= sum((cat,S), abs(Deviations(cat,'D1')));
objNetDev2..             NetDev =E= max( abs(Deviations('RetA','D1')),abs(Deviations('RetB','D1')),abs(Deviations('TotDP','D1')),
                                        abs(Deviations('Spirit','D1')),abs(Deviations('OilR1','D1')),abs(Deviations('OilR2','D1')),
                                        abs(Deviations('OilR3','D1')) );

Model Base /all/;

solve base using MINLP min netdev;
$ontext
Equations
*Equations for absolute functionality                               
         AbsoluteDev1(Cat)      'LP Equation for Modulus function, keeping model MIP' 
         AbsoluteDev2(Cat)      'LP Equation for Modulus function, keeping model MIP'
         ObjMinDeviation        'Objective Function, Minimum Net Deviation'
         ;
*Min constraints
AbsoluteDev1(Cat)..      Z(Cat) =G= Deviations(Cat,'D1');
AbsoluteDev2(Cat)..      Z(Cat) =G= - Deviations(Cat,'D1');
objMinDeviation..        MinTotDev =E= sum(Cat,Z(Cat));

Model Market /Base, AbsoluteDev1,AbsoluteDev2,objMinDeviation/;

solve Market using MIP Min MinTotDev;
display RetMap.l;
display Deviations.l;


Variable MiniMax,Z1(cat);

Equations MiniMaxDev1(cat), MinimaxDev2(cat), objminimaxLO,  objminimaxEQ(cat);

MiniMaxDev1(cat).. Z1(cat) =L= Deviations(Cat,'D1');
MiniMaxDev2(cat).. Z1(Cat) =L= - Deviations(Cat,'D1');

objMiniMaxLO..  MiniMax =G= sum(Cat,Z1(Cat));
objMiniMaxEQ(cat).. MiniMax =L= Z1(Cat);

model Market2 /Base,MiniMaxDev1, MinimaxDev2, objminimaxLO,  objMinimaxEQ/ ;
solve market2 using MIP Max MiniMax; 
display RetMap.l;
display Deviations.l;

$offtext

$ontext
parameter output(*),output1(*,*);

Output('Total D1 in A') = sum(R$RGrps(R,'A'),RetMap.l('D1',R) )  ;
Output('Total D1 in B') = sum(R$RGrps(R,'B'),RetMap.l('D1',R) ) ;
Output('Total D2 in A') = sum(R$RGrps(R,'A'),RetMap.l('D2',R) );
Output('Total D2 in B') = sum(R$RGrps(R,'B'),RetMap.l('D2',R) );
OutPut('Fraction of retailers in D1') = DisPoint.l('D1') / TotDPoint;
OutPut('Fraction of retailers in D2') = DisPoint.l('D2') / TotDPoint;

OutPut('Fraction of Spirit market in D1') = SupSpirit.l('D1') / TotSpirit;
OutPut('Fraction of Spirit market in D2') = SupSpirit.l('D2') / TotSpirit;


OutPut1('Fraction of Oil market in D1',Rg) = SupOil.l('D1',Rg) / TotOil(Rg);
OutPut1('Fraction of Spirit market in D2',Rg) = SupOil.l('D2',Rg) / TotOil(Rg);

display output,output1,TotOil;
display RetMap.l;
$offtext
