;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
; ERA INTERIM DATA
;
; This program creates daily accumulated fluxe (watts/m-sq) of radiative, surface sensible
; and surface latent heat
;
; The radiative flixes ae: Surface longwave and shortwave; and top  of the atmosphere
; longwave and shortwave
;
;
; NCSU Tropical dynamics (NTD)
; A. Aiyyer
;
; This code is part of the ERA Interim analysiis package at NTD
;
;=========================================================================================
;
;
;
;Notes
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
begin


; list of variables that we need
  varFile = (/"ttr_179","tsr_178","str_177","ssr_176","sshf_146","slhf_147"/)
; what are the filenames called? set the prefix here
  variables = (/"TTR","TSR","STR","SSR","SSHF","SLHF"/)
; the names of variables in the datafiles
  varName = variables + "_GDS4_SFC"
  
  ystart    = 1980
  nyears    = 1
 ; ndays     =   30 ;214
  nvars     =    6


;---------------------------------------------------------------------------------------------
    do iy = ystart,ystart+nyears-1

    do ivar = 0, nvars-1
     fil := systemfunc("ls /ecmwf/flux/ei.oper.fc.sfc.regn128sc." + varFile(ivar) +"."+iy +"*" )
     print (fil)
     print (" ")
     in   := addfile (fil, "r")
; now read the data 
      dat := in->$varName(ivar)$      
      dat!0 = "time"
      dat!1 = "fh"
      dat!2 = "lat"
      dat!3 = "lon" 	


      dates := in->initial_time0_hours

      ;printVarSummary(dat)
      ;print( cd_calendar(dat&time,-3))
      ;print(dat&fh)
     
; array dat has the flux data in it
; the data is actually accumulated forecast made from 2 initial times
; 

; 
     dimDat = dimsizes(dat)
     ndays  := dimDat(0)/2	
     datOut := dat(0:ndays-1,0,:,:)
;     printVarSummary(datOut)
      

    do iday = 0,ndays-1
       id0  = iday*2
       id12 =  id0+1 

; to get the accumulated flux for each day, add the 12 h forecast for both 0 and 12 hour
; initializations
     datOut(iday,:,:) = dat(id0,1,:,:) + dat(id12,1,:,:) 

; set the date of the output to 00 z of each day
; but first redefine the date relative to hours since "hours since 1-1-1 00:00:0.0"
     datOut&time(iday) = cd_convert( dates(id0), "hours since 1-1-1 00:00:0.0")

     ;print(iday + " " + cd_calendar(datOut&time(iday),-3)  + " " + cd_calendar(dat&time(id12),-3) )

     ;print(iday + " " + cd_calendar(datOut&time(iday),-3) )yy
    end do	




    datOut&time@units = "hours since 1-1-1 00:00:0.0"
    printVarSummary(datOut)

; now open the file and write the data
; for now write april to dec data since thats what we have for other variables 
; Aug 7, 2018 Aiyyer
    
    do iday = 91,ndays-1
  
      dateFil := cd_calendar(datOut&time(iday),-2)
      fileName = "/typhoon/eradaily/"+dateFil+".nc" 
      outFile = addfile(fileName, "w")
      outFile->$variables(ivar)$=datOut(iday,:,:)
      print ( iday + " " + dateFil )
      
    end do
    
  end do ; loop over variables
end do    ; loop over years

end


