set s sector /1,2,3/
    t time /1*6/
    ;
alias (s,ss);

variable share(s,s,t), out(s,t),tot ;
positive variable share, out;
parameter demand(s) / 1 100, 2 100, 3 100/
;
equations balance(s,t),quant(s,ss,t),total;


balance(s,t).. out(s,t) =E= sum(ss,share(s,ss,t)) + demand(s);
quant(s,ss,t)..   share(s,ss,t) =L= out(s,t) ;
total.. tot =e= sum((s,t),out(s,t));


model l /all/;

solve l using lp maximizing tot;