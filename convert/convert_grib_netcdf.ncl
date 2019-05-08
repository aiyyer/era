;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
;
; Reads the 4x daily ERA grib files and creates 
;
; May 02; muissing data for months 1-4 need to fill them in
;
;
; NCSU Tropical Dynamics 
; A. Aiyyer
; 08/2018
;
; 
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
begin


; list of variables that we need
  variables = (/"V","U","Q","Z","T","W","PV"/)
; what are the filenames called? set the prefix here
  varFile = (/"uv","uv","hum","geo","geo","omega","pv"/)
; the names of variables in the datafiles
  varName = variables + "_GDS4_ISBL"
  
  ystart    = 2004
  nyears    = 1
  nvars     = 5   ; missing omega and PV for months 1-3
  
  im = 04
  id = 19
  ih = 00
  mi = 00
  se = 00
  units = "hours since 1-1-1 00:00:0.0"
  hours = ispan(0,18,6)
  
;---------------------------------------------------------------------------------------------
  do iy = ystart,ystart+nyears-1
    dateS := ut_inv_calendar(iy,im,id,ih,mi,se,units,0)
    printVarSummary(dateS)
    date = new(4,typeof(dateS) )

    date = dateS
    date = dateS + hours

    ;print (date + " " + cd_calendar(date,-3))
    ;exit

    ndays = 365
    if (isleapyear(iy)) then
      ndays=365
    end if

    ndays = 257
    do ntimes = 0,ndays-1
      dateFil = cd_calendar(date,-3)
      ;printVarSummary(dateFil)
      print(date + " " + dateFil) 

     
      do ivar = 0, nvars-1

        print ( ivar + " " + variables(ivar) )
        fils := "/typhoon/era/" + dateFil + "." +  varFile(ivar)  + ".grib" 
        ;print (fils)
        in   := addfiles (fils, "r")
        ListSetType (in, "join")             ; concatenate or "merge" (default)

; now read the data 
        dat := in[:]->$varName(ivar)$              
        dat!0 = "time"
        dat&time = date
        dat!1 = "level"
        dat!2 = "lat"
        dat!3 = "lon"
        dat@timeunits = units

        
        dims=dimsizes(dat)
        ntimee = dims(0)
        if ( ntimee .ne. 4 ) then           
          print ( "n times = " + ntimee + " STOP")
          exit
        end if	
        

       
; now open the file and write the data   
        dayId = dateFil(0)/100
        ;print (dayId)

        fileName = "/tamrind/era/data/all/"+dayId+".nc"  ;+"_"+variables(ivar)+".nc"
        if (fileexists(fileName) ) then
          outFile = addfile(fileName, "w")
          ;print ( "writing to the file" + fileName)
        else
          ;print ( "creating the file" + fileName)
          outFile = addfile(fileName, "c")
        end if
        outFile->$variables(ivar)$=dat
       
      end do ; loop over variables
      
     
      ;print ( date + " " + cd_calendar(date,-3))
      date = date + 24.   
      ;print ( date + " " + cd_calendar(date,-3))
      
    end do ; loop over day
  end do    ; loop over years
  
end


