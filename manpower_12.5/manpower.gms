$ontext
this model is the manpower planning model from HP WIlliams book, excercise 12.5

$offtext

sets
         year 'years in question' /y0*y3/
         iyear(year) 'initial/existing year' /y0/
         dyear(year) 'decision years' /y1*y3/
         workcat 'work category' /unskill, semskill, skill/
         
         ;

table manpow(year,workcat)  'manpower requirements'
         unskill         semskill        skill
y0       2000            1500            1000
y1       1000            1400            1000
y2       500             2000            1500
y3       0               2500            2000
         ;

parameters
        Cretrain(workcat)   'cost to retrain per worker'        /unskill 400, semskill 500/
        Credund(workcat)       'cost of redundancy per worker'     / unskill 200, semskill 500, skill 500/
        Coverman(workcat)   'cost of overmanning per worker'    / unskill 1500, semskill 2000, skill 3000/
        Cshortt(workcat)    'cost of shorttime worker'          / unskill 500, semskill 400, skill 400/
        Rnewatt(workcat)    'rate of attrition of new workers'  /unskill 0.25, semskill 0.20, skill 0.10 /
        Roldatt(workcat)    'rate of attrition of old workers'  /unskill 0.10, semskill 0.05, skill 0.05 /
        Rdownatt           'rate of attrition of downgraded workers' /0.5/
        RecLim(workcat)     'max recruitment each year in each category' / unskill 500, semskill 800 , skill 500/
        ;
Alias(workcat,wc)

*all calculation checkpoint as begining of a year'
integer variable
         Wrec(year,workcat)   'number of recruits at end of each year'
         Wret(year,workcat)   'number of retrained personnel'
         Wred(year,workcat)   'number of workers declared redundant'
         Wsho(year,workcat)   'number of workers on short work'
         Wextra(year,workcat)       'number of extra workers each year. sum over categories'
         Woverman(year)         'total extra workers each year, up to 150 max'
         Watt(year,workcat)           'number of workers leaving. includes current and past year workers'
*         Wdown(year,workcat,wc) 'number of workers downgraded'
         Wtotal(year,workcat) ' total number of manpower in each category each year'
         ;
variables
         Cret(year)          'Cost of retraining'
         Cred(year)      'Redundancy cost each year'
         Cextra(year)    'extraworker costs each year'
         Csho(year)     'short time worker cost'
         TotCTC               'total cost to company'
         objval         'total number of layoffs / redundancy workers'
         ;

*defining limits on variables
Wret.up(year,'unskill') = 200 ;
Wret.up(year,'semskill') = 0.25*Wret.l(year,'skill') ;

Woverman.up(year) = 150 ;

Wsho.up(year,workcat) = 50;

*Wtotal.lo(year,workcat) = manpow(year,workcat);

Wrec.up(year,workcat) = RecLim(workcat) ; 

equations
        attrition(year,workcat)  'attrition rate equation'
        workers(year,workcat) 'worker each year in each category'
        extramanning(year,workcat) 'extra man each year eachcategory'
        overmanning(year) 'overmanpower each year'
        redundantworkers 'total redundant workers'
        
        retraincosts(year) 'retraining costs each each'
        redundancycosts(year) ' cost of redundancy each year'
        extraworkercosts(year) 'cost of extraworker each year'
        shorttimecosts(year) 'cost of shorttime worker each year'
        totalcosts  'total costs for 3 years'
        
        ;

*values for year 0
Wrec.l(year,workcat) =0;
Wret.l(year,workcat) = 0;
Wred.l(year,workcat) =0 ; 
Wsho.l(year,workcat) =0 ; 
Wextra.l(year,workcat) =0;
Woverman.l(year)   =0 ;
Watt.l(year,workcat)  =0  ;
*Wdown(year,workcat,wc) 'number of workers downgraded'
Wtotal.fx('y0',workcat) = manpow('y0',workcat) ;


