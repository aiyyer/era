;***************************************************************
;NCSU Tropical Dynamics
;A. Aiyyer 06/19/2019
;
;A basic code for plotting
;
;
;***************************************************************
begin
;***************************************************************
; User Input
;***************************************************************

  pltDir = "./"
  pltName = "Z"                         ; netCDF name output
  pltType = "ncgm"                      ; send graphics to PNG file
  

   wks    = gsn_open_wks(pltType, pltDir+pltName)
   res                      = True     ; plot mods desired
   ;res@cnFillPalette   = "GMT_cool"   ; change the color palette

   cmap = read_colormap_file("precip2_17lev")
   res@cnFillPalette = cmap(::-1,:)     ; reverse color map
   
;   res@gsnMaximize          = True     ; make ps/eps/pdf large
   
   res@cnFillOn             = False    ; turn on color fill
   res@cnFillMode           = "RasterFill"         ; Raster Mode
   res@cnLinesOn            =  True       ; Turn off contour lines
   res@cnLineLabelsOn       =  True       ; Turn off contour lines
   
   res@mpMinLatF            = 0.     
   res@mpMaxLatF            = 30.
   
   res@mpMinLonF            = 40.    
   res@mpMaxLonF            = 80.
   
   res@mpFillOn             = False
   

;   res@lbOrientation        = "vertical"   ; vertical label barb's
;   res@lbLabelFontHeightF   = 0.012        ; change font size
;   res@pmLabelBarWidthF     =  0.1     
;   res@pmLabelBarOrthogonalPosF = -0.01    ; move a bit to left



  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = 200.			; set the minimum contour level
  res@cnMaxLevelValF  = 400.			; set the maximum contour level
  res@cnLevelSpacingF = 2.			; set the interval between contours


  res@cnMinLevelValF  = -20.			; set the minimum contour level
  res@cnMaxLevelValF  =  20.			; set the maximum contour level
  res@cnLevelSpacingF =  1.			; set the interval between contours




;  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
;  res@cnMinLevelValF  = -40			; set the minimum contour level
;  res@cnMaxLevelValF  =  40.			; set the maximum contour level
;  res@cnLevelSpacingF = 2.			; set the interval between contours
 
  
  res@gsnContourNegLineDashPattern = 1       ; sets negative contours to dash pattern 1
  res@gsnContourZeroLineThicknessF = 0.        ; sets thickness of zero contour to 3.5 (default=1)
 
   res@tiMainString         = " "
;  res@gsnCenterString      = cd_calendar(time,-3)




   y = 2010
   m = 5
   d = 26
   h = 0
   opt = 0
   units = "hours since 1900-01-01 00:00:00"
   date=ut_inv_calendar(y,m,d,h,0,0,units,opt)
   ndays = 5

   
   



   level = 1000
   var = "Z"
   scale = 1./98.

   do id = 0,ndays
     do ih = 0,3
       date2 = cd_calendar( date,-2)
       fili   =  "/tamrind/era/3D/" + date2 + ".nc"
       f      = addfile (fili, "r")
      ; dat := f->$var$(ih,{level},:,:)

       u := f->U(ih,{level},:,:)
       v := f->V(ih,{level},:,:)
       sf = u
       vp = u
       uv2sfvpf (u,v, sf,vp)   
       dat = sf
       dat = dat*1.e-6

       ;dat  = dat*scale
       ;dat@units ="dam"
       ;dat@long_name = "Z" 

       dataTime = dat@time
       dataTime@units = dat@timeunits
       res@tiMainString         = cd_calendar(dataTime,-3)
       
       plot    = gsn_csm_contour_map(wks,dat, res)
       
     end do
     
     date = date + 24
   end do
   
   end
