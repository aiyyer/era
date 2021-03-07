;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
;
; Reads the 4x daily ERA grib files and writes to netcdf files
;
;
;
; NCSU Tropical Dynamics 
; A. Aiyyer
; 08/2018
;
; 03/2021 : ver 2 for new PV and Omega data
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
  variable = "PV"

; the names of variables in the datafiles
  varName = variable + "_GDS4_ISBL"


  dir = "/typhoon/era/daily/pv/"



  ystart    = 1980
  nyears    = 1  
  im = 1
  id = 1
  ih = 00
  mi = 00
  se = 00
  units = "hours since 1-1-1 00:00:0.0"
  hours = ispan(0,18,6)

;---------------------------------------------------------------------------------------------
  do iy = ystart,ystart+nyears-1
    dateS := ut_inv_calendar(iy,im,id,ih,mi,se,units,0)
    date = new(4,typeof(dateS) )

    date = dateS
    date = dateS + hours

    print (date + " " + cd_calendar(date,-3))

    ndays = 365
    if (isleapyear(iy)) then
      ndays=366
    end if

    do ntimes = 0,ndays-1
      dateFil = cd_calendar(date,-3)
      
      print(date + " " + dateFil) 
      fils := dir + "ei.oper.an.pl.regn128sc." + dateFil + ".aiyyer474689.grib"
      
      
      
      
      in   := addfiles (fils, "r")
      ListSetType (in, "join")             ; concatenate or "merge" (default)
      
; now read the data 
      dat := in[:]->$varName$              
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
      
;        printVarSummary(dat)
;        print ( dat&time + " " + cd_calendar(dat&time,-3) )
      
      
; now open the file and write the data   
      dayId = dateFil(0)/100
      
      
      fileName = "/tamrind/era/3D/"+dayId+".nc" 
      if (fileexists(fileName) ) then
        outFile = addfile(fileName, "w")
        print ( "writing to the file" + fileName)
      else
        print ( "creating the file" + fileName)
        outFile = addfile(fileName, "c")
      end if
      outFile->$variable$=dat
      date = date + 24.   
      end do
      

  end do

  end