$ontext
this model is the manpower planning model from HP WIlliams book, excercise 12.5

$offtext

sets
         year 'years in question' /y0*y3/
         workcat 'work category' /unskill, semskill, skilled/
         manpow(year,workcat) 'manpower required'
         ;

set table manpow(year,workcat)
         unskill         semskill        skilled
y0       2000            1500            1000
y1       1000            1400            1000
y2       500             2000            1500
y3       0               2500            2000
         ;
variables
         Wrecruit(year,workcat)  'number of recruits each year'
         Wretain(year,workcat)   'number of retained personnel'
         Wredund(year,workcat)   'number of workers declared redundant'

