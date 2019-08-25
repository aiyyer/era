;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
; calculates variance of bandpassed filtered data
;
;
;FOR USE WITH ERA INTERIM DATA
;
;
; NCSU Tropical dynamics (NTD)
; A. Aiyyer
; 07/12/2019
; This code is part of the ERA Interim analysis package at NTD
;
;=========================================================================================
;
;
;
;Notes
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "../../ncl/aiyyer_string_routines.ncl"
;
begin


dir = "/tamrind/eradaily/filtered/2to10/"
variable = "ColAvgQBP"
varOut   = variable + "Variance"
varOut2   = variable + "Ave"

md1 = 0701
md2 = 0930

count = 0.
firstYear = True


fileName = "/tamrind/climo/era/era_daily_2to10_derived_fields.nc"

do iy = 1998,2014
  
  startDate = iy*10000 + md1
  endDate = iy*10000 + md2
  
  print (startDate + " " + endDate)
  fil = dir + "2-10DayBP_daily" + iy + ".nc"
  in=addfile(fil,"r")
  timeUnits = in->time@units
  
  dateBeg = ymddate(startDate,timeUnits)
  dateEnd = ymddate(  endDate,timeUnits)
  
  ;print (dateBeg + " " + dateEnd )
  
  dat = in->$variable$({dateBeg:dateEnd},:,:)
  
; now calculate the seasonal variance
  
  datvar = dim_variance_n_Wrap (dat,0)
  datave = dim_avg_n_Wrap (dat,0)

  if (firstYear ) then
    var = datvar
    ave = datave
    firstYear = False
  end if 
  
  var = var*count/(count+1.) + datvar/(count+1.)
  ave = ave*count/(count+1.) + datave/(count+1.)

  print (iy + " " + count + " " + var({10.},{0.})  + " " + datvar({10.},{0.})+ " " + ave({10.},{0.})  + " " + datave({10.},{0.}))
  count = count + 1.
  
end do




if ( fileexists(fileName) ) then
  print ("outFile exists. Writing output")
  outFile  = addfile(fileName, "w")
else
  print ("outFile created. Writing output")
  outFile  = addfile(fileName, "c")
end if

printVarSummary(var)

outFile->$varOut$=var
outFile->$varOut2$=ave


print ("Normal code termination")
print ("===============================================")

end