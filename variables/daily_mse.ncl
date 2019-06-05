;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
;
; Reads daily ERA interim data and calculates the column average moist and dry static 
; energies and their advections
;
; Reads T,Z,Q,U,V,W
;
; Calculates and outputs: Mse zonalAdvMse meridAdvMse vertAdvMse 
;                         Dse zonalAdvDse meridAdvDse vertAdvDse
;
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

;-----------------------------------------------------------------------------------------  
; define constants  
  L  = 2.501e6
  cp = 1005.7
  grav = 9.8
;  
  
  ystart    =   2012
  nyears    =   3
  ndays     =   152

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
      fileName = "/tamrind/eradaily/3D/" +dateFil+".nc"
      datFile = addfile(fileName, "w")
      ;print(fileName)
      U = datFile->U ;(:,::-1,:)  ; no need to flip lats as we are using cfd routines below
      V = datFile->V ;(:,::-1,:)
      T = datFile->T ;(:,::-1,:)  ; Temp in K
      Z = datFile->Z ;(:,::-1,:)  ; erai Z = gz m**2 s**-2  so no need to multiply by g
      Q = datFile->Q ;(:,::-1,:)  ; eri Q is in kg/kg
      W = datFile->W ;(:,::-1,:)  ; erai in Pa/s

      Mse  = Q
      Mse  = cp*T + Z + L*Q ; erai Z = gz so no need to multiply by g
      Mse@long_name = "Moist Static Energy"
      Mse@units = "J/kg"

      Dse = Q
      Dse = cp*T + Z ; erai Z = gz so no need to multiply by g
      Dse@long_name = "Dry Static Energy"
      Dse@units = "J/kg"
      


    
 
    
;---------------------------------------------------------------
; vertical advection

      dims = dimsizes(W)
      nz   = dims(0)
      ;printVarSummary(W)
      ;print(W&level)
      
      vertAdvMse = Mse
      vertAdvDse = Dse
      plevels = W&level ; in hPa

      do k = 1,nz-2
        delP = 100.*(plevels(k+1) - plevels(k-1))
        vertAdvMse(k,:,:) = -1.*W(k,:,:)*(Mse(k+1,:,:)-Mse(k-1,:,:))/delP
        vertAdvDse(k,:,:) = -1.*W(k,:,:)*(Dse(k+1,:,:)-Dse(k-1,:,:))/delP
      end do
      k=0
      delP = 100.*(plevels(k+1) - plevels(k))
      vertAdvMse(k,:,:) = -1.*W(k,:,:)*(Mse(k+1,:,:)-Mse(k,:,:))/delP
      vertAdvDse(k,:,:) = -1.*W(k,:,:)*(Dse(k+1,:,:)-Dse(k,:,:))/delP
      k=nz-1
      delP = 100.*(plevels(k) - plevels(k-1))
      vertAdvMse(k,:,:) = -1.*W(k,:,:)*(Mse(k,:,:)-Mse(k-1,:,:))/delP
      vertAdvDse(k,:,:) = -1.*W(k,:,:)*(Dse(k,:,:)-Dse(k-1,:,:))/delP
   
      vertAdvDse@long_name = "Vert Advection of DSE"
      vertAdvDse@units = "J/kg/s"
 
      vertAdvMse@long_name = "Vert Advection of MSE"
      vertAdvMse@units = "J/kg/s"
;------------------------------------------------------------------------------
; now calculate the horizontal gradient of mse to then get advections
      
      grad  = grad_latlon_cfd (Mse, Mse&lat, Mse&lon, True, False)
      mY = grad[0]
      mX = grad[1]
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
;------------------------------------------------------------------------------
; now calculate the horizontal gradient of dse to then get advections
      
      grad  = grad_latlon_cfd (Dse, Dse&lat, Dse&lon, True, False)
      mY = grad[0]
      mX = grad[1]
      copy_VarMeta(Q,mY)
      copy_VarMeta(Q,mX)      
; zonal advection 
      zonalAdvDse  = -U*mX
      meridAdvDse  = -V*mY      
      copy_VarMeta(Q,zonalAdvDse)
      copy_VarMeta(Q,meridAdvDse)      
      zonalAdvDse@long_name = "Zonal Advection of DSE"
      zonalAdvDse@units = "J/kg/s"
      meridAdvDse@long_name = "Merid  Advection of MSE"
      meridAdvDse@units = "J/kg/s"
;------------------------------------------------------------------------------
      
      fileName = "/tamrind/eradaily/3D_derived/" +dateFil+".nc"
      if (fileexists(fileName)) then
        datFile = addfile(fileName, "w")
      else
        datFile = addfile(fileName, "c")
      end if
      
      print ( Mse(:,{10.},{340.}) + " " + Dse(:,{10.},{340.})  )
      exit      
      
      datFile->Mse=Mse
      datFile->zonalAdvMse=zonalAdvMse
      datFile->meridAdvMse=meridAdvMse
      datFile->vertAdvMse=vertAdvMse
    
      datFile->Dse=Dse
      datFile->zonalAdvDse=zonalAdvDse
      datFile->meridAdvDse=meridAdvDse
      datFile->vertAdvDse=vertAdvDse

      date = date + 24.    
    end do ; loop over day
  end do    ; loop over years
  
end


