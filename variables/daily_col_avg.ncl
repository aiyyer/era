;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
;
; Reads daily ERA interim data and calculates the column average of various variables
;--------------------------------------------------------------------------------------
; NCSU Tropical Dynamics
;
; A. Aiyyer 5.14.2019
;--------------------------------------------------------------------------------------
;
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load  "../../ncl/column_avg.ncl"


;
begin

;-----------------------------------------------------------------------------------------  
  ystart    =   1998
  nyears    =   17
  ndays     =   152


; derived variables
  variables =  (/"Mse","Dse","zonalAdvMse","meridAdvMse","vertAdvMse","zonalAdvDse","meridAdvDse","vertAdvDse","zonalAdvQ","meridAdvQ","vertAdvQ"/)
  nvar = dimsizes(variables)

; the names of variables in the datafiles
  varName = variables


;---------------------------------------------------------------------------------------------
  do iy = ystart,ystart+nyears-1 
    im = 06
    id = 01
    ih = 00
    mi = 00
    se = 00
    units = "hours since 1-1-1 00:00:0.0"
; for each year go from april to dec
    date = ut_inv_calendar(iy,im,id,ih,mi,se,units,0)
    
    do ntimes = 0,ndays-1
      dateFil = cd_calendar(date,-2)
      print(date + " " + dateFil)
      fileName = "/tamrind/eradaily/3D_derived/" +dateFil+".nc"
      in= addfile(fileName, "r")
      fileName = "/tamrind/eradaily/2D_derived/" +dateFil+".nc"
      
      if (fileexists(fileName)) then
        out= addfile(fileName, "w")
      else
        out= addfile(fileName, "c")
      end if
  
      do ivar = 0,nvar-1
        dat   = in->$varName(ivar)$({1000:100},:,:)
        ;printVarSummary(dat)
        ;exit
        datC  = column_avg(dat,dat&level)
        datC@long_name = "Column Average " + datC@long_name
        outVar = "ColAvg"+varName(ivar)
        out->$outVar$=datC
      end do
      date = date + 24.    
    end do ; loop over day
  end do    ; loop over years
  
end


