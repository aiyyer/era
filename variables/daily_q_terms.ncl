;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
;
; Reads daily ERA interim data and calculates the advection of Q
; and writes back to the daily files
; Reads Q,U,V,W
;
; Q is not multiplied by L (latent heat of vaporization)
; units of advection are [Q]/s
;
; Calculates and outputs: zonalAdvQ meridAdvQ vertAdvQ 
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
  ystart    =   1998
  nyears    =   17
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
      U = datFile->U ;(:,::-1,:) no need to flip lats as we are using cfd routines below
      V = datFile->V ;(:,::-1,:)
      W = datFile->W ;(:,::-1,:)  ; erai in Pa/s
      Q = datFile->Q ;(:,::-1,:)  ; eri Q is in kg/kg


;---------------------------------------------------------------
; vertical advection

      dims = dimsizes(W)
      nz   = dims(0)
      ;printVarSummary(W)
      ;print(W&level)
      
      vertAdvQ = Q

      plevels = W&level ; in hPa
 
      do k = 1,nz-2
        delP = 100.*(plevels(k+1) - plevels(k-1))
        vertAdvQ(k,:,:) = -1.*W(k,:,:)*(Q(k+1,:,:)-Q(k-1,:,:))/delP
      end do
      k=0
      delP = 100.*(plevels(k+1) - plevels(k))
      vertAdvQ(k,:,:) = -1.*W(k,:,:)*(Q(k+1,:,:)-Q(k,:,:))/delP
      k=nz-1
      delP = 100.*(plevels(k) - plevels(k-1))
      vertAdvQ(k,:,:) = -1.*W(k,:,:)*(Q(k,:,:)-Q(k-1,:,:))/delP
      vertAdvQ@long_name = "Vert Advection of Q"
      vertAdvQ@units = "kg/kg/s"

;------------------------------------------------------------------------------
; now calculate the horizontal gradient of mse to then get advections
      
      grad  = grad_latlon_cfd (Q, Q&lat, Q&lon, True, False)
      mY = grad[0]
      mX = grad[1]
      copy_VarMeta(Q,mY)
      copy_VarMeta(Q,mX)      
; zonal advection 
      zonalAdvQ  = -U*mX
      meridAdvQ  = -V*mY
      
      copy_VarMeta(Q,zonalAdvQ)
      copy_VarMeta(Q,meridAdvQ)      
      zonalAdvQ@long_name = "Zonal Advection of Q"
      zonalAdvQ@units = "kg/kg/s"
      meridAdvQ@long_name = "Merid  Advection of Q"
      meridAdvQ@units = "kg/kg/s"

;------------------------------------------------------------------------------
      
;      print ( Q(:,{10.},{20.}) + " " +  meridAdvQ(:,{10.},{20.}))
;      printVarSummary(meridAdvQ)


      fileName = "/tamrind/eradaily/3D_derived/" +dateFil+".nc"
      if (fileexists(fileName)) then
        datFile = addfile(fileName, "w")
      else
        datFile = addfile(fileName, "c")
      end if
      

      datFile->zonalAdvQ=zonalAdvQ
      datFile->meridAdvQ=meridAdvQ
      datFile->vertAdvQ=vertAdvQ

      date = date + 24.    
    end do  ; loop over day
  end do    ; loop over years
  
end


