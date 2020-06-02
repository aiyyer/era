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
           


   fili   =  "/tamrind/eradaily/3D/20100531.nc"
   pltName = "Ttest"                         ; netCDF name output
   pltType = "ncgm"                      ; send graphics to PNG file
   f      = addfile (fili, "r")


   wks    = gsn_open_wks(pltType,pltName)
   res                      = True     ; plot mods desired
   ;res@cnFillPalette   = "GMT_cool"   ; change the color palette

   cmap = read_colormap_file("precip2_17lev")
   res@cnFillPalette = cmap(::-1,:)     ; reverse color map
   
;   res@gsnMaximize          = True     ; make ps/eps/pdf large
 
   res@cnFillOn             = False    ; turn on color fill
   res@cnFillMode           = "RasterFill"         ; Raster Mode
   res@cnLinesOn            =  True       ; Turn off contour lines
   res@cnLineLabelsOn       =  True       ; Turn off contour lines
   
   res@mpMinLatF            =  0.     ; CMORPH limits [approx]
   res@mpMaxLatF            =  30.
   
   res@mpMinLonF            =  40.     ; CMORPH limits [approx]
   res@mpMaxLonF            =  80.
   
   res@mpFillOn             = False
   

;   res@lbOrientation        = "vertical"   ; vertical label barb's
;   res@lbLabelFontHeightF   = 0.012        ; change font size
;   res@pmLabelBarWidthF     =  0.1     
;   res@pmLabelBarOrthogonalPosF = -0.01    ; move a bit to left



;  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
;  res@cnMinLevelValF  = -10			; set the minimum contour level
;  res@cnMaxLevelValF  =  40.			; set the maximum contour level
;  res@cnLevelSpacingF =  2.			; set the interval between contours

  
   
   res@tiMainString         = " "
;   res@gsnCenterString      = cd_calendar(time,-3)


 
     
   dat := f->T({850.},:,:)
   printVarSummary(dat)

;   dat  = dat*1.e7

   dat@units ="10 PVU"
   
;   print ( date + " " + cd_calendar(date,-3) + " " + dat@time + " " + dat({20.},{20.}) )
;   res@tiMainString         = cd_calendar(date,-3)
   
   plot    = gsn_csm_contour_map(wks,dat, res)
   
   
   
   end
