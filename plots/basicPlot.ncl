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
                                             ; INPUT
   diri   = "./"                             ; input directory     
   fili   = "/tamrind/climo/era/synoptic_climo.nc"
   pltDir  = "./"                        ; directory for plot output
   pltName = "Z"                    ; netCDF name output
   pltType = "ncgm"                       ; send graphics to PNG file
 
   f      = addfile (fili, "r")

   time = f->time
   print(time + " " + cd_calendar(time,-3) )
   units = time@units


   print (units)




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
   
   res@mpMinLatF            = 0.     ; CMORPH limits [approx]
   res@mpMaxLatF            = 60.
   
   res@mpMinLonF            = -160.     ; CMORPH limits [approx]
   res@mpMaxLonF            =  -30.
   
   res@mpFillOn             = False
   

;   res@lbOrientation        = "vertical"   ; vertical label barb's
;   res@lbLabelFontHeightF   = 0.012        ; change font size
;   res@pmLabelBarWidthF     =  0.1     
;   res@pmLabelBarOrthogonalPosF = -0.01    ; move a bit to left



  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = 680			; set the minimum contour level
  res@cnMaxLevelValF  = 1200.			; set the maximum contour level
  res@cnLevelSpacingF = 4.			; set the interval between contours


;  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
;  res@cnMinLevelValF  = -40			; set the minimum contour level
;  res@cnMaxLevelValF  =  40.			; set the maximum contour level
;  res@cnLevelSpacingF = 2.			; set the interval between contours

  
   
   res@tiMainString         = " "
;   res@gsnCenterString      = cd_calendar(time,-3)




   y = 1979
   m = 5
   d = 3
   h = 0
   
   opt = 0
   dat := f->Z(:,{400.},:,:)


   date=ut_inv_calendar (y,m,d,h,0,0,units,opt)
 
   do id = 0,4
     
     dat := f->Z({date},{400.},:,:)
     dat  = (dat*.1)/9.8 ;in dam 
     dat@units ="dam"
     dat@long_name = "Z" 
     
     print ( date + " " + cd_calendar(date,-3) + " " + dat@time + " " + dat({20.},{20.}) )
     
     res@tiMainString         = cd_calendar(date,-3)
     
     plot    = gsn_csm_contour_map(wks,dat, res)

     date = date + 24

   end do

   
   
   end
