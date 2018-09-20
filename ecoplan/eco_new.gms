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

ObjMaxMan..            MaxMan =E= sum(dt(t), Mpow(t));

Model base      'common constraints'     /StockBal,Endogenous,Manpower,OutputLim,CapacityLim/ ;

$ontext
*fixed demand for model 1
Exog.fx(i,t) =Demand(i);
Model Plan1     'plan 1 : max capacity'  /base, ManPowLim, ObjMaxCap/;
Solve Plan1 using LP maximizing MaxCap;
$offtext

*ignore exogenous demand for model 2
*Exog.fx(i,t) = 0;
*Model Plan2     'plan 2 : max production' /base, ManPowLim, ObjMaxProd/;
*Solve Plan2 using LP maximizing MaxProd;

*fixed demand for model 3
Exog.fx(i,t) = Demand(i);
Model Plan3     'plan 3 :max manpower requirement'  /base, ObjMaxMan/;    
Solve Plan3 using LP maximizing MaxMan;


parameters
  outRep(i,t,*)
  ;
outRep(i,t,'stock bop') = store.L(i,t);
outRep(i,t,'output') = Output.L(i,t);
outRep(i,t,'Production') = sum(j, ProdCoef(i,j)* Output.l(j,t+1));
outRep(i,t,'upcap') = sum(j,CapCoef(i,j)*ExtraProd.l(j,t+2)) ;
outRep(i,t,'extraprod') = ExtraProd.l(i,t);
outRep(i,t,'capacity') = capacity.l(i,t) ; 
outRep(i,t,'eop') = outRep(i,t,'stock bop') + outRep(i,t,'output') - outRep(i,t,'Production')  - outRep(i,t,'upcap');



display outRep;


