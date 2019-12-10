

begin
; define the domain bounds
; latS and latN are for the edges of the plot
  latS = -5.
  latN = 30.
;
; lonW and lonE define the section within which we average data
; 
  lonW =   0.
  lonE =   7.
  lonC = .5*( lonW + lonE )

  eraDir = "/home/anant/data100/era/"

  nTimes = 120
  year = 2000
  month = 7
  day   = 1
  hour  = 0
  units = "hours since 1900-01-01 00:00:00"
  date = dble2flt(cd_inv_calendar(year,month,day,hour,0,0,units, 0))
  print (date)


;
;-------------------------------------------------------------------
;-------------------------------------------------------------------

  wks = gsn_open_wks("ncgm","t.cx")               ; open a ps file
  res                         = True             ; plot mods desired
  gsn_define_colormap(wks,"WhiteYellowOrangeRed")
  
  
  res@gsnAddCyclic  = False
  res@gsnContourNegLineDashPattern = 1       ; sets negative contours to dash pattern 1
  res@gsnContourZeroLineThicknessF = 0.        ; sets thickness of zero contour to 3.5 (default=1)
  
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       =    0.               ; set min contour level
  res@cnMaxLevelValF       =    2.                 ; set max contour level
  res@cnLevelSpacingF      =   .2           ; set contour spacing
  
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnFillOn            = True          ; turn on/off color
  res@gsnSpreadColors     = True            ; spread out color table
  res@cnLinesOn           = False           ; on/off contour lines
  res@gsnLeftString       = " "         ; change left string
  res@gsnRightString      = " "         ; assign right string

  res@cnLineThicknessF     = 1                ;  line thickness
  res@cnInfoLabelOn   = False                      ; turn off contour label
  res@gsnAddCyclic  = False
  
  res@vpXF            = 0.13                        ; change x-scale
  res@vpWidthF        = 0.75                        ; change height and width 
  res@vpHeightF       = 0.45
  

;-------------------------------------------------------------------
;-------------------------------------------------------------------
;



  

 do itimes = 0,24 ;nTimes-1

    date2 = cd_calendar( date,-3)
    print (itimes + " " + date2 )
    eraFil = eraDir + date2 + ".pv.grib"
    f     = addfile(eraFil, "r")
        
    PV := lonFlip(f->PV_GDS4_ISBL({900:150},{latS:latN},:))
 

    
    PV!0 = "level"
    PV!1 = "lat"
    PV!2 = "lon"
    PV = PV*1.e6
    p=tofloat(PV&level)
    p=p*100.
    p@units = "Pa"
    print (p)
    exit
    pt = pot_temp(p, t, 0, False)  ; dim=0

    PVAVE := dim_avg_n_Wrap(PV(:,:,{lonW:lonE}),2)
    res@gsnCenterString = date2 + " " 
    plotA  = gsn_csm_pres_hgt(wks,PVAVE, res ) 


    
    plotB  = gsn_csm_pres_hgt(wks,PVAVE, res ) 

    
    draw(plotA)
    frame(wks)
   
    date = date + 6.0
  end do



  
end

