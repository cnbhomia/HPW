$title Create an Example GDX file for the IDE Charting Facility (CHARTDAT,SEQ=313)

$onText
Create gdx file for charting demo.
The generated gdx file can be used to follow the charting examples in the GAMSIDE.


GAMS Development Corporation, Formulation and Language Examples.

Keywords: GAMS language features, Gantt graph
$offText

$sTitle Data for single Lines, Bars, Pie
Set years / y1998*y2005 /;

Parameter YearDataA(years), YearDataB(years), YearDataC(years);
YearDataA(years) = uniform(100, 200);
YearDataB(years) = uniform(100, 200);
YearDataC(years) = uniform( 75, 125);

$sTitle Data for Functions
Set p / p1*p100 /;

Parameter Points(p,*);

Scalar x / 0.0 /, delta;

delta = 2.0*pi/(card(p) - 1);
loop(p,
   Points(p, 'x') = eps + sin(x);
   Points(p, 'y') = eps + cos(3*x);
   x = x + delta;
);

$sTitle Data Vector 3D
Set
   d         / d1*d20 /
   xyz       / x0, y0, z0, x1, y1, z1 /
   xy(xyz)   / x0, y0, x1, y1 /
   xy1(xy)   / x1, y1 /
   xyz0(xyz) / x0, y0, z0 /
   xy0(xy)   / x0, y0 /;

Parameter
   Vector3D(d, xyz)
   Vector2D(d, xy)
   Vector2Db(d, xy)
   Scatter3D(d, xyz0)
   Scatter2D(d, xy0);

vector3D(d, xyz)   = uniform(1, 10);
vector2D(d, xy)    = vector3D(d, xy);
Vector2Db(d, xy)   = Vector2D(d, xy);
Vector2Db(d, xy1)  = uniform(1, 10);
scatter3D(d, xyz0) = vector3D(d, xyz0);
scatter2D(d, xy0)  = vector2D(d, xy0);

$sTitle Data for Gantt Graph
Set
   task     / task1*task3 /
   resource / resource1*resource3 /
   sl       / start, length /;

Table GanttData(task, resource, sl)
                     start  length
   task1.resource1       1       8
   task1.resource3      12       2
   task2.resource2       2       4
   task2.resource3       7       3
   task3.resource1      10       1
   task3.resource2       8       3
   task3.resource3       4       2;

$sTitle Data for Surface Graph
Set s / s1*s50 /;

Alias (s, ss);

Parameter Surface(s, ss);

Scalar x, y;

loop((s, ss),
   x = (ord(s)  - 1)/(card(s)  - 1)*30 - 15;
   y = (ord(ss) - 1)/(card(ss) - 1)*30 - 15;
   surface(s, ss) = sin(sqrt(sqr(x) + sqr(y)))/sqrt(sqr(x) + sqr(y))
);

$stitle Data for multi Line Graph
Set
   time0       / t0*t100 /
   time(time0) / t1*t100 /
   stock       / IBM, DELL, HP, SUN /;

Parameter StockData(time, stock, xy0);

option seed = 12345;

StockData(time, stock, 'x0') = jstart - card(time) + ord(time);
StockData('t1', stock, 'y0') = 100;

loop(time,
   StockData(time+1, stock, 'y0') = StockData(time, stock, 'y0') + uniform(-1, 1);
);

$sTitle Data for Fan Graph
Set
   scenario / scen1*scen1000 /
   timex    / t0*t135 /;

Parameter ScenarioData(timex, scenario);

Scalar scale, x, dx, v;

ScenarioData('t0', scenario) = abs(1 + normal(2, 2));
scale = sum(scenario, ScenarioData( 't0', scenario));
ScenarioData('t0', scenario) = ScenarioData('t0', scenario)/scale;
ScenarioData('t1', scenario) = 100;
loop((timex, scenario)$(ord(timex) > 1),
   x  = ScenarioData(timex, scenario);
   v  = mod(uniformInt(1, 4), 3);
   dx = 0;
   if(V = 0, dx =  0;);
   if(V = 1, dx =  1$(ord(timex) > card(timex)/2););
   if(V = 2, dx = -2$(ord(timex) > card(timex)/1.5););
   dx = dx + uniform(-2, 2);
   dx$(abs(x + dx - 100) > 25) = 0;
   ScenarioData(timex+1, scenario) = x + dx;
);

* Export the data to a GDX file
execute_unload 'chartdata.gdx',
   YearDataA, YearDataB, YearDataC,
   Points,
   Vector2D, Vector2dB, Vector3D,
   Scatter2D, Scatter3D,
   GanttData,
   Surface,
   StockData,
   ScenarioData;

* generate a chart file
* open the file in the GAMSIDE to view the chart
File f / testchart.gch /;
put  f;
$onPut
[CHART]
GDXFILE=chartdata.gdx
TITLE=StockData
[SERIES1]
SYMBOL=StockData
TYPE=multi-linex
$offPut
