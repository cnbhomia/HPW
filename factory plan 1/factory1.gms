$ontext
This code is for the problem 12.3 from H P William book

$offtext

sets
    prod 'products' /Prod1*Prod7/
    mac 'machines'  /G1*G4, VD1,VD2, HD1*HD3,borer,planer/
    grind(mac)      / G1*G4/
    vdrill(mac)     /VD1,VD2/
    hdrill(mac)     /HD1*HD3/
    bor(mac)        /borer/
    pln(mac)       /planer/
    ;

parameter profit(prod)
    /   Prod1   10
        Prod2   6
        Prod3   8
        Prod4   4
        Prod5   11
        Prod6   9
        Prod7   3
     /;