$title Farm Planning (REFINERY, SEQ =xx)

$ontext


Model Building in Mathematical Programming, Fifth Edition,
H. Paul Williams, Model 12.8 : Farm Planning
Wiley Publication, 2013
$offtext

Sets
    Cows    'different categories of cows' /heifer , milkcow/
    Feed    'feedstock for milkcow'        /grain , beet/
    Group   'Group of land for grain'      /G1*G4/
    Years   'Total years '              /Y0*Y5/
    DYears  'Decision years'            /Y1*Y5/
    ;

Scalars
    MaxHerd     'Max herd size'                /130/
    MaxArea     'Max size of land'             /200/
    BirthRate   'New calves each year per cow' /1.1/
    Ybeet       'Yield for growing sugar beet [ton/acre]'    /1.5/
    RevMilk      'annual milk selling revenue[£/cow]'           /370/  
    ;

Parameters
    grazing(cows)   'grazing/support area by cows'
                    /heifer 0.66 , milkcow 1/
    Ygrain(group)   'Yield of grain per group'
                    /G1 1.1, G2 0.9, G3 0.8, G4 0.65/
    Agrain(group)   'Max area utilization in each group'
                    /G1 20, G2 30,G3 20,G4 10/
    CostPr(Feed)    'Cost of purchasing feed [£/ton]'
                    /grain 90, beet 70/
    SellPr(Feed)    'Cost of purchasing feed [£/ton]'
                    /grain 75, beet 58/
    Eat(cows,feed)  'Feed requirement by each milking cow'
                    /milkcow.grain 0.6 , milkcow.beet 0.7/

    ;
Alias(years,y);
Alias(Cows,c);

Integer Variables
    TotNum(c,years)         'Total number of heifer and milking cows each year'
    TotHerd(years)          'Total animals in the heard'
    ExtraCows(y)        'Extra cows more than the MaxHerd Limit'
    Calves(y)           'Number of calves born eah year'
    sellbull(y)         'Number of Bullocks sold each year'
    babyheif(y)         'Number of heifers kept each year'   
    sellheif(y)         'Number of heifers sold each year'
    oldcowsold(y)       'old milking cow sold each year. Minimum 1'
    ;

Positive Variables
    eaten(feed,y)       'Amount of feedstock (grain and sugarbeet) consumed each year'
    produced(feed,y)    'Amount of feedstock produced each year'
    purchased(feed,y)   'Amount of feedstock purchased each year'
    feedsold(feed,y)    'Amount of feedstock sold each year'
    Abeet(y)            'Area for growing sugar beet ecah year'
    TotCost(y)          'Total cost incurred each year'
    TotSell(y)          'Total revenue made each year'
    ;
Variable Profit         'Cumulative profit for 5 years'
    ;

*year zero initializations
TotNum.fx('heifer','Y0') = 20;
TotNum.fx('milkcow','Y0') =100;


oldcowsold.lo(y) =1 ;
Abeet.lo(y) = 120 ;
Equations
    totalherd(y)        'Total herd population each year'
*    extraherd(y)        'Extra cows calculation for accomodation'
    newborns(y)         'Number of new borns each year'      
    sellbulls(y)        'Number of new bulloks each year for selling'
    newheifs(y)         'Number of new heifers each year for selling'      
    milkcount(c,y)      'Calculate number of milking cows'
    heifcount(c,y)      'Calculate number of heifers cows'

    foodneed(feed,y)    'Amount of grain/sugarbeet needed each year'
    feedbal(Feed,y)     'Quantity/mass Balance of feedstock'
    area4grow(y)        'Area Balance for growing feedstock'
    area4roam(y)        'Area balance for cow roaming'
    grow1(Feed,y)       'quantity of sugar beet produced'
    grow2(Feed,y)       'quantity of grain produced'
    expenses(y)         'expenses incurred each year'
    revenue(y)          'revenue generated each year'
    ObjFunc             'Objective function, 5 year cumulative profit'
    ;


totalherd(y)..      sum(c,TotNum(c,y)) =E= TotHerd(y) ;
*extraherd(y)$[TotHerd(y) > MaxHerd]..         Extracows(y) =E= TotHerd(y) - MaxHerd ;
newborns(y)..       Calves(y+1) =E= TotNum('milkcow',y)*BirthRate;
sellbulls(y)..      sellbull(y) =E= 0.5*Calves(y) ;
newheifs(y)..       babyheif(y) + sellheif(y) =E= 0.5*Calves(y) ;
milkcount(c,y)..    ToTNum('milkcow',y+1) =E= ToTNum('milkcow',y)+ ToTNum('heifer',y-1) -oldcowsold(y) ;
heifcount(c,y)..    ToTNum('heifer',y+1) =E= ToTNum('heifer',y) + babyheif(y) - ToTNum('heifer',y-1);

foodneed(feed,y)..  eaten(feed,y) =E= sum(c, Eat(c,feed)*TotNum(c,y)) ;
feedbal(Feed,y)..   produced(Feed,y) + purchased(Feed,y) =E= eaten(Feed,y) +feedsold(Feed,y);
area4grow(y)..      sum(group, Agrain(group)) + Abeet(y) =L= MaxArea ;
area4roam(y)..      sum(c,TotNum(c,y)*grazing(c)) =L= MaxArea ;
grow1(Feed,y)..     produced('beet',y) =E= Abeet(y) * Ybeet ;
grow2(Feed,y)..     produced('grain',y) =E= sum(group,Agrain(group)*Ygrain(group));

expenses(y)..       TotCost(y) =E= sum(feed, purchased(feed,y)* CostPr(Feed)) ;
revenue(y)..        TotSell(y) =E= sum(feed, feedsold(feed,y)* SellPr(Feed)) +RevMilk * TotNum('milkcow',y)
                                        +120*oldcowsold(y) + sellbull(y)*30;

ObjFunc..            Profit =E= sum(y , TotSell(y) - TotCost(y) );

model farm /all/;

solve farm Maximizing Profit using rMIP;









