;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
;
; Reads the 4x daily ERA grib files and creates daily avg files in netcdf format
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
  variables = (/"PV","W","V","U","Q","Z","T"/)
; what are the filenames called? set the prefix here
  varFile = (/"pv","omega","uv","uv","hum","geo","geo","omega"/)


  variables = (/"W"/)
  varFile   = (/"sc"/)

; the names of variables in the datafiles
  varName = variables + "_GDS4_ISBL"
  
  ystart    = 2019
  nyears    = 1
  ndays     = 365
  nvars     = 1   ; missing omega and PV for months 1-3
  

;---------------------------------------------------------------------------------------------
  do iy = ystart,ystart+nyears-1
    
    im = 01
    id = 01
    ih = 00
    mi = 00
    se = 00
; the units should be the same as those in the 4x daily data files
    units = "hours since 1-1-1 00:00:0.0"
    
; for each year go from april to dec
    
    date = ut_inv_calendar(iy,im,id,ih,mi,se,units,0)
    
    do ntimes = 0,ndays-1
      dateFil = cd_calendar(date,-2)
      print(date + " " + dateFil)  
      first = False
      do ivar = 0,0       
        fils := systemfunc("ls /typhoon/era/daily/2019/*" + dateFil + "*" )
        print (fils)
        in   := addfiles (fils, "r")
        ListSetType (in, "join")             ; concatenate or "merge" (default)
; now read the data 
        dat := in[:]->$varName(ivar)$      
        delete(in)
        
; now average the data over the day
        datAve := dim_avg_n_Wrap(dat,0)
        datAve!0 = "level"
        datAve!1 = "lat"
        datAve!2 = "lon"
        
        datAve@time = date
        datAve@time_units = units
        delete(datAve@forecast_time)
        delete(datAve@initial_time)
        delete(datAve@forecast_time_units)
        
        dims=dimsizes(dat)
        ntimee = dims(0)
        if ( ntimee .ne. 4 ) then           
          print ( "n times = " + ntimee + " STOP")
          exit
        end if	
        
; now open the file and write the data        
        fileName = "/tamrind/eradaily/3D/"+dateFil+".nc"  ;+"_"+variables(ivar)+".nc"
        if ( first ) then
          system ("rm " + fileName)
          outFile = addfile(fileName, "c")
          first = False
        else
          outFile = addfile(fileName, "w")
        end if
        print ("writing to: " + fileName)
        outFile->$variables(ivar)$=datAve
      end do ; loop over variables

      date = date + 24.    
    end do ; loop over day
  end do    ; loop over years
  
end


