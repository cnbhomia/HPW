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
    Dyears  'Decision years'            /Y1*Y5/
    Age     'Age of the cows'           
    
    ;

Scalars
    BirthRate               /1.1/
    MaxArea     'Max size of land'             /200/
    Ysbeet      'Yield for growing sugar beet [ton/acre]'    /1.5/    
    ;

Parameters
    grazAr(cows)   'grazing/support area by cows'
                    /heifer 0.66 , milkcow 1/
    Ygrain(group)   'Yield of grain per group'
                    /G1 1.1, G2 0.9, G3 0.8, G4 0.65/
    ArGrMx(group)   'Max area utilization for growing grain in each group'
                    /G1 20, G2 30,G3 20,G4 10/
    Diet(cows,feed) 'Feed requirement by each milking cow'
                    /milkcow.grain 0.6 , milkcow.beet 0.7/
    LabCow(cows)   'Labor hours required for cows, [hr/year]'
                    /milkcow 42, heifer 10/
    LabFoo(feed)  'Labor hours for food growing , [hr/year]'
                    /grain 4, beet 14/
    CostPr(feed)    'Cost price of buying feed [£/ton]'
                    /grain 90, beet 70/
    SellPr(feed)    'Sell price of extra feed produced [£/ton]'
                    /grain 75, beet 58/
    MiscCow(cows)   'Miscelleneous/other cost for cows [£/year]'
                    /heifer 50, milkcow 100/
    MiscFoo(feed)   'Miscelleneous/other cost growing feed [£/acre/year]'
                    /grain 15, beet 10/
    ;

Alias(years,y);
Alias(feed,f);
Alias(Group,g);
Alias(cows,c);


Variables
    pop(c,y)
    calves(y)      'Number of calves born each year'
    heifkept(y)    'Number of heifers kept each year'
    heifsold(y)    'Number of heifers sold each year'
    bullsold(y)    'Number of Bullocks sold each year'
    cowsold(y)     'old cows sold each year'
    Ar4Gr(g,y)      'Area allotted for growing grain each year'
    Ar4Sb(y)        'Area allotted for growing sugarbeet each year'
    fgrow(f,y)      'Amount of feed grown each year'
    fneed(f,y)      'Amount of feed needed each year'
    fbuy(f,y)       'Amount of feed bought each year'
    fsold(f,y)      'Amount of feed sold each year'
    LaborReq(y)   'Total yearly labor required for cattle and farming'
    LaborCost(y)
    LaborPenalty(y)
    OtherCost(y)
    AccPenalty(y)
    Revenue(y)
    Expense(y)
    Profit
    ;

*limit on area for growing grain
Ar4Gr.UP(g,y) = ArGrMx(g);


Equations
    births(y)   'calculating new births each year'
    heifpop(y)  'heifer population balance'
    milkpop(y)  'milking cows population balance'
    heifbal(y)
    bullSel(y)

    grazing(y)  'land area limitation for animal roaming'


    growing(y)  'land area limitation for feed growing'

    grainproduce(y)
    beetproduce(y)
    foodneed(c,y,f)  'amount of food required by cows'
    foodbal(f,y)    'feed balance equation'

    laborhour(y)
    
    Labor1(y)
    Labor2(y)
    Misc(y)


    
    Accomodatn(y)
    Income(y)
    Expenditure(y)
    ObjFunc


    ;

*Population balance    
births(y)..     calves(y) =E= pop('milkcow',y-1)*BirthRate;
heifpop(y)..    pop('heifer',y) =E= pop('heifer',y-1) + heifkept(y);
milkpop(y)..    pop('milkcow',y) =E= pop('milkcow',y-1) + pop('heifer',y-2);
heifbal(y)..    heifkept(y) + heifsold(y) =E= 0.5 * calves(y);
bullSel(y)..    bullsold(y) =E= 0.5* calves(y) ;

*growing and grazing area calculations
grazing(y)..    sum(c,pop(c,y)*grazAr(c)) =L= MaxArea;
growing(y)..    Ar4Sb(y) + sum(g,Ar4Gr(g,y)) =L= MaxArea;

*food production
grainproduce(y)..   fgrow('grain',y) =E= sum(g, Ar4Gr(g,y)*Ygrain(g));
beetproduce(y)..    fgrow('beet',y) =E= Ar4sb(y) * Ysbeet ;
foodneed(c,y,f)..   fneed(f,y) =E= pop(c,y)* diet(c,f);
foodbal(f,y)..      fgrow(f,y) + fbuy(f,y) =E= fneed(f,y) + fsold(f,y);
laborhour(y)..      LaborReq(y) =E= sum(c, pop(c,y)*LabCow(c)) + sum(f, fgrow(f,y)*LabFoo(f)) ;

Labor1(y).. LaborPenalty(y) =E= 1.2 *(LaborReq(y) - 5500) ;
Labor2(y).. LaborCost(y) =E= 4000 + LaborPenalty(y) ;
Misc(y).. OtherCost(y) =E= sum(c, pop(c,y) * MiscCow(c)) + Ar4SB(y)*10 +  sum(g,Ar4Gr(g,y))*15 ; 

 
Accomodatn(y).. AccPenalty(y) =E= 200 * [sum(c,pop(c,y)) -130] ;

Income(y).. Revenue(y) =E= 370 * pop('milkcow',y) + sum(f, fsold(f,y)*SellPr(f)) + 30 * bullsold(y) + 40*heifsold(y) +120 * oldcow(y) ;

Expenditure(y).. Expense(y) =E= LaborCost(y) + AccPenalty(y) +  sum(f, fbuy(f,y)*CostPr(f)) + OtherCost(y);

ObjFunc.. Profit =E= sum(y, Revenue(y) - Expense(y));


model farm /all/;

solve farm maximizing Profit using RMIP;













       