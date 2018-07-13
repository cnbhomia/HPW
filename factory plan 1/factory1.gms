<<<<<<< HEAD
<<<<<<< HEAD
$ontext
This code is for the problem 12.3 from H P William book

$offtext

=======
>>>>>>> parent of 3be8cad... Merge branch 'master' of https://github.com/cnbhomia/HPW
=======
>>>>>>> parent of 3be8cad... Merge branch 'master' of https://github.com/cnbhomia/HPW
sets
    p 'ps'                  /p1*p7/
    process                 /grinding, vdrill,hdrill,boring,planing/
    mac 'machines'          /G1*G4 , VD1*VD2 , HD1*HD3, borer, planer/
    equipment(process,mac)  /grinding.(G1*G4) , vdrill.(VD1*VD2) ,hdrill.(HD1*HD3), boring.borer , planing.planer /
    month 'months'          /Jan, Feb, Mar, Apr, May, Jun/

    ;

table processtime(process,p)  'time required for each process per unit product'
            p1       p2     p3      p4      p5      p6      p7
grinding   0.5      0.7      0       0      0.3     0.2     0.5
vdrill      0.1     0.2     0       0.3     0       0.6     0
hdrill      0.2       0     0.8     0       0       0       0.6
boring     0.05    0.03            0.07    0.1             0.08
planing                    0.01            0.05            0.05
;

table marketlim(p,month) 'marketing constraints of each product each month'
        Jan     Feb     Mar     Apr     May     Jun
p1      500     600     300     200     0       500
p2      1000    500     600     300     100     500
p3      300     200     0       400     500     100
p4      300     0       0       500     100     300
p5      800     400     500     200     1000    1100
p6      200     300     400     0       300     500
p7      100     150     100     100     0       60
;

table maintain(mac,month) 'maintenance schedule. 0 = downtime'
       Jan  Feb Mar Apr May Jun
G1      0   1   1   1   0   1
G2      1   1   1   1   1   1
G3      1   1   1   1   1   1
G4      1   1   1   1   1   1
VD1     1   1   1   0   0   1
VD2     1   1   1   1   1   1
HD1     1   0   1   1   1   0
HD2     1   0   1   1   1   1
HD3     1   1   1   1   1   1
borer   1   1   0   1   1   1
planer  1   1   1   1   1   0
;

parameter profitcon(p) 'profit contribution of each PROD'
    /   p1   10
        p2   6
        p3   8
        p4   4
        p5   11
        p6   9
        p7   3/;
        
parameter processexists(process,month),storecost;
processexists(process,month) $ [sum(mac$equipment(process,mac), maintain(mac,month))] =1  ;
storecost = 0.5;

variables
    produced(p,month) 'units of ech product produced'
    prodsold(p,month)
    storage(p,month) 'units stored at the end of each month'
    profit
    ;
*variable bounds

positive variable produced(p,month);
prodsold.up(p,month) = marketlim(p,month);

storage.up(p,month)  = 1000;
storage.lo(p,month)  = 0;
storage.fx(p,'Jun') = 50;

equations

    machrslimit(process,month) 'total limit on machine hours of a process of 24*8*2*N per month,N represents total no. of machines available '
    stock(p,month) 'storage balance'
    stockjan(p)
    objfunc
    ;

machrslimit(process,month).. sum(p, produced(p,month)*processtime(process,p)) =l= 384*sum(mac$equipment(process,mac),maintain(mac,month));
* total machine hours under the given process catagories. 28*8*2* (no. of machine avaiable for the process)

stock(p,month)$[ord(month)>1].. storage(p,month) =e= storage(p,month-1) + produced(p,month) - prodsold(p,month);
stockjan(p).. storage(p,'Jan') =e= produced(p,'Jan') - prodsold(p,'Jan');


objfunc.. profit =e= sum((p,month),produced(p,month)*profitcon(p)) - sum((p,month), storage(p,month)*storecost);


model eqchk /all/;
option limrow =100;
solve eqchk using LP maximizing profit;

