$title Economic Planning , Dynamic Input-Ouput Leontief Model, LP (Leontief, SEQ =xx)
*         *         *         *         *         *         *         *         *
$ontext
This problem is a sample three industry input-output Leontief economic model.
The problem is a dynamic model with optimization for three different goals over
a 5 year period. The model is build for a 10 year period to account for the lag
associated with effects in year 't+2' of a decision taken in year 't' .
Detailed description of the Leontief Model is provided in section 5.2 of the reference.

The good balance equation is

(Output) + existing stock >= (Input back into Eco) + market demand + new stock

Model Building in Mathematical Programming, Fifth Edition,
H. Paul Williams, Model 12.9 : Economic Planning
Wiley Publication, 2013
$offtext

Sets
    i       'industries in economy'     /coal,steel,transport/
    t       'years under consideration' /1*7/
    dt(t)   'decision years'            /1*5/
    ;

Parameters
    Stock(i)       'stock for goods i in year 0[m£]'
                        /coal 150, steel 80, transport 100/
    LimCapacity(i)     'Productive Capacity for goods i in year 0 , [m£]'
                        /coal 300, steel 350, transport 280/
    ProdManPow(i)    'manpower required for unit quantity of good i'
                        /coal 0.6, steel 0.3, transport 0.2/
    UpCapManPow(i)  'manpower required for increase in capacity for good i'
                        /coal 0.4, steel 0.2, transport 0.1/
    Demand(i)      'demand for good i each year [m£] for objective 1'
                        /coal 60, steel 60, transport 30/
    LimManpower      'Maximum Yearly Manpower Available [m£]' /470/ 
    ;

Alias(i,j);
Alias(t,lt);

Table InOutCoef(i,j)   'Input of good j for unit increase in output of j'
                coal      steel     transport

coal            0.1       0.5         0.4
steel           0.1       0.1         0.2
transport       0.2       0.1         0.2
    ;


Table UpCapCoef(i,j)   'amount of good j for unit increase in production capacity for good i'
                coal      steel     transport

coal                      0.7         0.9
steel           0.1       0.1         0.2
transport       0.2       0.1         0.2
    ;


Positive Variables
    Output(i,t)
    Input(i,t)      'input back into the economy for production [m£/year]'
    UpCap(i,t)      'input back into the economy for productive capacity, [m£/year]'
    x(i,t)          'quantity of output marked for endogenour consumption [m£/year]'
    y(i,t)          'quantity of input marked for increasing capacity [m£/year]'
    store(i,t)      'good i stored in year t [m£]'
    capacity(i,t)   'Production capacity of good i in year t'
    
    ;

store.up(i,t) = 4000;



Variables
    Target         'Objective for maximizing productive capacity'
    ;
*year 0 values 

*variables which are zero
y.fx(i,'1')=0;
y.fx(i,'2')=0;

*fixed values for time horizon t>5th year
upcap.fx(i,t)$(ord(t)>6) =0;
*store.fx(i,t)$(ord(t) >6) = stock(i);

Equations
    GoodsBalanceYr0(i)
    GoodsBalance(i,t)
*    In4Output(i,t)       'Economic Input for output calculation'
*    In4UpCap(i,t)        'Economic Input for rising productive capacity'
    horizonstore1(i)
     horizonstore2(i)
    LimCapCalc(i,t)     'Limit of Productive Capacity Calculation'
    LimOutput(i,t)      'Limit for total output'
    ManpowerCap(t)      'Yearly Manpower Capacity'
    objFunc1            'First Objective for maximizing production capacity'
    
    ;

GoodsBalanceYr0(i)..     Stock(i) =E= sum(j,InOutCoef(i,j)*x(j,'1')) + sum(j,UpCapCoef(i,j)*y(j,'2')) + Store(i,'1');

GoodsBalance(i,t)$dt(t)..     Output(i,t) + Store(i,t) =E= sum(j,InOutCoef(i,j)*x(j,t+1)) +
                                                    sum(j,UpCapCoef(i,j)*y(j,t+2)) + Store(i,t+1);

horizonstore1(i)..       Store(i,'6') =E= Store(i,'7');
horizonstore2(i)..       Store(i,'5') =E= Store(i,'6');

LimCapCalc(i,t)$(dt(t))..    Capacity(i,t) =E= LimCapacity(i) + sum(lt $ [ord(lt)<=ord(t)], y(i,lt)) ;

LimOutput(i,t)$(dt(t))..        Output(i,t) =L= capacity(i,t) ;

ManpowerCap(t)..     sum(i, ProdManPow(i)*x(i,t+1)) + sum(i, UpCapManPow(i)*y(i,t+2)) =L= LimManpower ;

objFunc1..           Target =E= sum(i, x(i,'4') + x(i,'5')) ;

$ontext
upcap.fx(i,t)$[ord(t) <= 3] =0;

inout(i,t)$[(ord(t)>1) and (ord(t)<7)]..   x(i,t) +store(i,t-1) =E= sum(j,InOutCoef(i,j)*x(j,t+1)) + sum(j,UpCapCoef(i,j)*upcap(j,t+2)) + demand(i) + store(i,t);

ProdLimit(i,t)$(ord(t)>1)..   x(i,t) =L= LimCapacity(i) + sum(lt$ {[ord(lt)<ord(t)]}, upcap(i,lt)) ;

objFunc1..                    BestCap =E= sum[(i,dt), upcap(i,dt)] ;

ManpowerCap(dt)..        sum(i, ProdManPow(i)*x(i,dt)) + sum(i, UpCapManPow(i)*upcap(i,dt)) =L= MaxManPow ;

capdata(i,t)$(ord(t)>1)..          capacity(i,t) =E= LimCapacity(i) + sum(lt${[ord(lt)<ord(t)]}, upcap(i,lt)) ;

$ontext
Endogenous(i,t)$..   x(i,t) =E=  sum(j, InOutCoef(i,j) * x(j,t-1) ) ;

Capacity(i,t)$(ord(t)>3)..     upcap(i,t) =E= sum(j, UpCapCoef(i,j)* x(j,t-2));

balance(i,t)..                 store(i,t) =E= store(i,t-1) + x(i,t) - demand(i) ;

ProdLimit(i,t)..               x(i,t) =L= LimCapacity(i) + sum(lt$ {[ord(lt)<ord(t)] and [ord(lt)<6]}, upcap(i,t)) ;

objFunc1..                     BestCap =E= sum[(i,t)$(ord(t)<7), upcap(i,t)] ;

*ManpowerCap(t)..    sum(i, ProdManPow(i)*x(i,t)) + sum(i, UpCapManPow(i)*upcap(i,t)) =L= MaxManPow ; 
$offtext

model ecoplan /all/;

solve ecoplan using LP maximizing Target ; 

display output.l, x.l,y.l,store.l;











    