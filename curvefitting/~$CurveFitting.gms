$title Curve Fitting (CURVE, SEQ =xxx)

$ontext
This problem helps decide the buying and manufacturing policy for an oil
blending production line over 6 monthth period. The objective is to maximize
profit under the capacity and storage constraints.

Model Building in Mathematical Programming,Fifth Edition, H. Paul Williams,
Model 12.1 : Food Planning I
Wiley Publication, 2013

$offtext


Sets
    i       'number of observation points'
    ;

Parameters
    x(i)    'input in each observation'
    y1(i,*)
    y(i)    'output in each observation'
    ;
$onecho>slices.txt
dset =i rng =A2:A20 rdim=1
par=x rng A2:B20 rdim=1
par=y1 rng A2:C20 rdim=2
$offecho

$call gdxxrw curvefit.xlsm o=curve.gdx @slices.txt


$gdxin curve.gdx
$load i
$load x
$load y1
$gdxin

y = y1;

*$call gdxxrw i=data_read.xlsm o=data2.gdx dset=i6 Rng=A3:A5 rdim=1
$offtext

