$title Tariff Rate for Power Generation (TARIFF, Seq =xxx)

$ontext

The problem focus on planning use of generators in power stations to
meet the variable demand based on time of the day. The decision variables
vary over use of three types of generators. Objective is to find the optimum
utilization plan (min operating cost) considering under the constraints of
min/max production ccapacity for each type of generator and generation capacity
to fulfill upto 15% higher demand that normal.

Model Building in Mathematical Programming,Fifth Edition, H. Paul Williams,
Model 12.15 : Tariff Rate 
Wiley Publication, 2013

$offtext

Sets
    t   'time periods'      /t1*t5/
    g   'generator type'    /g1*g3/
    ;

Parameters
    Demand(t)  'Demand in each time period, [kMW]'
                /t1 15, g2 30, g3 25, g4 40, g5 27/
    MinLev(g)  'Minimum generation level, [MW]'
                /g1 850 , g2 1250, g3 1500/
    MaxLev(g)  'Maximum generation level, [MW]'
                /g1 2000 , g2 1750, g3 4000/
    Navail(g)  'Num of generators in each type'
                /g1 12, g2 10, g3 5/
    hrs(t)     'Hours in each time period, [hr]'
                /t1 6, t2 3, t3 6, t4 3, t5 6/
    CostMin(g) 'Cost of operation at min level [$/hr]'
                /g1 1000, g2 1750, g3 4000/
    Cost(g)    'Cost of operation above min Level [$/hr/MW]'
                /g1 2, g2 1.3, g3 3000/
    start(g)   'start up cost, [$]'
                /g1 2000, g2 1000, g3 500/
    ;

Scalar  margin    'reserve capacity '   /0.15/
    ;

Variable
    Nuse(t,g)
    ;

Equation

