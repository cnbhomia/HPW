set i/ 1,2,3,4/;
alias(i,j)
parameter K(i) / 1 0.34, 2 -0.35 , 3 0.1, 4 -0.26 / ;

Variable Z(i), M;
 
Equation ZK1(i),ZK2(i), ZM1,ZM2(i);


ZK1(i).. Z(i) =G= K(i) ;
ZK2(i).. Z(i) =G= - K(i) ;

ZM1.. M =L=sum(i, Z(i) );
ZM2(i).. M =G= Z(i);

model minimax /all/ ;

solve minimax using LP Min M;