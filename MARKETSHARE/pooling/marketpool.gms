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

Alias (Retailers, R), (GrCat,G), (Suppliers,S), (Regions,Rg);

Parameter
         NumRet(G)      'Number of retailers in each group'
         Target(S)      'Target distribution' /D1 0.4, D2 0.6/
         TotDPoint      'Total Distribution Points in the market'
         TotSpirit      'Total Spirit Market, [mGallon]'
         TotOil(Rg)     'Total oil market per region, [m,Gallon]'
;

NumRet(G) = sum(R$ RGrps(R,G), 1);
TotDPoint = sum(R, Dpoints(R));
TotSpirit = sum(R, DSpirit(R));
TotOil(Rg) = sum(R$RRegs(R,Rg),Doil(R));

Binary Variables
         RetMap(S,R)             'Mapping for retailers to suppliers , 40-60 in each group'
         ;
Variables
         DisPoint(S)           'Number of distribution points with each supplier'
         SupSpirit(S)          'Spirit Level for each supplier'
         SupOil(S,Rg)          'Oil Level for each supplier in each region'
*         PerCentD              'Objective, Minimum Percentage deviations'
         RetailDev(S,G)        'Deviation , Retailer Allotment per group'
         DistribDev(S)         'Deviation , Distribution Points Allotment'
         SpiritDev(S)          'Deviation , Spirit demand Allotment'
         OilDev(S,Rg)          'Deviation , Oil demand Allotment'
         Feas
*         MaxAbsD             'Maximum Abs Deviation'
         ;

*group ratio 40-60 ratio limits on NRet

Equations
*Equations for retailers 40-60 in each group ( no. 6,7, from Aspect List)
         RetailAssign(G)       'Accounting retailers in each group'
         EnsureRetAssign(R)    'Ensuring each retailer is assigned to one supplier'
         MaxRetailD1(G)        'Max number of reatailers for D1 in each group'
         MinRetailD1(G)        'Min Number of retailers for D1 in each group'
         DevRetailAllot(S,G)     '% Deviations in Alloting Retailers in 40-60 ratio'

*Equations for total distribution points
         CalcDPoints(S)        'Calculating Distribution points for each supplier'
         MaxDPpointsD1         'Maximum Number of Distribution Points'
         MinDPpointsD1         'Minimum Number of Distribution Points'
         TotalDPoint           'Calculating total distribution points'
         DevDPAllot(S)         '% Deviations in Alloting Distribution Points in 40-60 ratio'

*Equations for Spirit Market Control
         CalcSpirit(S)         'Calculating Spirit Market for each supplier'
         MaxSpiritD1           'Maximum spirit market for D1'
         MinSpiritD1           'Minimum spirit market for D1'
         TotalSpirit           'Calculating total distribution points'
         DevSpiritAllot(S)     '% Deviations in Alloting Spirit Market in 40-60 ratio'

*Equations for Oil Market Control for each region
         CalcOil(S,Rg)         'Calculating Oil Market for each supplier in each region'
         MaxOilD1(Rg)          'Maximum spirit market for D1'
         MinOilD1(Rg)          'Minimum spirit market for D1'
         TotalOil(Rg)          'Calculating total distribution points'
         DevOilAllot(S,Rg)     '% Deviations in Alloting Spirit Market in 40-60 ratio'

         ObjFeasibility        'Dummy objective for Feasible solutions'
*         ObjMinDeviation       'Objective Function'
*         ObjMinMaxDevtn(S,Rg)        'Objective Function, Min the Max Deviation'
         ;

RetailAssign(G)..     sum((S,R)$RGrps(R,G), RetMap(S,R)) =E= NumRet(G) ;
EnsureRetAssign(R)..  sum(S,RetMap(S,R)) =E= 1    ;
MaxRetailD1(G)..      sum(R$RGrps(R,G), RetMap('D1',R)) =L= 0.45*NumRet(G) ;
MinRetailD1(G)..      sum(R$RGrps(R,G), RetMap('D1',R)) =G= 0.35*NumRet(G) ;
DevRetailAllot(S,G).. RetailDev(S,G) =E= sum(R$RGrps(R,G),RetMap(S,R))/NumRet(G) - Target(S) ;


CalcDPoints(S)..      DisPoint(S) =E= sum(R, RetMap(S,R) * Dpoints(R)) ;
MaxDPpointsD1..       DisPoint('D1') =L= 0.45*TotDPoint ;
MinDPpointsD1..       DisPoint('D2') =G= 0.35*TotDPoint ;
TotalDPoint ..        sum(S,DisPoint(S)) =E= TotDPoint ;
DevDPAllot(S)..       DistribDev(S) =E= DisPoint(S)/TotDPoint - Target(S) ;


CalcSpirit(S)..       SupSpirit(S) =E= sum(R, RetMap(S,R) * DSpirit(R)) ;
MaxSpiritD1..         SupSpirit('D1') =L= 0.45*TotSpirit ;
MinSpiritD1..         SupSpirit('D2') =G= 0.35*TotSpirit ;
TotalSpirit ..        sum(S,SupSpirit(S)) =E= TotSpirit ;
DevSpiritAllot(S)..   SpiritDev(S) =E= SupSpirit(S)/TotSpirit - Target(S) ;

