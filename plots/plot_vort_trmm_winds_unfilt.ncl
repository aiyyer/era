; PROGRAM:plot_vort_trmm_winds_unfilt.ncl
; Aiyyer
; Part of the AEW diagnostic package
;
;
; Plots Unfiltered data
; This program will plot relative vorticity and trmm rain at chosen level
; for the entire season (every 6 hours) using ERA interim and trmm
; It will also mark TC position using a hurricane symbol (uses IBTracs data)
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


  level2 = 925
  level1 = 850
  level0 = 600

  eraDir = "/typhoon/era/"
 ; eraDir = "/home/anant/data100/era/"

  iBFil = "/tamrind/ibtracs/Allstorms.ibtracs_wmo.v03r06.nc"
  ;iBFil = "/home/anant/data100/ibtracs/Allstorms.ibtracs_wmo.v03r10.nc"

  ; use the interpolated trmm file (see below for daily trmm file option that has been commented out)
  dir = "/home/anant/data100/trmm/" 
  dir = "/tamrind/trmm/carl/"
  trmmFile = dir + "trmm3b42.nc" ;4xdilay trmm data

  deltaTime = .25 ; delta T in days for this TRMM file
  ftr = addfile(trmmFile   ,"r")
  trmmTimeUnits = ftr->time@units
  print (trmmTimeUnits)
  
  
  do year = 2010,2010
    month  = 5
    day    = 26
    hour   = 0
    ntimes = 6*4


; helene 2006
;    month = 8
;    day   = 28
;    hour  = 0
;    ntimes = 80


; we will keep track of time by encoding it in the trmm date units
; the current ERA interim data does not have units for the dates
; the date is stamped on the file name
; commented out the units line below and replaced by trmmTimeUnits    
;    units = "hours since 1900-01-01 00:00:00"

    units = trmmTimeUnits
    date = dble2flt(cd_inv_calendar(year,month,day,hour,0,0,units, 0))
    print (date)
    
    
; in current form lat lon data for TC tracks is cumbersome to use. This is an inelegant
; but effective hack to get lat-lons for specific dates
; 

    iBf     = addfile(iBFil, "r")
    iBTimeUnits = iBf->time_wmo@units
    ibLats = ndtooned (short2flt(iBf->lat_wmo))
    ibLons = ndtooned (short2flt(iBf->lon_wmo))
    Filedates   = ndtooned (doubletofloat(iBf->time_wmo) )
    Filedates@units = iBTimeUnits
    ibDate = cd_convert(date,iBTimeUnits)
    base   = min ( ind( Filedates .ge. ibDate  ) )
;
    Filedates2 = Filedates (base:) 
    ibLats2   = ibLats (base:) 
    ibLons2   = ibLons (base:) 
;
    delete(ibLats)
    delete(ibLons)
    delete(Filedates)
    
    
    
;----------------------------------------------------------------------------------------------
    
    ncgmfile = "vort_trmm_winds_unfilt" + year
    
    wks = gsn_open_wks("ncgm" , ncgmfile)                      ; ps,pdf,x11,ncgm,eps
                                ; gsn_define_colormap(wks,"GMT_polar")
                                ; gsn_define_colormap(wks,"hotcolr_19lev")
    colors = (/"white","black", "white"    \
    ,"PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow"  \
    ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/)
    
    gsn_define_colormap(wks, colors)               ; generate new color map
    
    
    
    res                     = True
    
    
    res@gsnDraw             = False           ; don't draw
    res@gsnFrame            = False           ; don't advance frame
    res@cnInfoLabelOn       = False           ; turn off cn info label
    
    res@mpMinLonF          = 40.           ; choose a subregion
    res@mpMaxLonF          = 80.
    res@mpMinLatF          = -5.           ; choose a subregion
    res@mpMaxLatF          =  30.
    res@pmTickMarkDisplayMode = "Always"
    res@mpFillOn              =  False          ; turn off map fill
    res@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last

    
    
; vector resources
    ;res@vcRefAnnoOrthogonalPosF  = .1               ; move ref vector down
    ;res@vcRefAnnoOrthogonalPosF = -1.0   ; move ref vector block up

    res@vcRefAnnoOn = False ; remove the ref vector block
    res@vcRefMagnitudeF  = 10.0
    res@vcRefLengthF     = 0.03   
    res@vcGlyphStyle             = "CurlyVector"    ; turn on curly vectors
    res@vcMinDistanceF           = 0.017            ; thin vectors


    res@gsnScalarContour     = True               ; contours desired
    
    res@mpPerimOn              = True
    res@mpFillOn               = False
    res@mpLabelsOn             = False
    res@lbLabelBarOn = False

    
    res@cnFillOn             = True     ; turn on color fill
    res@cnLinesOn            = False    ; turn of contour lines
                                ;res@cnFillMode           = "CellFill"           ; Cell Mode
;    res@cnFillMode           = "RasterFill"         ; Raster Mode
    res@cnLineLabelsOn       =  False       ; Turn off contour lines
    res@cnLevelSelectionMode = "ExplicitLevels"              
    res@cnMissingValFillPattern = 0
    res@cnMissingValFillColor   = "black"
    
    
    res@cnLevels             = (/0.1,0.3,0.5,1,2,3,5,10,15,20/) ; "mm/3hr" 
    txres               = True   
    txres@txFontHeightF = .03             ; Set the font height

    
    
    resVor = True
    resVor@gsnDraw             = False           ; don't draw
    resVor@gsnFrame            = False           ; don't advance frame
    resVor@cnInfoLabelOn       = False           ; turn off cn info label
    
    resVor@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    resVor@cnMinLevelValF       =  2.0               ; set min contour level
    resVor@cnMaxLevelValF       =  20.                 ; set max contour level
    resVor@cnLevelSpacingF      =  1.0               ; set contour spacing
    resVor@cnFillOn             = False               ; turn on color for contours
    resVor@cnLinesOn            = True              ; turn off contour lines
    resVor@cnLineLabelsOn       = False              ; turn off contour line labels
    resVor@cnLineThicknessF= 1. 

    resP                     = True                ; modify the panel plot    
    resP@gsnPanelLabelBar    = True                ; add common colorbar
    resP@lbLabelFontHeightF  = 0.007               ; make labels smaller

                         


