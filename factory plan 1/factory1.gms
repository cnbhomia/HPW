$ontext
This code is for the problem 12.3 from H P William book

$offtext

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

display storage.l, profit.l ; 