;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
;
; Reads daily ERA interim data and calculates the column average moist and dry static 
; energies
;
;--------------------------------------------------------------------------------------
; NCSU Tropical Dynamics
;
; A. Aiyyer 5.1.2019
;--------------------------------------------------------------------------------------
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
begin




  
; define constants  
  L  = 2.501e6
  cp = 1005.7
  grav = 9.8
;  
  
  ystart    = 1998
  nyears    =   13
  ndays     =   245

;---------------------------------------------------------------------------------------------
    do iy = ystart,ystart+nyears-1 
       im = 05
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
       fileName = "/tamrind/eradaily/3D/" +dateFil+".nc"
       datFile = addfile(fileName, "w")
       print(fileName)
       U = datFile->U ;(:,::-1,:) no need to flip lats as we are using cfd routines below
       V = datFile->V ;(:,::-1,:)
       T = datFile->T ;(:,::-1,:)
       Z = datFile->Z ;(:,::-1,:)
       Q = datFile->Q ;(:,::-1,:)

       Mse = Q
       Mse  = cp*T + Z + L*Q 
       Mse@long_name = "Moist Static Energy"
       Mse@units = "J/kg"

; now calculate the gradient of mse to then get advections

       gradMse  = grad_latlon_cfd (Mse, Mse&lat, Mse&lon, True, False)


       mY = gradMse[0]
       mX = gradMse[1]

       copy_VarMeta(Q,mY)
       copy_VarMeta(Q,mX)

; zonal advection 
       zonalAdvMse  = -U*mX
       meridAdvMse  = -V*mY

       copy_VarMeta(Q,zonalAdvMse)
       copy_VarMeta(Q,meridAdvMse)

       zonalAdvMse@long_name = "Zonal Advection of MSE"
       zonalAdvMse@units = "J/kg/s"


       meridAdvMse@long_name = "Merid  Advection of MSE"
       meridAdvMse@units = "J/kg/s"


       print ( Mse(:,{10.},{20.}) + " " +  meridAdvMse(:,{10.},{20.}))
       printVarSummary(meridAdvMse)
       exit


       ;datFile->Mse=Mse
       ;datFile->


       date = date + 24.    
     end do ; loop over day
   end do    ; loop over years
   
end


