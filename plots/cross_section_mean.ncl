

begin
; define the domain bounds
; latS and latN are for the edges of the plot
  latS = -5.
  latN = 40.
;
; lonW and lonE define the section within which we average data
; 
  lonW =   0.
  lonE =   7.
  lonC = .5*( lonW + lonE )

  eraDir = "/home/anant/data100/era/"
  eraDir = "/typhoon/era/"


  year = 2000
  month = 6
  day   = 1
  hour  = 0
  units = "hours since 1900-01-01 00:00:00"
  dateB = dble2flt(cd_inv_calendar(year,month,day,hour,0,0,units, 0))

  month = 7
  day   = 9
  hour  = 18
  units = "hours since 1900-01-01 00:00:00"
  dateE = dble2flt(cd_inv_calendar(year,month,day,hour,0,0,units, 0))
  print (dateB + " " + dateE)

  dh = 6.

  nTimes = tointeger ( (dateE-dateB)/dh ) + 1
  print (nTimes)

  date = dateB



 do itimes = 0,nTimes-1

    date2 = cd_calendar( date,-3)

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

    eraFil = eraDir + date2 + ".geo.grib"
    f     = addfile(eraFil, "r")
    T := lonFlip(f->T_GDS4_ISBL({900:150},{latS:latN},:))
    T!0 = "level"
    T!1 = "lat"
    T!2 = "lon"
    PT = pot_temp(p, T, 0, False)  ; dim=0

 
    PVAVE := dim_avg_n_Wrap(PV(:,:,{lonW:lonE}),2)
    PTAVE := dim_avg_n_Wrap(PT(:,:,{lonW:lonE}),2)


    if ( itimes .eq. 0 ) then
      PVM = PVAVE
      PTM = PTAVE
    end if
    PVM = PVM*itimes/(itimes+1) + PVAVE/(itimes+1)
    PTM = PTM*itimes/(itimes+1) + PTAVE/(itimes+1)
    print (itimes + " " + date2 + " " + max(PVM) + " " + max(PVAVE) )
    date = date + 6.0
  end do



  fileName = "mean1.nc"
  f = addfile(fileName, "c")
  f->PTM=PTM
  f->PVM=PVM

;
;-------------------------------------------------------------------
;-------------------------------------------------------------------

  wks = gsn_open_wks("pdf","t.cx")               ; open a ps file
  res                         = True             ; plot mods desired
  gsn_define_colormap(wks,"WhiteYellowOrangeRed")
  
  res@gsnAddCyclic  = False
  res@gsnContourNegLineDashPattern = 1       ; sets negative contours to dash pattern 1
  res@gsnContourZeroLineThicknessF = 0.        ; sets thickness of zero contour to 3.5 (default=1)
  
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       =  -.8               ; set min contour level
  res@cnMaxLevelValF       =    4.                 ; set max contour level
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
  

  resT = res
  resT@cnLinesOn           = True          ; on/off contour lines
  resT@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  resT@cnMinLevelValF       =    260.               ; set min contour level
  resT@cnMaxLevelValF       =    380.                 ; set max contour level
  resT@cnLevelSpacingF      =      4.           ; set contour spacing
  resT@cnFillOn            = False          ; turn on/off color

  res@lbLabelBarOn = False
    res@gsnCenterString = "06/01-07/09" 
    plotA  = gsn_csm_pres_hgt(wks,PVM, res ) 
    plotB  = gsn_csm_pres_hgt(wks,PTM, resT ) 

    overlay(plotA,plotB)
    draw(plotA)
    frame(wks)
;-------------------------------------------------------------------
;-------------------------------------------------------------------
;



  




  
end

