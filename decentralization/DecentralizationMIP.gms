$title Decentralization with linear MIP constraints (DCENTRALIZATN-MIP, SEQ =xx)

$ontext
This problem is a simple decision making problem for a company relocating it's five
departments from London to two other cities subject to constraint of maximum
number of offices in a city. The objective is to maximize the benefits of relocation
against increased communication costs.

This model uses lineear MIP constraint to represent the polynomial of binaries
Locate(city,city)*Locate(city,city) into two linear MIP constraints.

Model Building in Mathematical Programming, Fifth Edition,
H. Paul Williams, Model 12.10 : Decentralization
Wiley Publication, 2013
$offtext

Sets
    Dept    'Departments in the company'    /A*E/
    City    'Cities Available'              /'Bristol', 'Brighton' , 'London'/
    ;

Table B(City,Dept)      'Benefits from relocation, [1000 £/yr]'
             A      B       C       D       E
Bristol     10     15      10      20       5   
Brighton    10     20      15      15      15
    ;

Table C(Dept,Dept)      'Quantity of communication between departments [1000 units] '
    A      B       C       D       E
A                 1.0     1.5         
B                 1.4     1.2
C                                 2.0  
D                                 0.7
    ;

Table D(City, City)     'Cost of Communication between cities [£/unit] '
            Bristol     Brighton    London
Bristol           5           14        13            
Brighton         14            5         9
London           13            9        10
    ;

Alias(Dept,i,k),(City,j,l);

Variables
    Locate(Dept,City)   'Moving Decision Variable'
    ComOpen(i,j,k,l)    'Communication between Dept i at City j to Dept k at City l'
    MovCost             'Cost Benefit from Moving, [1000£]'
    ComCost             'Cost from comunication, [1000£] '
    NetCost             'Net cost, [1000£]'
    ;

Binary Variable Locate(Dept,City),ComOpen(i,j,k,l);

Equations
    Benefits                 'Benefit Evaluation'
    Communication            'Communication Cost Evaluation'
    BinaryCon1(i,j,k,l)      'Logical Condition ComOpen(i,j,k,l) --> Locate(i,j)'
    BinaryCon2(i,j,k,l)      'Logical Condition ComOpen(i,j,k,l) --> Locate(k,l)'
    BinaryCon3(i,j,k,l)      'Logical Condition Locate(i,j) and Locate(k,l) --> ComOpen(i,j,k,l)'
    MaxDept(City)            'Maximum Departments allowed in each city'
    MaxCity(Dept)            'Maximum City for each Department'
    Savings                  'Net cost'
    ;

Benefits..                  MovCost =E= sum ((i,j), Locate(i,j)* B(j,i)) ;

Communication..             ComCost =E= sum((i,j,k,l), C(i,k)*D(j,l)* ComOpen(i,j,k,l));

BinaryCon1(i,j,k,l) $[(ord(i)<ord(k))]..
                            ComOpen(i,j,k,l) - Locate(i,j) =L= 0;

BinaryCon2(i,j,k,l) $[(ord(i)<ord(k))]..
                            ComOpen(i,j,k,l) - Locate(k,l) =L= 0;

BinaryCon3(i,j,k,l) $[(ord(i)<ord(k))]..
                            Locate(i,j) + Locate(k,l) -  ComOpen(i,j,k,l) =L= 1;

MaxDept(City)..             sum(Dept,Locate(Dept,City)) =L= 3;

MaxCity(Dept)..             sum(City,Locate(Dept,City)) =E= 1;

Savings..                   NetCost =E=  - MovCost + ComCost ;

Model Decentre /all/;

Solve Decentre using MIP minimizing NetCost;

Display Locate.l, MovCost.l, ComCost.l;


$ontext
notes: the table D is a full martix, instead of the upper traingular matric as provided and used in the book.
Use of D as a lower matrix renders some ComOpen(i,j,k,l) useless, and the HP William Model Solution does not work.

Additionally, using full matrix D prevents use of contraints over domain of ComOpen(i,j,k,l).

Constraint over summation of Cost has some sort of typographical error. 

$offtext




       