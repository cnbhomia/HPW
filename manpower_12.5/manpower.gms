$ontext

This multiperiod problem COmpares two different strategies for laying-off employees
under dynamic ManPower requirement. One strategy focuses on miminum lay-offs (redundancy)
without concern to cost of retaining employees,while other focuses on minimizing Costs
without concern for number of employees laid-off

Each year, following decisions are made across three categories of workers
1. Recruitment
2. Retraining and Downgrading
3. Redundacy
4. overmanning
5. Transfer from full time to short-time 

Model Building in Mathematical Programming,Fifth Edition, H. Paul Williams,
Model 12.5 : ManPower Planning
Wiley Publication, 2013

$offtext

Sets
        Years               'years/time horizon'    /Y0*Y3/
        DYears(years)       'decision years'        /Y1*Y3/
        SkillCat            'skill category'        /S1*S3/
        ;

Table Manpower(years,SkillCat)   'Estimated manpower requirements in future'
          S1       S2         S3
Y0       2000     1500       1000
Y1       1000     1400       1000
Y2        500     2000       1500
Y3                2500       2000
;

Alias(SkillCat,skp,sk);
Alias (Years,y)

Parameters
        RetrainC(sk)    'Retrain Cost each worker per skill leve;[$]'   /S1 400, S2 500/
        RedundC(sk)     'cost of redundancy per worker [$]'             /S1 200, S2 500, S3 500/
        OvermanC(sk)    'cost of overmanning per worker [$]'            /S1 1500, S2 2000, S3 3000/
        ShorttC(sk)     'cost of having shorttime worker [$]'           /S1 500, S2 400, S3 400/
        RnewAtrn(sk)     'rate of attrition of new workers [$]'         /S1 0.25, S2 0.20, S3 0.10 /
        Roldatt(sk)     'rate of attrition of old workers [$]'          /S1 0.10, S2 0.05, S3 0.05 /
        Rdownatt        'rate of attrition of downgraded workers'       /0.5/
        RecLim(sk)      'max recruitment each year in each category'    /S1 500, S2 800 , S3 500/
        ;

Integer variable
        Wrecruit(y,sk)          'number of recruits at end of each year'
        Wretrain(y,sk)          'number of workers retrained'
        Wredund(y,sk)           'number of workers declared redundant'
        Wshortt(y,sk)           'number of workers on short work'
        Wextra(y,sk)            'total number of extra workers each year each category'
        Wattritn(y,sk)          'number of workers leaving. Includes current and past year workers'
        Wdowngrad(y,sk,skp)     'number of workers downgraded from sk to skp'
        Wtotal(y,sk)            'total number of workers in each category each year'
        ;

Variables
        CostRetrain(y)          'Cost of retraining [$]'
        CostRedund(y)           'Redundancy cost each year [$]'
        CostExtra(y)            'cost of having extraworkers each year [$]'
        CostStime(y)            'short time worker cost each year [$]'
        TotCTC                  'total cost to company [$]'
        TotRed                  'total number of layoffs / redundancy workers'
        ;

equations
         total(y,sk)            'total workers each year per skill level'
         attrition(y,sk)        'attrition each year per skill level'
         Overmanning(y)         'limit on extra workers each year'
         Extraman(y,sk)         'number of extra workers per year per skill level'
         retrainlim(y,sk)       'retrainlim equations'
         retraincosts(y)        'cost to retrain'
         overmancosts(y)        'cost of overmanning'
         redundancycosts(y)     'cost of redundancy'
         shorttimecosts(y)      'cost of having short time workers'
         totalcosts             'total costs for 3 years'
         objfunc                'cumulative redundancy minimization'
         ;


*Minimum Manpower contraints as bound    
Wtotal.lo(y,sk) = ManPower(y,sk) ;
*Max extra manpower each year is 150. A safe upper cound on the variable Wtotal
Wtotal.up(y,sk)= ManPower(y,sk) + 150 ;

*Limits on recruitment
Wrecruit.lo(y,sk) = 0;
Wrecruit.up(y,sk) = Reclim(sk);

*Limits on retraining

Wretrain.up(y,'S1') = 200;
Wretrain.fx(y,'S3') = 0;
Wretrain.lo(y,sk) =0 ;

*Limits on Short Time workers
Wshortt.up(y,sk) = 50;

*Current values, inital year, Y0
Wtotal.fx('y0',sk)   = ManPower('y0',sk) ;
Wrecruit.fx('y0',sk) =0   ;
Wretrain.fx('y0',sk) =0   ;
Wredund.fx('y0',sk)  =0   ;
Wdowngrad.fx('y0',skp,sk) =0 ;
Wredund.lo(y,sk) = 0;


total(y,sk)$(ord(y)>1)..    Wtotal(y,sk) =E= Wtotal(y-1,sk) + Wrecruit(y,sk)
                                            - Wredund(y,sk)- Wattritn(y,sk) + [Wretrain(y,sk-1) - Wretrain(y,sk)]
                                            + { sum(skp$(ord(skp) > ord(sk)),Wdowngrad(y,skp,sk))
                                                    -sum(skp$(ord(skp)<ord(sk)),Wdowngrad(y,sk,skp))}   ;


attrition(y,sk)..           Wattritn(y,sk) =E= RnewAtrn(sk)*Wrecruit(y,sk) + Roldatt(sk)*Wtotal(y-1,sk)+ Roldatt(sk)*Wretrain(y,sk-1)
                                            + 0.5*[sum(skp$(ord(skp) > ord(sk)),Wdowngrad(y,skp,sk))]    ;

Overmanning(y)..            sum(sk, Wextra(y,sk)) =L= 150 ;

extraman(y,sk)..            Wextra(y,sk) +  0.5*Wshortt(y,sk) =E= Wtotal(y,sk) - ManPower(y,sk) ;

retrainlim(y,sk)..          Wretrain(y,'S2') =L= 0.25* Wtotal(y,'S3') ;

retraincosts(y)..           CostRetrain(y) =E= sum(sk, RetrainC(sk)*Wretrain(y,sk)) ;

redundancycosts(y)..        CostRedund(y) =E= sum(sk, RedundC(sk)*Wredund(y,sk));

overmancosts(y)..           CostExtra(y) =E= sum(sk, OvermanC(sk)*Wextra(y,sk));

shorttimecosts(y)..         CostStime(y) =E= sum(sk, ShorttC(sk)* Wshortt(y,sk)) ;

totalcosts..                TotCTC =E= sum(y, CostRetrain(y) + CostRedund(y) + CostExtra(y) + CostStime(y) ) ;

objfunc..                   TotRed =E= sum((y,sk), Wredund(y,sk)) ;


model manpowerplan /all/ ;
option limrow = 100,limcol=100;
option intVarup =2;
option optcr=0;

solve manpowerplan using MIP minimizing TotRed ;

display Wredund.l,Wrecruit.l,Wdowngrad.l,Wshortt.l;

solve manpowerplan using MIP minimizing TotCTC ;

display Wredund.l,Wrecruit.l,Wdowngrad.l,Wshortt.l;
