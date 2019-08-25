;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
; calculates EKE using bandpass filetered u,v
; outputs seasonal average eke climatology
;
;FOR USE WITH ERA INTERIM DATA
;
;
; NCSU Tropical dynamics (NTD)
; A. Aiyyer
; 07/16/2019
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
variableU = "UBP"
variableV = "UBP"
varOut    = "EKE"

md1 = 0701
md2 = 0930

count = 0.
firstYear = True


fileName = "/tamrind/climo/era/era_daily_2to10_derived_fields.nc"

do iy = 1998,2014
  
  startDate = iy*10000 + md1
  endDate = iy*10000 + md2
  
  ;print (startDate + " " + endDate)
  fil = dir + "2-10DayBP_daily" + iy + ".nc"
  in=addfile(fil,"r")
  timeUnits = in->time@units
  
  dateBeg = ymddate(startDate,timeUnits)
  dateEnd = ymddate(  endDate,timeUnits)
  
  ;print (dateBeg + " " + dateEnd )
  
  U = in->$variableU$({dateBeg:dateEnd},:,:,:)
  V = in->$variableV$({dateBeg:dateEnd},:,:,:)
  E = U
  E = .5*(U*U + V*V)
  E@long_name = "EKE"
  E@units = "m**2 s**-2"


; now calculate the seasonal mean
  
  ES = dim_avg_n_Wrap (E,0)
  

; define an array to hold the EKE climo 
; copy it once from ES
  if (firstYear ) then
    EKE = ES
    firstYear = False
  end if 
  
  EKE = EKE*count/(count+1.) + ES/(count+1.)
  
  print (iy + " " + count + " " + ES({650.},{10.},{0.}) + " " +  EKE({650.},{10.},{0.}) )
  count = count + 1.
  
end do




if ( fileexists(fileName) ) then
  print ("outFile exists. Writing output")
  outFile  = addfile(fileName, "w")
else
  print ("outFile created. Writing output")
  outFile  = addfile(fileName, "c")
end if

printVarSummary(EKE)

outFile->$varOut$=EKE


print ("Normal code termination")
print ("===============================================")

end