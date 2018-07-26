$ontext

This model is the refinery model from HPWilliams book.

$offtext

sets
    fluid 'all flows in refinery' /c1,c2,LN,MN,HN,LO,HO,RES,RGAS,COIL,CGAS,REG, PRE, JET, OIL, LUB/
    crude 'crude oils' /c1,c2/
    oper 'refinery operations' /DIS,REF,CRK1,CRK2,BLD1,BLD2,BLD3/
    inter 'intermediates in the operation' /LN,MN,HN,LO,HO,RES,RGAS,COIL,CGAS/
    products 'final products' /REG, PRE, JET, OIL, LUB/
    direc /in , out/
    ;


set flow(oper,direc,fluid);

table flow(oper,direc,fluid)
          c1    c2  LN  MN  HN  LO  HO  RES RGAS COIL CGAS REG PRE   JET OIL LUB
DIS.in     1    1   
DIS.out             1   1   1   1   1    1 
REF.in              1   1   1                 
REF.out                                       1
CRK1.in                         1   1
CRK1.out                                           1    1
CRK2.in                                  1
CRK2.out                                                                       1
BLD1.in             1   1   1
BLD1.out                                                    1   1
BLD2.in                         1   1    1          1         
BLD2.out                                                             1
BLD3.in                         1   1    1          1   
BLD3.out                                                                  1

; 

variable mass(oper,direc,fluid);

equation
    DISmassbal(oper) 'mass balance across distillation';

massbal(oper)$(val(oper)='DIS').. sum((direc,fluid)$ flow(flow,'in',fluid),mass(oper,,direc,fluid)) =e= sum((direc,fluid)$ flow(flow,'out',fluid),mass(oper,,direc,fluid));



$ontext
table proflo(process,flow) 'massflow in and out of processes'
        c1  c2  LN  MN  HN  LO HO   RES RGAS    COIL CGAS REG PRE JET OIL LUB
dist    -1  -1  1   1   1   1   1   1   0       0      0   0   0   0   0    0
refo    0   0   -1  -1  -1  0   0   0   1       0      0   0   0   0   0    0
cracoil 0   0   0   0   0   -1  -1  0   0       1      1   0   0   0   0    0
cracres 0   0   0   0   0   0   0   -1  0       0      0   0   0   0   0    1
blend1  0   0   -1  -1  -1  0   0   0   -1      0     -1   1   1   0   0    0
blend2  0   0   0   0   0   -1  -1  -1  0       0      0   0   0   1   0    0
blend3  0   0   0   0   0   -1  -1  -1   0      -1     0   0   0   0   1    0
;



variable mass(flow) 'mass flow of each R/M , intermediate and product';


equations distillation(flow,process);

distillation(flow,process).. sum(proflo(process,flow)$

$offtext