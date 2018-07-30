$ontext
following is the model from HP Williams book.
Focus is oil blennding, production, selling strategy. Model title is Food Manufacture 1
$offtext

sets
    Oil 'oils' /veg1,veg2,oil1*oil3/
    veg(oil) /veg1,veg2/
    nonveg(oil)/oil1*oil3/
    month 'mons in planning' / Jan,Feb, Mar, Apr,May, June/
    ;
* hellooo dlkahgkjahgklrah


table price(month,oil) 'cost price of veg oil in the future'
      veg1      veg2    oil1    oil2    oil3
jan     110     120     130     110     115
feb     130     130     110     90      115
mar     110     140     130     100     95
apr     120     110     120     120     125
may     100     120     150     110     105
june    90      100     140     80      135
;

parameters
    hardness(Oil) 'hardness of veg oils'
    / veg1    8.8
    veg2    6.1
    oil1    2.0
    oil2    4.2
    oil3    5.0/

    storecost 'storage cost $/tonn' /5.0/
    RefineLimVeg /200/
    RefineLimNVeg /250/
    sellprice ' selling price of product ' /150/
    ;

positive variables
    RMpur(oil,month) ' amount of oil purchased each month'
    RMused(oil,month) ' amount of oil used each month'
    RMstock(oil,month) 'amount of oil in stock at the begining of each month'
    product(month) 'amount of final product each month'
    ;
variable
    profit 'profit overall'
    ;
*fixing stocks
RMstock.fx(oil,'Jan') = 500;
RMstock.up(oil,month) = 1000;


equations
    stockcalc(oil,month) 'stock calculation'
    matbalance(month) 'material balance each month'
    hardnessup(month) ' hardness less than 6'
    hardnesslow(month) ' hardness more than 3'
    refiningLimVeg(month) 'refining limit of each month for veg oil'
    refiningLimNVeg(month) 'refining limit of each month for nonveg oil'
    profitcalc 'profit equation';


stockcalc(oil,month).. RMstock(oil,month++1) =e= RMstock(oil,month) + RMpur(oil,month) - RMused(oil,month) ;

matbalance(month).. product(month) =e= sum(oil, RMused(oil,month));

hardnessup(month).. sum(oil,RMused(oil,month)*hardness(oil)) - 6*product(month) =l=0 ;

hardnesslow(month).. sum(oil,RMused(oil,month)*hardness(oil)) - 3*product(month) =g=0 ;

refiningLimVeg(month).. sum(oil$veg(oil), RMused(oil,month)) =l= RefineLimVeg ;

refiningLimNVeg(month).. sum(oil$nonveg(oil), RMused(oil,month)) =l= RefineLimNVeg ;

profitcalc.. profit =e= sum(month,product(month)*sellprice) - sum((oil,month), RMpur(oil,month)*price(month,oil)) - sum((oil,month),RMstock(oil,month)*storecost);


model food1 /all/;
*option limrow=100
solve food1 using LP maximizing profit;



