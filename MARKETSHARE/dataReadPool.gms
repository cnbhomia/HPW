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

* We create a file slices.txt to store statement for various slices of data
* we wish to extract from the excel file.
*=============================================================================
$onecho>slices.txt
par =data rng=Sheet1!A1 rdim=3 trace=99
par=oil rng=Sheet2!A1 rdim=1 trace=99
par=spirit rng=Sheet3!A1 rdim=1 trace =99