CalcOil(S,Rg)..       SupOil(S,Rg) =E= sum(R$RRegs(R,Rg), RetMap(S,R) * Doil(R));
MaxOilD1(Rg)..        SupOil('D1',Rg) =L= 0.45*TotOil(Rg);
MinOilD1(Rg)..        SupOil('D1',Rg) =G= 0.35*TotOil(Rg);
TotalOil(Rg)..        sum(S,SupOil(S,Rg)) =E= TotOil(Rg);
DevOilAllot(S,Rg)..   OilDev(S,Rg) =E= SupOil(S,Rg)/TotOil(Rg) - Target(S) ;

objFeasibility..      Feas =E= sum((S,R),RetMap(S,R));
*objMinDeviation..     PerCentD =E=  sum(S,abs(RetailDev(S)) + abs(DistribDev(S)) +
*                                                 abs(SpiritDev(S)) + sum(Rg,abs(OilDev(S,Rg))));
*objMinMaxDevtn(S,Rg)..      MaxAbsD =E= max(abs(RetailDev(S)),abs(DistribDev(S)),
*                                                 abs(SpiritDev(S)), abs(OilDev(S,Rg))) ;

model Market /all/;
Market.optfile =1;

*We create the cplex option file to enable solution pooling
$onecho>cplex.opt
solnpool solnpool.gdx
solnpoolintensity 4
solnpoolpop 2
$offecho


*solve Market using MIP Min PerCentD;
solve Market using MIP Max Feas;

*++++++++++=========================*++++++++++=========================*++++++++++=========================
Set
    soln           'possible solutions'    /file1*file100/
    solnpool(soln) 'actual solutions'
    ;

Scalar cardsoln 'number of solutions in the pool';

Alias(soln,s1,s2) ;

Parameter 
          Assignment(soln,S,R)      'Assignments of R to S in a solution' 
          DevTotDistrib(soln,S)     'Deviation Distribution Points for a solution'
          DevSpiritMarket(Soln,S)   'Deviation in distribution of Spirit Market'
          DevOilRegionD1(Soln,S,Rg) 'Deviation in distribution of Oil in Region R'           
          DevRgroupAD1(Soln,S)      'Deviation, allotment of retailers to D1 in group A'
          DevRgroupBD1(Soln,S)      'Deviation, allotment of retailers to D1 in group B'

          NetDev(soln)              'Total Deviation for the criterias'
          ObjMinDev               'Soln with Minimum Total Deviation'
          BestSol(S,R)
          ;

execute_load 'solnpool.gdx', solnpool =index ;
cardsoln = card(solnpool) ;
display cardsoln;
    ;

loop(solnpool(soln),
    put_utility 'gdxin' /solnpool.te(soln)
    execute_loadpoint;

    Assignment(soln,S,R) = RetMap.l(S,R);
    
    DevTotDistrib(Soln,'D1') = abs(DistribDev.l('D1'));

    DevSpiritMarket(Soln,'D1') = abs(SpiritDev.l('D1'));

    DevOilRegionD1(Soln,'D1',Rg) = abs(OilDev.l('D1',Rg) );

    DevRgroupAD1(Soln,'D1') = abs(RetailDev.l('D1','A'));
    
    DevRgroupBD1(Soln,'D1') = abs(RetailDev.l('D1','B'));
    
    NetDev(Soln) = DevTotDistrib(Soln,'D1') + DevSpiritMarket(Soln,'D1') +DevRgroupAD1(Soln,'D1')
                    +DevRgroupBD1(Soln,'D1')+ sum(Rg,DevOilRegionD1(Soln,'D1',Rg));


    );
*Objective 1, finding soultion with minimum Net deviation
ObjMinDev =1;
loop(solnpool(soln),
        if(NetDev(soln)<ObjMinDev,
            ObjMinDev = NetDev(soln);
            BestSol(S,R) = Assignment(soln,S,R);
           )
    
*    DevRetGroupD1(G) = sum(R$RGrps(R,G),RetMap.l('D1',R))/NumRet(G) - Target('D1');
    );

    
*    D1inA =  sum(R$RGrps(R,'A'),RetMap.l('D1',R))/NumRet('A') - Target('D1');
*    D1inB = sum(R$RGrps(R,'B'),RetMap.l('D1',R))/NumRet('A') - Target('D1');
*    PerDev(soln,S) = abs(RetailDev.l(S)) + abs(DistribDev.l(S)) + abs(SpiritDev.l(S)) + sum(Rg,abs(OilDev.l(S,Rg)));
*    MaxD(soln) = Max( 
*    SRMap(Soln,S,R) = RetMap.l(S,R);

*++++++++++=========================*++++++++++=========================*++++++++++=========================
display Assignment, DevTotDistrib, DevSpiritMarket, DevOilRegionD1, DevRgroupAD1, DevRgroupBD1, NetDev , ObjMinDev,BestSol; 


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

$offtext