; ---------------Main loop over all times 
    
    
    do itimes = 0,ntimes
      

 ; these lines are for daily trmm files     
 ;     date0 = cd_calendar( date,-2)
 ;     dateArray = cd_calendar( date,0)
 ;     hh = "" + dateArray(0,3)
 ;     if ( dateArray(0,3) .lt. 10 ) then
 ;       hh = "0" + dateArray(0,3)
 ;     end if
 ;     trmmFil = "/typhoon/trmm/3b42/3B42." + date0 + "." +  hh + ".7A.nc"
 ;     ftr     = addfile(trmmFil, "r")
 ;     pcp = ftr->pcp
 ;---------------------------------------------------------------     

      pcp = ftr->rain({date},:,:)
      date2 = cd_calendar( date,-3)
;     print (itimes + " " + date0 + hh + " " + date2 )
      print (itimes + " " + date2 )
      
      eraFil = eraDir + date2 + ".uv.grib"
      f     = addfile(eraFil, "r")

; read the winds
      u1 = f->U_GDS4_ISBL({level0},:,:)
      v1 = f->V_GDS4_ISBL({level0},:,:)

      u2 = f->U_GDS4_ISBL({level1},:,:)
      v2 = f->V_GDS4_ISBL({level1},:,:)
      
      u3 = f->U_GDS4_ISBL({level2},:,:)
      v3 = f->V_GDS4_ISBL({level2},:,:)

      u1!0 = "lat"
      u1!1 = "lon"
      v1!0 = "lat"
      v1!1 = "lon"
      
      copy_VarMeta (u1,u2)
      copy_VarMeta (v1,v2)
      copy_VarMeta (u1,u3)
      copy_VarMeta (v1,v3)


      vr1 = uv2vr_cfd(u1,v1,u1&lat,u1&lon, 2) 
      vr1 = vr1*1.e5
      vr2 = uv2vr_cfd(u2,v2,u2&lat,u2&lon, 2) 
      vr2 = vr2*1.e5
      vr3 = uv2vr_cfd(u3,v3,u3&lat,u3&lon, 2) 
      vr3 = vr3*1.e5



     copy_VarMeta (u1,vr1)
     copy_VarMeta (u2,vr2)
     copy_VarMeta (u3,vr3)

; create vorticity  
    res@tiMainString         = " "
    res@gsnRightString = " "
    resVor@gsnLeftString  = " "
    resVor@gsnRightString = " "

;
    plot = new(3, "graphic")
;
    res@gsnLeftString  = level0 + " hPa"
    plot(0)   = gsn_csm_vector_scalar_map(wks,u1,v1,pcp(:,:),res)
    plotVor  = gsn_csm_contour(wks,vr1,resVor)
    overlay(plot(0),plotVor)
;
    res@gsnLeftString  = level1 + " hPa"
    plot(1)   = gsn_csm_vector_scalar_map(wks,u2,v2,pcp(:,:),res)
    plotVor  = gsn_csm_contour(wks,vr2,resVor)
    overlay(plot(1),plotVor)
;
    res@gsnLeftString  = level2 + " hPa"
    plot(2)   = gsn_csm_vector_scalar_map(wks,u3,v3,pcp(:,:),res)
    plotVor  = gsn_csm_contour(wks,vr3,resVor)
    overlay(plot(2),plotVor)
;
; now plot the location of the TC
; convert era date to ibtracs date
    ibDate = cd_convert(date,iBTimeUnits)
    print (date)
    print (ibDate)
    TCIndices  = ind( Filedates2 .eq. ibDate )

; TCIndices should have no missing values. If it has, then
; it is because no stroms present on this time
    
    if(any(ismissing(TCIndices))) then
                                ; SKIP
    else
      dims = dimsizes(TCIndices)
      ns = dims(0)    
      do j = 0,ns-1
        is = TCIndices(j)
        print ( itimes + " " + ibLons2(is) + " " + ibLats2(is) ) 
        hurri = gsn_add_text(wks,plot(0), "~F37~p~F",ibLons2(is),ibLats2(is), txres ) 
        hurri = gsn_add_text(wks,plot(1), "~F37~p~F",ibLons2(is),ibLats2(is), txres ) 
      end do
    end if

    resP@gsnPanelFigureStrings= (/"a","b"/) ; add strings to panel
    resP@amJust   = "TopLeft"
    resP@txString   = "V, Vorticity and TRMM " + date2
    gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot


    ;draw(plot)
    ;frame(wks)
    delete(TCIndices)

; in case of trmm data    deltaTime is in days
    date = date + deltaTime

    delete (vr1)
    delete (u1)
    delete (v1)

    delete (vr2)
    delete (u2)
    delete (v2)

    delete (vr3)
    delete (u3)
    delete (v3)


  end do
  
  delete ( Filedates2 )
  delete ( ibLats2)
  delete ( ibLons2)
end do


end

