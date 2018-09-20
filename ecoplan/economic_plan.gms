$title Economic Planning , Dynamic Input-Ouput Leontief Model, LP (Leontief, SEQ =xx)
*         *         *         *         *         *         *         *         *
$ontext
This problem is a sample three industry input-output Leontief economic model.
The problem is a dynamic model with optimization for three different goals over
a 5 year period. The model is build for a 10 year period to account for the lag
associated with effects in year 't+2' of a decision taken in year 't' .
Detailed description of the Leontief Model is provided in section 5.2 of the reference.

The good balance equation is

(Industry Output) + existing stock = Input (Endogenous Consumption) + Market demand + New stock

Model Building in Mathematical Programming, Fifth Edition,
H. Paul Williams, Model 12.9 : Economic Planning
Wiley Publication, 2013
$offtext

Sets
    ind     'industry + manpower'           /coal,steel,trans,manpow/
    i(ind)  'industry'                      /coal,steel,trans/
    t       'years under consideration'     /t1*t7/
    dt(t)   'years for decisions'           /t1*t5/  
    ;

Parameters
    Stock(i)       'stock for goods i begining of t=1, [m£]'
                        /coal 150, steel 80, trans 100/
    ICapacity(i)     'Productive Capacity for goods i begining of t=1 , [m£]'
                        /coal 300, steel 350, trans 280/
    Demand(i)      'demand for good i each year [m£] for objective 1'
                        /coal 60, steel 60, trans 30/
    MaxManpower      'Maximum Yearly Manpower Available [m£]' /470/ 
    ;

Alias(i,j);
Alias(t,lt);

Table ProdCoef(ind,i)   'Input of good j for unit increase in output of j'
                coal      steel     trans

coal            0.1       0.5         0.4
steel           0.1       0.1         0.2
trans           0.2       0.1         0.2
Manpow          0.6       0.3         0.2  
    ;


Table CapCoef(ind,i)   'amount of good j for unit increase in production capacity for good i'
                coal      steel     trans

coal                      0.7         0.9
steel           0.1       0.1         0.2
trans           0.2       0.1         0.2
Manpow          0.4       0.2         0.1  
    ;

Positive Variables
    Store(i,t)          'Quantity of good i in storage at begining of time t, [m£]'
    Output(i,t)         'Quantity of output of good i in time t for future use, [m£]'
    Endo(i,t)           'Endogenous Consumption of good i each year,[m£]'
    Exog(i,t)           'Exogenous Consumption of good i each year,[m£]' 
    Capacity(i,t)       'Production Capacity of good i each year, [m£]' 
    ExtraProd(i,t)      'Quantity of extra production capacity desired, [m£]'
    Mpow(t)             'Quantity of manpower, [m£]'
    fstock(i,t)         'Slack Variable for final year goods balance equation, [m£]'
    ;
Variable
    MaxCap              'Objective, Maximum Productive capacity'
    MaxProd             'Objective, Maximum Production t4,t5'
    MaxMan              'Objective, Maximize Manpower Requirement'
    ;
    
*unbounded rays
ExtraProd.fx(i,t)$(ord(t)<3) =0;

*initial capacity
Capacity.fx(i,'t1') = ICapacity(i);

*timehorizon
store.lo(i,t)$(ord(t)>5)= stock(i);
store.fx(i,'t1') = stock(i);

Equations
    StockBal(i,t)      'Balance of good in each time perios'
    Endogenous(i,t)    'Endogenous consumption for production and capacity rise'   
    Manpower(t)        'Manpower consumption each year'
    OutputLim(i,t)     'Max limit on Output'      
    CapacityLim(i,t)   'Calculate new production limits'
    ManPowLim(t)       'Manpower Limit each year'
    ObjMaxCap          'Objective function max Productive Capacity'
    ObjMaxProd         'Objective function max Production t4,t5'
    ObjMaxMan          'Objective function max Manpower requirement'
    ;
    
StockBal(i,t)..        Store(i,t) + Output(i,t) =E= Endo(i,t)  + Exog(i,t) + Store(i,t+1) + fstock(i,t)$(ord(t) =7) ;

Endogenous(i,t)..      Endo(i,t) =E= sum(j, ProdCoef(i,j)* Output(j,t+1)) + sum(j,CapCoef(i,j)*ExtraProd(j,t+2)) ;

Manpower(t)..          MPow(t) =E=sum(j, ProdCoef('ManPow',j) * OutPut(j,t+1) + CapCoef('Manpow',j)* ExtraProd(j,t+2));

OutputLim(i,t)..       Output(i,t) =L= Capacity(i,t);

CapacityLim(i,t+1)..   Capacity(i,t+1) =E= Capacity(i,t) + ExtraProd(i,t+1);

ManPowLim(t)..         Mpow(t) =L= MaxManPower;

ObjMaxCap..            MaxCap =E= sum(i, Capacity(i,'t5') - ICapacity(i));

ObjMaxProd..           MaxProd =E= sum(i, Output(i,'t4') + Output(i,'t5'));

ObjMaxMan..            MaxMan =E= sum(dt(t),Mpow(t));

Model base      'common constraints'     /StockBal,Endogenous,Manpower,OutputLim,CapacityLim/ ;


*fixed demand for model 1
Exog.fx(i,t) =Demand(i);
Model Plan1     'plan 1 : max capacity'  /base, ManPowLim, ObjMaxCap/;
Solve Plan1 using LP maximizing MaxCap;

*ignore exogenous demand for model 2
Exog.fx(i,t) = 0;
Model Plan2     'plan 2 : max production' /base, ManPowLim, ObjMaxProd/;
Solve Plan2 using LP maximizing MaxProd;

*fixed demand for model 1
Exog.fx(i,t) =Demand(i);
Model Plan3     'plan 3 :max manpower requirement'  /base, ObjMaxMan/;    
Solve Plan3 using LP maximizing MaxMan;


$ontext
Note:  The model formulation differs from that of HP William and OPLIDE. Major difference is in form
of the Balance equation, an equality constraint for us and inequality in the references. We use an additional slack variable
to account for the surplus in StockBal(i,'t7') due to absence of t8 from the set time.

Additionally, results are higher for us than HPW and OPLIDE. The cause is rather uncertain, but the model formulation
has been checked several times, and satisfies all constraints. 
$offtext