$ontext
this model is the manpower planning model from HP WIlliams book, excercise 12.5

$offtext

sets
        y 'years in question' /y0*y3/
        yd(y) ' decision years' /y1*y3/
        sk 'skill level' /s1*s3/
        ;
Alias(sk,skp);

table manpow(y,sk)  'manpower requirements'
          s1       s2         s3
y0       2000     1500       1000
y1       1000     1400       1000
y2       500      2000       1500
y3       0        2500       2000
;

parameters
        Cretain(sk)   'cost to retrain per worker'        /s1 400, s2 500/
        Credund(sk)       'cost of redundancy per worker'     / s1 200, s2 500, s3 500/
        Cover(sk)   'cost of overmanning per worker'    / s1 1500, s2 2000, s3 3000/
        Cshortt(sk)    'cost of shorttime worker'          / s1 500, s2 400, s3 400/
        Rnewatt(sk)    'rate of attrition of new workers'  /s1 0.25, s2 0.20, s3 0.10 /
        Roldatt(sk)    'rate of attrition of old workers'  /s1 0.10, s2 0.05, s3 0.05 /
        Rdownatt           'rate of attrition of downgraded workers' /0.5/
        RecLim(sk)     'max recruitment each year in each category' / s1 500, s2 800 , s3 500/
        ;

integer variable
         Wrec(y,sk)   'number of recruits at end of each year'
         Wret(y,sk)   'number of retrained personnel'
         Wred(y,sk)   'number of workers declared redundant'
         Wsho(y,sk)   'number of workers on short work'
         Wextra(y,sk)       'number of extra workers each year. sum over categories'
*         Woverman(y)         'total extra workers each year, up to 150 max'
         Watt(y,sk)           'number of workers leaving. includes current and past year workers'
         Wdown(y,sk,skp) 'number of workers downgraded'
         Wtot(y,sk) ' total number of manpower in each category each year'
        ;

variables
         Cret(y)          'Cost of retraining'
         Cred(y)      'Redundancy cost each year'
         Cextra(y)    'extraworker costs each year'
         Csho(y)     'short time worker cost'
         TotCTC               'total cost to company'
         objval         'total number of layoffs / redundancy workers'
         ;

equations
        total(y,sk) 'total workers each year per skill level'
        attrition(y,sk) 'attrition each year per skill level'
        overman(y,sk)  'number of extra workers per year per skill level'
        retrainlim(y,sk)   'retrainlim equations'
        retraincosts(y) 'cost to retrain'
        overmancosts(y) 'cost of overmanning'
        redundancycosts(y) 'cost of redundancy'
        shorttimecosts(y)
        totalcosts  'total costs for 3 years'
        objfunc 'cumulative redundancy minimization'
        ;

         ;
Wtot.lo(y,sk) = manpow(y,sk) ;
Wtot.up(y,sk)= manpow(y,sk) + 150 ;
Wtot.fx('y0',sk) = manpow('y0',sk) ;

*Limit of extra workers Wextra.up(y,sk) is indirectly taken care of  through Wextra

Wrec.lo(y,sk) = 0;
Wrec.up(y,sk) = Reclim(sk);



Wret.up(y,'s1') = 200;
Wret.fx(y,'s3') = 0;
Wret.lo(y,sk) =0 ;

*y0 variables
Wrec.fx('y0',sk) =0   ;
Wret.fx('y0',sk) =0   ;
Wred.fx('y0',sk) =0   ;
Wdown.fx('y0',skp,sk) =0 ;


Wred.lo(y,sk) = 0;

*TotCTC.up = 6E6;
$ontext
$offtext


total(y,sk)$(ord(y)>1).. Wtot(y,sk) =e= Wtot(y-1,sk) + Wrec(y,sk) - Wred(y,sk)- Watt(y,sk) + [Wret(y,sk-1) - Wret(y,sk)]
                                        + { sum(skp$(ord(skp) > ord(sk)),Wdown(y,skp,sk)) -sum(skp$(ord(skp)<ord(sk)),Wdown(y,sk,skp))}   ;

attrition(y,sk).. Watt(y,sk) =e= Rnewatt(sk)*Wrec(y,sk) + Roldatt(sk)*Wtot(y-1,sk) + 0.5*[sum(skp$(ord(skp) > ord(sk)),Wdown(y,skp,sk))]    ;

overman(y,sk).. Wextra(y,sk) +  0.5*Wsho(y,sk) =e= Wtot(y,sk) - manpow(y,sk) ;

retrainlim(y,sk).. Wret(y,'s2') =l= 0.25* Wtot(y,'s3') ;

retraincosts(y).. Cret(y) =e= sum(sk, Cretain(sk)*Wret(y,sk)) ;

redundancycosts(y).. Cred(y) =e= sum(sk, Credund(sk)*Wred(y,sk));

overmancosts(y).. Cextra(y) =e= sum(sk, Cover(sk)*Wextra(y,sk));

shorttimecosts(y).. Csho(y) =e= sum(sk, Cshortt(sk)* Wsho(y,sk)) ;      

totalcosts.. TotCTC =e= sum(y, Cret(y) + Cred(y) + Cextra(y) + Csho(y) ) ;

objfunc.. objval =e= sum((y,sk), Wred(y,sk)) ;


      
model manpowerplan /all/ ;
option limrow = 100,limcol=100;
option intVarup =2;
option optcr=0;
solve manpowerplan using RMIP minimizing objval ;

solve manpowerplan using MIP minimizing objval;


solve manpowerplan using RMIP minimizing TotCTC ;


