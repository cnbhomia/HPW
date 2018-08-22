$title Farm Planning (FARM PLANNING, SEQ =xx)

$ontext
The model addresses the planning of farm activities over a period of 5 years.
The goal is to maximize profit over constraints of herd size, feed requirements
of the herd, land available for growing the feed and labor constraints.

Additionally, the model also covers loan/capital outlay repayments taken in the
five years over 10 years from the year of issue. 

Model Building in Mathematical Programming, Fifth Edition,
H. Paul Williams, Model 12.8 : Farm Planning
Wiley Publication, 2013
$offtext

Sets
    Cows                'different categories of cows'      /heifer , milkcow/
    Feed                'types of feedstock for milkcow'    /grain , beet/
    Group               'Group of land for grain'           /G1*G4/
    Years               'Decision years'                    /Y0*Y5/
    Age                 'Age of cows'                       /0*12/
    ;

Scalars
    BirthRate           'Rate of Birth each year'                       /1.1/
    MaxArea             'Max size of land [acre]'                       /200/
    Ysbeet              'Yield for growing sugar beet [ton/acre]'       /1.5/
    CapOut              'Capital for extra cattle (>130) [£/cow]'       /200/
    ;

Parameters
    GrazAr(cows)        'grazing/support area needed by cows[acre/cow]'
                        /heifer 0.666667 , milkcow 1/
    Ygrain(group)       'Yield of grain per group of land [ton/acre]'
                        /G1 1.1, G2 0.9, G3 0.8, G4 0.65/
    ArGrMx(group)       'Max area utilization for growing grain in each group[acre]'
                        /G1 20, G2 30,G3 20,G4 10/
    Diet(cows,feed)     'Feed requirement by each milking cow [ton/year]'
                        /milkcow.grain 0.6 , milkcow.beet 0.7/
    LabCow(cows)        'Labor hours required for herding cows, [hr/year]'
                        /milkcow 42, heifer 10/
    LabFeed(feed)       'Labor hours for Feed growing , [hr/year]'
                        /grain 4, beet 14/
    CostPr(feed)        'Cost price of buying feed [£/ton]'
                        /grain 90, beet 70/
    SellPr(feed)        'Sell price of extra feed produced [£/ton]'
                        /grain 75, beet 58/
    MiscCow(cows)       'Miscelleneous/other cost for cows [£/year]'
                        /heifer 50, milkcow 100/
    MiscFeed(feed)       'Miscelleneous/other cost growing feed [£/acre/year]'
                        /grain 15, beet 10/
    ;

Alias(Years,yr,CapYr)
Alias(Feed,f);
Alias(Group,g);
Alias(Age,a);
Alias(cows,c);

Positive Variables

    NewBorns(yr)        'number of NewBorns each year, Age 0'
    CowCount(a,yr)      'number of cows of age a per year'
    BullSold(yr)        'number of bulls sold'
    HeifSold(yr)        'number of heifers sold'
    
    ExtraCows(yr)       'over population, >130 each year'
    OldCow(yr)          'number of old cows Age 12, sold '
    HerdSize(yr)        'total size of the herd each year'

    Ar4Gr(g,yr)         'Area allotted for growing grain each year [acre/year]'
    Ar4Sb(yr)           'Area allotted for growing sugarbeet each year[acre/year]'
    fgrow(f,yr)         'Amount of feed grown each year [ton/year]'
    fneed(f,yr)         'Amount of feed needed each year [ton/year]'
    fbuy(f,yr)          'Amount of feed bought each year [ton/year]'
    fsold(f,yr)         'Amount of feed sold each year [ton/year]'
    
    ExtraLabor(yr)      'Extra Labor beyond  5500 hr/year, [hours/year]'
    
    LaborCost(yr)       'Total cost for labor [£/year]'

    OtherCost(yr)       'Total other expenses [£/year]'

    Revenue(yr)         'Total Revenue generated [£/year]'
    Expense(yr)         'Total Expense each year [£/year]'

    Profit(yr)          'Profit each year' 
    ;

Variables
    Profit(yr)          'Total profit [£/year]'
    NetProfit           'Net profit over 5 years, with future loan repayments'
    ;
Positive Variables
    Pop(cows,yr)        'population of cow each year'
    ;


*initial population of cows, year Y0
CowCount.fx(Age,'Y0')$[ord(Age)<13]= 10;
CowCount.fx('12','Y0') = 0;

*Limits and constraints
herdsize.up('Y5') = 1.75 * 100 ;
herdsize.lo('Y5') = 0.5 * 100 ;
Ar4Gr.up(g,yr) = ArGrMx(g) ;

ExtraCows.l(yr) = 10;

Equations
    Births(yr)              'calculating NewBorns each year'
    SellingBulls (yr)       'calculating BullSold(yr)'
    HeiferBal1(yr)          'calculating heifers kept in the herd after birth'
    HeiferBal2(yr)          'Heifers Age 0  to Age 1'
    HeiferBal3(yr)          'Heifers Age 1  to Age 2'
    MilkCowBal(Age,yr)      'Milking cows continuity, Age 3  to Age 12'
    Totalherd(yr)           'Herd size calculation'
    populae1(cows,yr)       'calculating total heifers in herd each year'
    populae2(cows,yr)       'calculating total milking cows in herd each year'
    SellCow(yr)             'Selling cows of Age 12'
