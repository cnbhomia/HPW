$ontext
This code is for the problem 12.3 from H P William book

$offtext


sets
    p 'ps'                  /p1*p7/
    process                 /grinding, vdrill,hdrill,boring,planing/
    gprocess(process)       /grinding/              
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

parameter profitcon(p) 'profit contribution of each PROD'
    /   p1   10
        p2   6
        p3   8
        p4   4
        p5   11
        p6   9
        p7   3/;

parameter storecost /0.5/;

variables
    produced(p,month) 'units of ech product produced'
    prodsold(p,month)
    maccount(process,month) 'number of machines active for a process in a month'
    storage(p,month) 'units stored at the end of each month'
    profit
    ;
*variable bounds

integer variable avail(mac,month) ;
avail.up(mac,month) = 1;


positive variable produced(p,month);
prodsold.up(p,month) = marketlim(p,month);

storage.up(p,month)  = 100;
storage.lo(p,month)  = 0;
storage.fx(p,'Jun') = 50;

equations

    machrslimit(process,month) 'total limit on machine hours of a process of 24*8*2*N per month,N (maccount) represents total no. of machines available '
    stock(p,month) 'storage balance'
    stockjan(p) 'storage balance for jan'
    macactive(process,month)  'calclating active machines for each process each month'
    objfunc

    nonGschedule(process,mac) ' Maintenance of machines atleast once in 6 month'
    Gschedule 'Maintenance of 2 grinders in 6 months'
    ;
macactive(process,month).. maccount(process,month) =e= sum(mac$equipment(process,mac),avail(mac,month)) ;
machrslimit(process,month).. sum(p, produced(p,month)*processtime(process,p)) =l= 384*maccount(process,month);
* total machine hours under the given process catagories. 28*8*2* (no. of machine avaiable for the process)

stock(p,month)$[ord(month)>1].. storage(p,month) =e= storage(p,month-1) + produced(p,month) - prodsold(p,month);
stockjan(p).. storage(p,'Jan') =e= produced(p,'Jan') - prodsold(p,'Jan');

objfunc.. profit =e= sum((p,month),prodsold(p,month)*profitcon(p)) - sum((p,month), storage(p,month))*storecost;


nonGschedule(equipment(process,mac))$[[not gprocess(process)]].. sum(month, avail(mac,month)) =e= 5;
Gschedule .. sum((equipment(gprocess,mac),month),avail(mac,month)) =e= 22;

*maintenance2 .. sum((gprocess,mac,month)$[equipment(gprocess,mac)],avail(mac,month)) =e= 22;

*maintenance1(mac,process)$[equipment(process,mac)$[ord(process)>1]].. sum(month, avail(mac,month)) =e= 5;
*maintenance2(process)$(ord(process)=1).. sum((mac,month)$[equipment(process,mac)],avail(mac,month)) =e= 22;

model eqchk /all/;
option limrow =100;

eqchk.optcr=0;
solve eqchk using MIP maximizing profit;

display storage.l, profit.l ;
display produced.l, prodsold.l, avail.l;