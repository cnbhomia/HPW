$title Curve Fitting (CURVE, SEQ =xxx)

$ontext
This problem aims at fitting a curve ( straigth line and quadratic curve) through
a set of data points. The fitting is done using two objectives, viz
a. minimize sum of absolute deviations
b. minimize the maximum deviation

Model Building in Mathematical Programming,Fifth Edition, H. Paul Williams,
Model 12.1 : Food Planning I
Wiley Publication, 2013

$offtext

Sets
    i       'number of observation points'
    ;

Parameters
    x(i)     'input in each observation'
    y(i)     'output in each observation'
    xy(i,*)  'x-y tuple in each observation for import'
    ;
$onecho>slices.txt
dset =i rng =A2:A20 rdim=1
par=xy rng A1 rdim=1 cdim =1
$offecho

$call gdxxrw curvefit.xlsm o=curve.gdx @slices.txt
$ife errorlevel<>0 $abort "Problems with GDXXRW""

$gdxin curve.gdx
$load i xy
$gdxin

x(i) = xy(i,'x');
y(i) = xy(i,"y");


Variables
    a      'coefficient a for the general curve cx^2 + bx + a'                  
    b      'coefficient b for the general curve cx^2 + bx + a'     
    c      'coefficient c for the general curve cx^2 + bx + a'     
    ybar(i) 'value of y from the curve fit'   
    e(i)    'error per observation'
    sumE    'total abosulate error, objvar'
    MinMaxE 'Minimum Maximum Error'
    ;


Equation
    ybarL(i)   'calculate ybar=ax + b, linear equation'
    error1(i)  'calculation of absolute error, ybar-y'
    error2(i)  'calculation of absolute error, ybar-y'
    TotAbsDevL  'objfunc, linear fit, minimum total absolute deviation'
    MiniMaxErrL(i)
    ;


ybarL(i)..          ybar(i) =E= b*x(i) + a;
error1(i)..         e(i) =G= ybar(i) - y(i);
error2(i)..         e(i) =G= y(i) - ybar(i);
TotAbsDevL..        sumE =E= sum(i,e(i));
MiniMaxErrL(i)..    MinMaxE =G= e(i) ;

model linearfit /all/ ;
solve linearfit using LP min sumE ;


parameter coefficients(*,*) ;
coefficients('a','linear Minsum') = a.l ;
coefficients('b','linear Minsum') = b.l ;

solve linearfit using LP min MinMaxE ;
coefficients('a','linear MinMax') = a.l ;
coefficients('b','linear MinMax') = b.l ;


Equations
    ybarQ(i)   'calculate ybar=c.x^2 a1x + b1, linear equation'  
    TotAbsDevQ  'objfunc, linear fit, minimum total absolute deviation'
    MiniMaxErrQ(i)
    ;

ybarQ(i)..          ybar(i) =E= c*x(i)**2 + b*x(i) + a;
TotAbsDevQ..        sumE =E= sum(i,e(i));
MiniMaxErrQ(i)..    MinMaxE =G= e(i) ; 


model quadfit /ybarQ, error1, error2, TotAbsDevQ, MiniMaxErrQ/ ;

solve quadfit using QCP min sumE ;
coefficients('a','quad MinSum') = a.l ;
coefficients('b','quad MinSum') = b.l ;
coefficients('c','quad MinSum') = c.l ;


solve quadfit using QCP min MinMaxE ;
coefficients('a','quad MinMax') = a.l ;
coefficients('b','quad MinMax') = b.l ;
coefficients('c','quad MinMax') = c.l ;


display coefficients ;

