$title Refinery Production Strategy (REFINERY, SEQ =xx)
*                                                                                |||
$ontext
The MIP problem determines the operation and production strategy of a mining
company with four mines over a period of five years. The determination includes
decision such as which mines to operate and how much to extract under the
equality and upper production limit constraints. 


Model Building in Mathematical Programming, Fifth Edition,
H. Paul Williams, Model 12.7 : Mining
Wiley Publication, 2013
$offtext


Sets
    mines       'set of mines'      /M1*M4/
    years       'decision years'    /Y1*Y5/
    ;

Parameters
    royalty(mines)      'royalties for each mine when open [£ million /year]'
                            /M1 5, M2 4, M3 4, M4 5/
    prodlim(mines)      'limit on production in each mine [million tons]'
                            /M1 2, M2 2.5, M3 1.3, M4 3/
    orequal(mines)      'ore quality from each mine'
                            /M1 1, M2 0.7, M3 1.5, M4 0.5/
    sellqual(years)     'ore quality desired by market each year'
                            /Y1 0.9, Y2 0.8, Y3 1.2, Y4 0.6, Y5 1/
    ;

Scalar
    SellPr  'Selling price [£/ton]'             /10/
    MaxWrk  'Maximum mines working in a year'   /3/
    drate   'discount rate'                     /0.1/
    ;
Parameter dSellPr(years)   'discounted selling price for each year' ;
dSellPr(years) = SellPr* power[(1-drate),ord(years)-1]


*dSellPr('Y1') = SellPr;
*dSellPr(years)$(ord(years)>1) = SellPr*(1-drate);

Variables
    qmined(mines,years)  'quantity mined each year in a mine [million ton]'
    totore(years)        'total ore sold each year [million tons]'        
    ifopen(mines,years)  'if the mine is open in a given year'
    ifoper(mines,years)  'if the mine was operated in a given year'
    Droyal(mines,years)  'cost from paying royalty each year for open mine'       
    profit               'total profit over five years'
*    dSellPr(years)           'discounted selling price in year y'
    ;

Binary Variables ifopen,ifoper;
Positive Variables qmined(mines,years);

Alias(mines,m);
Alias(years,y);
*ifopen.l(m,y) = 1;
*ifoper.l(m,y) = 1;

$gdxin datafiles.gdx
$load ifopen , ifoper, qmined, totore
$gdxin
ifoper.l('M2','Y3')= 0;
ifoper.l('M2','Y3')= 0;
qmined.l('M1','Y4') = 0.12;
totore.l('Y4') =5.62;

Equations
    MaxMining(m,y)   'Maximum mining for each mine in any year'
    MaxOperate(y)  'Maximum number of mines working year year'
    TotalOre(y)    'total ore mined each year'
    Blending(y)    'Blending of mined ore for final product quality'
    OperCond(m,y)  'Logical constraint, a mine can operate only if it is open'
    OpenCond(m,y)  'Logical constraint, once a mine is close, it cannot be opened again'
    Royalties(m,y)   'Total royalty paid each year'
*    discountrate(y)'calculate discounted rate for each year'
    ObjFunc        'calculation of profit'
    ;


MaxMining(m,y)..    qmined(m,y) =L= prodlim(m)*ifoper(m,y);

MaxOperate(y)..     sum(m,ifoper(m,y)) =L= MaxWrk;

TotalOre(y)..       sum(m, qmined(m,y) ) =E= totore(y);

Blending(y)..       sum[ m,qmined(m,y)*orequal(m)] =E= totore(y) * sellqual(y);

OperCond(m,y)..     ifopen(m,y) - ifoper(m,y) =G= 0;

OpenCond(m,y)..     ifopen(m,y+1) =L= ifopen(m,y) ;

Royalties(m,y)..    Droyal(m,y) =E= ifopen(m,y)* royalty(m)* power[(1-drate),ord(y)-1] ; 

*discountrate(y)..   dSellPr(y) =E= SellPr* power[(1-drate),ord(y)-1] ;

ObjFunc..           profit =E= sum(y, totore(y)*{SellPr* power[(1-drate),ord(y)-1]}) - sum((m,y),ifopen(m,y)* royalty(m)* power[(1-drate),ord(y)-1])  ;


model mining /all/;
option limrow=100;
*option mip =BARON;
solve mining using mip maximizing profit;

*$execute_unload 'datafiles.gdx' , ifopen ;
*$gdxout data
*$unload ifopen ifoper
*$gdxout

display ifopen.l , ifoper.l, qmined.l, totore.l, dSellPr;



























