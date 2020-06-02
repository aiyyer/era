;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
;
; Reads daily ERA interim data and calculates the Ertel PV on pressure surface
;
;
; UNDER CONST
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
begin

  
  ystart    = 2005
  nyears    =   1
  ndays     =   1
  nvars     =   1


;---------------------------------------------------------------------------------------------
    do iy = ystart,ystart+nyears-1 
       im = 08
       id = 04
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

       fileName = "/tamrind/eradaily/test/20050804.nc"
       datFile = addfile(fileName, "w")
       
       U = datFile->U(:,::-1,:)
       V = datFile->V(:,::-1,:)
       T = datFile->T(:,::-1,:)
       Q = datFile->Q(:,::-1,:)
       lev = U&level 
       lev = lev*100  ; convert units
       lev@units = "Pa"

       printVarSummary(Q)

; calculate thetaE
       
       TE = pot_temp_equiv(lev, T, Q,0, "q")  
; calculate theta
       TT = pot_temp(lev,T, 0, False)  ; dim=0

       T2 = T
       T2 = T*TE/TT

 ;      printVarSummary(TT)
 ;      printVarSummary(TE)
 ;      print ( TT({850.},{0.},{5.}) + " " + TE({850.},{0.},{5.}))
 ;      print ( T({850.},{0.},{5.}) + " " + T2({850.},{0.},{5.}))



       PVOrig = datFile->PV(:,::-1,:)



       lat = U&lat
       gridType = 1       ; regular grid
  
; for moist PV use T2     
       PV  = pot_vort_isobaric(lev,U,V,T2,lat, gridType, 0 )
       PV  = PV(:,::-1,:)

       ;printVarSummary(PV)
       ;printVarSummary(U)
       printMinMax(PV,0)
       printMinMax(PVOrig,0)


       print ( PV({850.},{-40.},{15.}) + " " +  PVOrig({850.},{-40.},{15.}))
       ;datFile->PVtest=PV


       date = date + 24.    
     end do ; loop over day
   end do    ; loop over years
   
end