*    grazing(yr)             'land area constraint for animal roaming'
    growing(yr)             'land area constraint for feed growing'
    grainproduce(yr)        'amount of grain produced'
    beetproduce(yr)         'amount of sugar beet produced'
    FeedNeed(f,yr)          'amount of Feed required by cows'
    FeedBal(f,yr)           'feed balance equation'
    Labor1(yr)              'net labour hours calculation'
    Labor2(yr)              'calculating yearly labor cost'
    MiscCosts(yr)           'calculating Misc/other costs'
    OverPopulae(yr)         'calculate number fo extra cows'
    Income(yr)              'Net income each year'
    Expenditure(yr)         'Net expenditure each year'
    ProfitPerYr(yr)         'yearly profit calculation'
    ObjFunc                 'profit over 5 years'
    ;

*continuity equations

Births(yr)$(ord(yr)>1)..           NewBorns(yr) =E= 1.1 * Pop('milkcow',yr) ;

SellingBulls(yr)$(ord(yr)>1)..     BullSold(yr) =E= 0.5 * NewBorns(yr);

HeiferBal1(yr)$(ord(yr)>1)..       CowCount('0',yr) =E= 0.5 * NewBorns(yr) - heifsold(yr) ;

HeiferBal2(yr)$(ord(yr)>1)..       CowCount('1',yr) =E= 0.95 * CowCount('0',yr-1) ;

HeiferBal3(yr)$(ord(yr)>1)..       CowCount('2',yr) =E= 0.95 * CowCount('1',yr-1) ;

MilkCowBal(a,yr)$[ord(a)>3 and ord(yr)>1]..      CowCount(a,yr)=E=0.98 * CowCount(a-1,yr-1) ;

populae1(cows,yr)$(ord(cows)=1) .. Pop(cows,yr) =E= CowCount('0',yr) + CowCount('1',yr) ;

populae2(cows,yr)$(ord(cows)=2) .. Pop(cows,yr) =E= sum(a$[ord(a)>2 and ord(a)<13] ,CowCount(a,yr)) ;

totalherd(yr) ..                   herdsize(yr) =E= sum(c, Pop(c,yr));

SellCow(yr)..                      oldcow(yr) =E= CowCount('12',yr) ;

*growing and grazing area calculations
*grazing(yr)..                      sum(cows,Pop(cows,yr)*grazAr(cows)) =L= MaxArea;

growing(yr)..                      Ar4Sb(yr) + sum(g,Ar4Gr(g,yr)) + sum(cows,Pop(cows,yr)*grazAr(cows)) =L= MaxArea;

*Feed production
grainproduce(yr)..                 fgrow('grain',yr) =E= sum(g, Ar4Gr(g,yr)*Ygrain(g));

beetproduce(yr)..                  fgrow('beet',yr) =E= Ar4Sb(yr) * Ysbeet ;

Feedneed(f,yr)..                   fneed(f,yr) =E= sum(c, Pop(c,yr)* Diet(c,f));

Feedbal(f,yr)..                    fgrow(f,yr) + fbuy(f,yr) =E= fneed(f,yr) + fsold(f,yr);

Labor1(yr)..                       sum(cows, Pop(cows,yr)*LabCow(cows))
                                                               + sum(f, fgrow(f,yr)*LabFeed(f))  =L= 5500 + extraLabor(yr) ;

Labor2(yr)..                       LaborCost(yr) =E= 4000 + extraLabor(yr) * 1.2 ;

MiscCosts(yr)..                    OtherCost(yr) =E= sum(c, pop(c,yr) * MiscCow(c)) + Ar4Sb(yr)*MiscFeed('beet')
                                                                +  sum(g,Ar4Gr(g,yr))*MiscFeed('grain') ;

OverPopulae(yr)..                  sum(cows,Pop(cows,yr)) =L= 130 + sum(CapYr $(ord(CapYr)>1 and {ord(CapYr) <=ord(yr)}),ExtraCows(CapYr))  ;

Income(yr)..                       Revenue(yr) =E= 370 * pop('milkcow',yr) + sum(f, fsold(f,yr)*SellPr(f))
                                                                    + 30 * bullsold(yr) + 40*heifsold(yr) +120 * oldcow(yr) ;

Expenditure(yr)..                  Expense(yr) =E= LaborCost(yr) +  sum(f, fbuy(f,yr)*CostPr(f)) + OtherCost(yr);

ProfitPerYr(yr)$(ord(yr)>1)..      Profit(yr) =E= Revenue(yr) - Expense(yr) - 39.71* sum(CapYr $[ord(CapYr)>1 and
                                                                ord(CapYr)<= ord(yr)],ExtraCows(CapYr)) ;

ObjFunc..                           NetProfit =E= sum(yr$(ord(yr)>1),Profit(yr)) - 39.71* sum(yr$(ord(yr)>1), (4 + ord(yr)-1)*ExtraCows(Yr));


Profit.l('Y1') = 21906 ;
Profit.l('Y2') = 21888 ;
Profit.l('Y3') = 25816 ;
Profit.l('Y4') = 26826 ;
Profit.l('Y5') = 25283 ;


model farm /all/;
option limrow =100, limcol=20;




solve farm maximizing NetProfit using LP;


display NewBorns.l,Pop.l, oldcow.l,bullsold.l,heifsold.l,extracows.l,herdsize.l;






















    