<<<<<<< HEAD
display storage.l, profit.l ; 
=======
$ontext
This code is for the problem 12.3 from H P William book



sets
=======
>>>>>>> 7e65abad2e7582fdeaa1f88b2b877a42dc1c71cf
    p 'ps' /p1*p7/
    mac 'machines'  /G1*G4, VD1,VD2, HD1*HD3,borer,planer/
    grind(mac)      / G1*G4/
    vdrill(mac)     /VD1,VD2/
    hdrill(mac)     /HD1*HD3/
    bor(mac)        /borer/
    pln(mac)       /planer/
<<<<<<< HEAD
    month 'months' /Jan, Feb, Mar, Apr, May, Jun/
    ;

table time(mac,p)  'time required'
            p1       p2     p3      p4      p5      p6      p7
G1*G4       0.5     0.7     0       0       0.3     0.2     0.5
VD1*VD2     0.1     0.2     0       0.3     0       0.6     0
HD1*HD3     0.2     0       0.8     0       0       0       0.6
borer       0.05    0.03            0.07    0.1             0.08
planer                      0.01            0.05            0.05
;

display time


table avail(mac,month) 'machine availability'
       Jan  Feb Mar Apr May Jun
G1      0   1   1   1   0   1
G2      1   1   1   1   1   1
G3      1   1   1   1   1   1
G4      1   1   1   1   1   1
VD1     1   1   1   0   0   1
VD2     1   1   1   1   1   1
HD1     1   0   1   1   1   0
HD2     1   0   1   1   1   1
HD3     1   1   1   1   1   1
borer   1   1   0   1   1   1
planer  1   1   1   1   1   0
;
table marketing(p,month) 'marketing constraints of each product each month'
        Jan     Feb     Mar     Apr     May     Jun
p1      500     600     300     200     0       500
p2      1000    500     600     300     100     500
p3      300     200     0       400     500     100
p4      300     0       0       500     100     300
p5      800     400     500     200     1000    1100
p6      200     300     400     0       300     500
p7      100     150     100     100     0       60
;


parameter profit(p)
    /   p1   10
        p2   6
        p3   8
        p4   4
        p5   11
        p6   9
        p7   3/;

parameter tgrind(grind,p);
tgrind(grind,p)=time(grind,p);

parameter process(mac,p) 'whether process applies or not';
process(mac,p)$(time(mac,p)) = 1;

parameter storecost 'storage cost /unit / month' /0.5/ ;


variables
    storage(p,month) 'amount to be stored'
    produce(p,month) 'units of ech product produced'
    ;
storage.up(p,month) = 100;
storage.fx(p,'Jun') = 50;

equations
    maclim(mac,month) 'machine usage each month limited to 24*2*8 if available'
    objfunc 'profit calculation equation'
    production (p,month) 'production of p ech month'
    ;

maclim(mac,month).. sum(p, time(mac,p)*avail(mac,month)) =l= 24*2*8 ;

production(p,month).. sum(mac, time(mac,p))*produce(p,month)

objfunc.. profit = sum((month,p),produce(p,month)*profit(p) -storage(p,month)*storecost );


model plan1 /all/;
solve model using LP maximizing profit;
$offtext


=======
    month 'months' /Jan Feb Mar Apr May Jun/;

table time(mac,p)  'time required'
            p1       p2     p3      p4      p5      p6      p7
G1*G4       0.5     0.7     0       0       0.3     0.2     0.5
VD1*VD2     0.1     0.2     0       0.3     0       0.6     0
HD1*HD3     0.2     0       0.8     0       0       0       0.6
borer       0.05    0.03            0.07    0.1             0.08
planer                      0.01            0.05            0.05
;
>>>>>>> 7e65abad2e7582fdeaa1f88b2b877a42dc1c71cf
<<<<<<< HEAD
>>>>>>> parent of 3be8cad... Merge branch 'master' of https://github.com/cnbhomia/HPW
=======
>>>>>>> parent of 3be8cad... Merge branch 'master' of https://github.com/cnbhomia/HPW
