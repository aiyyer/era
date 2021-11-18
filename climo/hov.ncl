;=======================================================================
;
; NCSU Tropical and Large Scale Dynamics
;=======================================================================
;
; Code:
;===========================================================================

begin

dir = "/share/aiyyer/hurricaneCourse/era_int_2pvu/data/"
infile = "./wpac_cases.csv"

; what latitudes do we average over for the hovmoller?
minLat = 30.
maxLat = 40.


; range of days to plot relative to the reference date in the csv file
numDaysBack = 1
numDaysForw = 6
nTimes = (numDaysForw + numDaysBack + 1)*4 ; 4x daily data in era-interim

; read the csv file
lines = asciiread(infile,-1,"string")
delim = ","

latS  =  tofloat(str_get_field(lines(1:),2,delim))
lonS  =  tofloat(str_get_field(lines(1:),3,delim))
dateS =  tointeger(str_get_field(lines(1:),5,delim))
nameS =  str_get_field(lines(1:),4,delim)
;print(latS + " " + lonS + " " + dateS + " " + nameS)



do mainLoop = 0, dimsizes(latS)-1
	print(lonS(mainLoop) + " " +  latS(mainLoop) + " " + nameS(mainLoop))

	dateStorm  = dateS(mainLoop)
	nTimesBack = numDaysBack*4 
	nTimesForw = numDaysForw*4
; each frame is 6 hours apart in ERA interim
	pltName = nameS(mainLoop)
	pltType = "png"
	lat_spacing = 20   ; use integers here
	lon_spacing = 20
  

;--------------------------------------------------------------
;end user input
;--------------------------------------------------------------
	yyyymmddhh = dateStorm
	yyyy  = yyyymmddhh/1000000 
	hh    = yyyymmddhh - (yyyymmddhh/100)*100
	mmdd  = (yyyymmddhh -yyyy*1000000)/100              ; mmdd = yyyymmdd%10000
	mm    = mmdd/100
	dd    = mmdd-mm*100                        ; dd   = mmdd%100
	units  = "hours since 1900-01-01 00:00:00"
	time   = cd_inv_calendar(yyyy,mm,dd,hh,0,0,units, 0)
	time  = time - numDaysBack*24.0 


;---------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------
wks    = gsn_open_wks(pltType,pltName)
res_Theta                     = True     ; plot mods desired

gsn_define_colormap(wks,"MPL_PuOr")  ;  MPL_coolwarm   ; MPL_YlGnBu  MPL_PRGn

res_Theta@cnFillOn            =  True        ; turn on color fill
res_Theta@cnLinesOn           =  False; Turn off contour lines
res_Theta@cnLineLabelsOn      =  False       ; Turn off contour lines   
res_Theta@gsnDraw             = False        ; Don't draw plots
res_Theta@gsnFrame            = False        ; Don't advance frame
res_Theta@cnInfoLabelOn       = False                ; turn off info label

res_Theta@lbLabelBarOn = True
 

res_Theta@cnLevelSelectionMode = "ManualLevels"      ; manually set the contour levels with the following 3 resources
res_Theta@cnMinLevelValF  =  260.			; set the minimum contour level
res_Theta@cnMaxLevelValF  =  400.			; set the maximum contour level
res_Theta@cnLevelSpacingF =  5.0			; set the interval between contours
res_Theta@tiMainString         = " "


  
 do iTimes = 0,nTimes-1
   
   date = cd_calendar(time,-3)
 ;  print("Now plotting for date = " + date + " for storm " + nameS(mainLoop))
   
   
   fileName=dir + date + ".nc"
   f      = addfile (fileName, "r")
   
; read theta
   theta = f->PT_GDS4_PVL   ; the data is dimensioned time,lat,lon: (time = nt = 1)
   
  
 ; first average over the latitudes  	

 ;  datAve = dim_avg_n_Wrap( theta({latS:latN},:),0)

   if (iTimes.eq.0) then
	   hov := dim_avg_n_Wrap( theta(:,{minLat:maxLat},:),1)
   else
   	   hov := array_append_record (	hov, dim_avg_n_Wrap( theta(:,{minLat:maxLat},:),1), 0 )
   end if	
	   


;   res_Theta@gsnCenterString      = cd_calendar(time,-3)  

;   txres               = True                            
;   txres@txFontHeightF = .020             ; Set the font height
	     
;   hurri = gsn_add_text( wks, plot, "~F37~p~F",lonS(mainLoop),latS(mainLoop),txres ) 




   time = time + 6.0

end do	
	printVarSummary(hov)
  	plot = gsn_csm_hov(wks, hov, res_Theta)
	draw(plot)
	frame(wks)

	exit

exit


print ( " --------------------- " )

end do

end








;===================================================================
;===================================================================








