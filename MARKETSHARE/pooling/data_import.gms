$ontext
This file reads data for the Market Sharing Model MARKET (SEQ=xxx) from excel
file, and is  used as an include file in the model.
$offtext

sets
    Suppliers                   'Suppliers in the market'   /D1,D2/
    Retailers                   'Retailers in the market'
    Regions                     'Regions in the area'
    GrCat                       'Growth Categories among the retailer'
    RGrps(Retailers,GrCat)      'Mapping Retailers to the Group Category'
    RRegs(Retailers,Regions)    'Mapping Retailers to the Regions'
    ;

Parameters
    DPoints(Retailers)     'Number of distribution point for each retailer'
    DOil(Retailers)        'Data, oil market for each retailer'
    DSpirit(Retailers)     'Data, Spirit market for each retailer'
    Data(Retailers,Regions,GrCat)  'Data, distribution point for each retailer'
    ;

$onecho>slices.txt
par =data rng=Sheet1!A1 rdim=3 trace=99
par=oil rng=Sheet2!A1 rdim=1 trace=99
par=spirit rng=Sheet3!A1 rdim=1 trace =99
$offecho

$call gdxxrw market_data.xlsx o=data.gdx @slices.txt

$gdxin data.gdx
$load Retailers <data.dim1
$load Regions < data.dim2
$load GrCat < data.dim3
$load Data = data
$load DOil = oil
$load DSpirit = spirit
$gdxin

DPoints(Retailers) = sum((Regions,GrCat), Data(Retailers,Regions,GrCat));
option Rgrps< Data ;
option RRegs<Data ;





