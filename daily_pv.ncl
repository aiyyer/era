;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
;
; Reads daily ERA interim data and calculates the Ertel PV on pressure surface
;
;

;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
begin

  
  ystart    = 1981
  nyears    =   35
  ndays     =   275
  nvars     =    6


;---------------------------------------------------------------------------------------------
    do iy = ystart,ystart+nyears-1 
       im = 04
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
       fileName = "/typhoon/eradaily/"+dateFil+".nc"  ;+"_"+variables(ivar)+".nc"
       datFile = addfile(fileName, "w")
       
       U = datFile->U(:,::-1,:)
       V = datFile->V(:,::-1,:)
       T = datFile->T(:,::-1,:)

       lev = U&lv_ISBL0
 
       lev = lev*100  ; convert units
       lev@units = "Pa"

       lat = U&g4_lat_1
       gridType = 1       ; regular grid
       
       PV  = pot_vort_isobaric(lev,U,V,T,lat, gridType, 0 )
       PV  = PV(:,::-1,:)

       ;printVarSummary(PV)
       ;printVarSummary(U)
       printMinMax(PV,0)
       datFile->PV=PV


       date = date + 24.    
     end do ; loop over day
   end do    ; loop over years
   
end