attrition(year,workcat)$(not iyear(year)).. Watt(year,workcat) =e= Rnewatt(workcat)*Wrec(year,workcat) + Roldatt(workcat)*Wtotal(year-1,workcat);
*                                                                    + Rdownatt * Wdown(year,workcat) ;

workers(year,workcat)$(ord(year)>1).. Wtotal(year,workcat) =e= Wtotal(year-1,workcat) + Wrec(year,workcat) - Watt(year,workcat) - Wret(year,workcat) + Wret(year,workcat-1) ;

extramanning(dyear,workcat).. Wextra(dyear,workcat) =e= Wtotal(dyear,workcat) - manpow(dyear,workcat) ;

overmanning(dyear).. Woverman(dyear) =e= sum(workcat,Wextra(dyear,workcat)) ;

retraincosts(dyear).. Cret(dyear) =e= sum(workcat, Cretrain(workcat)*Wret(dyear,workcat)) ;

redundancycosts(dyear).. Cred(dyear) =e= sum(workcat, Credund(workcat)*Wred(dyear,workcat));

extraworkercosts(dyear).. Cextra(dyear) =e= sum(workcat, Coverman(workcat)*Wextra(dyear,workcat));

shorttimecosts(dyear).. Csho(dyear) =e= sum(workcat, Cshortt(workcat)* Wsho(dyear,workcat)) ;

totalcosts.. TotCTC =e= sum(year, Cret(year) + Cred(year) + Cextra(year) + Csho(year)) ;

redundantworkers.. objval =e= sum((year,workcat), Wred(year,workcat)) ; 
                                                       
$ontext      
attrition(year,workcat)$(not iyear(year)).. Watt(year,workcat) =e= Rnewatt(workcat)*Wrec(year,workcat) + Roldatt(workcat)*Wtotal(year-1,workcat)
                                                                    + Rdownatt * Wred(year,workcat) ;

workers(year,workcat).. Wtotal(year,workcat) =e= Wtotal(year-1,workcat) + Wrec(year,workcat) - Watt(year,workcat) +0.5*Wsho(year,workcat) - Wret(year,workcat+1) + Wdown(year,workcat+2) + Wdown(year,workcat+1) -Wdown(year,workcat-1) - Wdown(year,workcat-2) ;

extramanning(dyear,workcat).. Wextra(dyear,workcat) =e= Wtotal(dyear,workcat) - manpow(dyear,workcat) ;

overmanning(dyear).. Woverman(dyear) =e= sum(workcat,Wextra(dyear,workcat)) ;

retraincosts(dyear).. Cret(dyear) =e= sum(workcat, Cretrain(workcat)*Wret(dyear,workcat)) ;

redundancycosts(dyear).. Cred(dyear) =e= sum(workcat, Credund(workcat)*Wred(dyear,workcat));

extraworkercosts(dyear).. Cextra(dyear) =e= sum(workcat, Coverman(workcat)*Wextra(dyear,workcat));

shorttimecosts(dyear).. Csho(dyear) =e= sum(workcat, Cshortt(workcat)* Wsho(dyear,workcat)) ;

totalcosts.. TotCTC =e= sum(year, Cret(year) + Cred(year) + Cextra(year) + Csho(year)) ;

redundantworkers.. objval =e= sum((year,workcat), Wred(year,workcat)) ; 

$ontext
totalmanpower(year)$(not year('y0')).. TotMan(year) =e= sum(workcat,Wtotal(year,workcat));

manpower(year,workcat).. Wtotal(year+1,workcat) =  Wtotal(year,workcat) + Wrec(year,workcat) - Wred(year-1,workcat) - Watt(year) ) ;

overmanning(year).. Woverman(year) =e= [TotMan(year) - sum(workcat,manpow(year,workcat))]$ [TotMan(year) > sum(workcat,manpow(year,workcat))] ;
attrition(year)..   Watt(year) =e= TotMan(year-1)           
        
$offtext

model manpowerplan /all/ ;
option limrow = 100;
solve manpowerplan using RMIP minimizing objval ; 