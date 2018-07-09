$ontext
following is the model from HP Williams book.
Focus is oil blennding, production, selling strategy. Model title is Food Manufacture 1
$offtext

sets
    Oil 'oils' /veg1,veg2,oil1*oil3/
    veg(oil) /veg1,veg2/
    nonveg(oil)/oil1*oil3/
    mon 'mons in planning' / Jan,Feb, Mar, Apr,May, June, July/
    ;
alias (oil,i);

table price(mon,oil) 'cost price of veg oil in the future'
      veg1      veg2    oil1    oil2    oil3
jan     110     120     130     110     115
feb     130     130     110     90      115
mar     110     140     130     100     95
apr     120     110     120     120     125
may     100     120     150     110     105
june    90      100     140     80      135
july   
;

parameters
      hardness(Oil) 'hardness of veg oils'
      / veg1    8.8
        veg2    6.1
        oil1    2.0
        oil2    4.2
        oil3    5.0/

      cost_storage 'storage cost $/tonn' /5.0/

      ProdLimVeg /200/
      ProdLimNVeg /250/
      sellprice ' selling price of product ' /150/;
      ;
*Defining storage limitations
positive variable
        storage(oil,mon) ' amount of oil stored each mon';
        storage.up(oil,mon) = 1000;
        storage.fx(oil,'Jan')= 500;
        storage.fx(oil,'june')= 500;

*variables declaration
positive Variables
        rawmat(oil,mon) 'amount of each oil purchased each mon tonn/mon'
        rawmatused(oil,mon) 'amount of raw mat used each mon'
        product(mon) 'amount of blended product made and sold'
        spec 'hardness spec in product' /lo 3 , up 6/
        ;
variable    profit 'objective variable';

equations
    massbalance(mon) 'material mabance equation each mon'
    storecalc(oil,mon) 'storage calculation'    
    prodLimitVeg(mon) 'production limit equations'
    prodLimitNVeg(mon) 'production limit equations'
    hardnessup(mon) 'hardness limitation on product'
    hardnesslow(mon) 'hardness limitation on product'
    cost ' cost of production'
    ;

storecalc(oil,mon).. storage(oil,mon+1) =e= storage(oil,mon) + rawmat(oil,mon) - rawmatused(oil,mon) ;
massbalance(mon).. sum(oil,rawmatused(oil,mon)) =e= product(mon);
hardnessup(mon).. sum(oil, hardness(oil)*rawmatused(oil,mon))-6*product(mon) =l=0 ;
hardnesslow(mon).. sum(oil, hardness(oil)*rawmatused(oil,mon))-3*product(mon) =g=0 ;
prodLimitVeg(mon).. sum(oil$veg(oil),rawmatused(oil,mon)) =l= ProdLimVeg;
prodLimitNVeg(mon).. sum(oil$nonveg(oil),rawmatused(oil,mon)) =l= ProdLimNVeg;

cost.. profit =e= sum((oil,mon), sellprice*product(mon) - rawmat(oil,mon)*price(mon,oil) - storage(oil,mon)*cost_storage)    ;

model food1 /all/;
option limrow=100
solve food1 using LP maximizing profit;


      

   
        