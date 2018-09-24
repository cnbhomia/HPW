$title Market Sharing (MARKETSHARE, SEQ =xx)

$ontext
The model covers distribution of 23 retailers in the market to two suppliers
D1 and D2. Each retailer has access to certain distribution points in three regions,
with respective oil and spirit demand. The distribution is required to be done
in a 40-60 ratio over the distribution points, and oil and spirit demand.
The model is smaller version of market sharing problem faced by British Oil and
Shell,1972.
The data for the model is imported from excel. The model demostrated use of
DataEx Tool GDXXRW, $gdxin and $include feature.

There are two objective functions
1. Minimization of total Deviation
2. Minimization fo Maximum Deviations
LP formulations have been used instead of discontinuous abs(),min() and max() functions

Model Building in Mathematical Programming, Fifth Edition,
H. Paul Williams, Model 12.13 : Market Sharing
Wiley Publication, 2013


$offtext
$include "data_import.gms"

set
         category       'categories for 40-60 split'
                        /TotDP  'Total Distribution Points for each supplier'
                        Spirit  'Overall Spirit Market'
                        OilR1   'Oil Market in Region Ri'
                        OilR2   'Oil Market in Region Ri'
                        OilR3   'Oil Market in Region Ri'
                        RetA    'Retailer in Group A' 
                        RetB    'Retailer in GroupB'/
         DevRet(category)   'Subset, categories for Retailer distribution'
                        /RetA,RetB/
         ;

Alias (Retailers, R), (Grcat,G), (Suppliers,S), (Regions,Rg),(category,cat);

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
         Deviations(cat,S)      'Deviations, variable over all split categories'
         Z(cat)                 'Absolute Deviation in each category'
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
         DevRetailAllot(cat)    '% Deviations in Alloting Retailers in 40-60 ratio'

         
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

         ObjNetDev
         ;


RetailAssign(G)..        sum((S,R)$RGrps(R,G), RetMap(S,R)) =E= NumRet(G) ;
EnsureRetAssign(R)..     sum(S,RetMap(S,R)) =E= 1    ;
MaxRetailD1(G)..         sum(R$RGrps(R,G), RetMap('D1',R)) =L= 0.45*NumRet(G) ;
MinRetailD1(G)..         sum(R$RGrps(R,G), RetMap('D1',R)) =G= 0.35*NumRet(G) ;
DevRetailAllot(devret(cat))..
                         Deviations(devret,'D1') =E= sum(R$RGrps(R,'A'),RetMap('D1',R))/NumRet('A') - Target('D1') ;



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
objNetDev..              NetDev =E= sum((cat,S), Deviations(cat,'D1'));

Model Base /all/;

*============================================================================================================
*Model market constraints for minimum total deviation across the 7 division criterias
*============================================================================================================

Equations
*Equations for absolute functionality                               
         AbsoluteDev1(cat)      'LP Equation for Modulus function, keeping model MIP' 
         AbsoluteDev2(cat)      'LP Equation for Modulus function, keeping model MIP'
         ObjMinTotDev       'Objective Function, Minimum Net Deviation'
         ;
*Minimization constraints
AbsoluteDev1(cat)..      Z(cat) =G= Deviations(cat,'D1');
AbsoluteDev2(cat)..      Z(cat) =G= - Deviations(cat,'D1');
objMinTotDev..           MinTotDev =E= sum(cat,Z(cat));

Model Market1 /Base, AbsoluteDev1,AbsoluteDev2,objMinTotDev/;
solve Market1 using MIP Min MinTotDev;

*============================================================================================================
*Model market constraints for minimum maximum deviation across the 7 division criterias
*============================================================================================================

Variable
    MiniMax 'Minimum Maximum Value'
    ;

Equations
    MiniMaxDev1(cat)    'LP equation for Modulus function, keeping model MIP'
    MinimaxDev2(cat)    'LP equation for Modulus function, keeping model MIP'
    MiniMaxTotDev       'Objective Function, Minimum of Maximum Deviation'
    ;

MiniMaxDev1(cat).. MiniMax =G= Deviations(cat,'D1');
MiniMaxDev2(cat).. MiniMax =G= - Deviations(cat,'D1');
MiniMaxTotDev..    MinTotDev =E= sum(cat,Deviations(cat,'D1'));


model Market2 /Base,MiniMaxDev1, MinimaxDev2, MiniMaxTotDev/ ;
solve Market2 using MIP Min MiniMax;


