sets
    p 'ps' /p1*p7/
    mac 'machines'  /G1*G4, VD1,VD2, HD1*HD3,borer,planer/
    grind(mac)      / G1*G4/
    vdrill(mac)     /VD1,VD2/
    hdrill(mac)     /HD1*HD3/
    bor(mac)        /borer/
    pln(mac)       /planer/
    month 'months' /Jan Feb Mar Apr May Jun/;

table time(mac,p)  'time required'
            p1       p2     p3      p4      p5      p6      p7
G1*G4       0.5     0.7     0       0       0.3     0.2     0.5
VD1*VD2     0.1     0.2     0       0.3     0       0.6     0
HD1*HD3     0.2     0       0.8     0       0       0       0.6
borer       0.05    0.03            0.07    0.1             0.08
planer                      0.01            0.05            0.05
;