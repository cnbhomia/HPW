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
    j       'type of cureve fit,  linear and quadratic' /L , Q/
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
    a(j)      'coefficient a for straight line'                  
    b(j)      'coefficient b for straight line'
    c(j)      'coefficient c for straight line'  
    ybar(j,i) 'value of y from the curve fit'   
    e(j,i)    'error per observation'
    sumErr    'total abosulate error, objvar'
    MinMaxErr 'Minimum Maximum Error'
    ;


Equation
    ybarL(i)   'calculate ybar=ax + b, linear equation'
    ybarQ(i)   'calculate ybar=c.x^2 a1x + b1, linear equation'
    error1(j,i)  'calculation of absolute error, ybar-y'
    error2(j,i)  'calculation of absolute error, ybar-y'
    TotAbsDevL  'objfunc, linear fit, minimum total absolute deviation'
    MiniMaxErrL(i) 'objfunc, linear fit, min max deviation'
    TotAbsDevQ  'objfunc, linear fit, minimum total absolute deviation'
    MiniMaxErrQ(i) 'objfunc, linear fit, min max deviation'
    ;


ybarL(i)..     ybar('L',i) =E= b('L')*x(i) + a('L');
ybarQ(i)..     ybar('Q',i) =E= c('Q')*x(i)**2 + b('Q')*x(i) + a('Q');
error1(j,i)..  e(j,i) =G= ybar(j,i) - y(i);
error2(j,i)..  e(j,i) =G= y(i) - ybar(j, i);
TotAbsDevL..   sumErr =E= sum(i,e('L',i));
MiniMaxErrL(i)..  MinMaxErr =G= e('L',i) ;

model linearfit /ybarL, error1, error2, TotAbsDevL, MiniMaxErrL/ ;

solve linearfit using LP min sumErr ;

solve linearfit using LP min MinMaxErr ;

TotAbsDevQ..   sumErr =E= sum(i,e('Q',i));
MiniMaxErrQ(i)..  MinMaxErr =G= e('Q',i) ;

model quadfit /ybarQ, error1, error2, TotAbsDevQ, MiniMaxErrQ/ ;

solve quadfit using QCP min sumErr ;

solve quadfit using QCP min MinMaxErr ;

display a.l,b.l,c.l ;

      
    
