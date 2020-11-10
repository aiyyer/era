; reads the longterm daily average data and plots a timeseries at a location
;
; 4x daily
;
;
; Last Updated:
;
;
;      oct 12, 2020: 
;---------------------------------------------------------------

;load "../../ncl/codeTime_sub.ncl"
load "../../ncl/aiyyer_string_routines.ncl"
  
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

begin
  

  level = 500.
  lat   = 40.
  lon   = 300.
  ih = 00
  mi = 00
  se = 00

  ; list of variables that we need
  variables = (/"Z","U","V","W","Q","PV"/)
  ivar = 0

; climo file
  fileName = "/tamrind/climo/era/synoptic_climo_4xdaily_smooth.nc"
  inFile= addfile(fileName, "r")
  
  

  print ( "reading file" )
  dat = inFile->$variables(ivar)$(::4,{level},{lat},{lon})
  datB = inFile->$variables(ivar)$(1::4,{level},{lat},{lon})

  printVarSummary(dat)
  printVarSummary(datB)

  times = dat&time

;---Start the graphics
  wks = gsn_open_wks("png","ts") ; send graphics to PNG file

;---Plotting options for time series plot
 

  res = True
  res@gsnMaximize = True
  res@vpWidthF    = 0.8
  res@vpHeightF   = 0.3

  res@tmXTOn      = False
  res@tmYLFormat  = "f"      ; remove trailing ".0"
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
    

  restick           = True
  restick@ttmFormat = "%N/%D %H:%M"

  time_axis_labels(times,res,restick)

  res@tiMainString       = "test"
  res@tiYAxisString      = variables(ivar)
  res@tiMainFontHeightF  = 0.025
  res@tiYAxisFontHeightF = 0.02

  plotA = gsn_csm_xy(wks,times,dat,res)
  plotB = gsn_csm_xy(wks,times,datB,res)

  overlay(plotA,plotB)
  draw(plotA)
  frame(wks)





  print ("*********************************************************")
  print ("****Normal code termination******************************")
  print ("*********************************************************")
  
  


end


