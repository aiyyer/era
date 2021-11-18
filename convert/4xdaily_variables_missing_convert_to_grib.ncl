;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
;FOR USE WITH ERA INTERIM DATA
;
;
; NCSU Tropical dynamics (NTD)
; A. Aiyyer
; 12/01/2018
; This code is part of the ERA Interim analysis package at NTD
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

; the names of variables in the datafiles



  dirGrib = "/typhoon/era/daily/"

  hours = ispan(0,18,6)



  
  units = "hours since 1-1-1 00:00:0.0"

  ; list of variables that we need
  ;variables = (/"PV","T","Z","U","V","W","Q"/)
  variables = (/"U","V","T","Z","Q"/)

  nvar=5



  do iy = 2014,2014
    startDate = cd_inv_calendar(iy,01,01,0,0,0,units,0)
    endDate   = cd_inv_calendar(iy,04,01,0,0,0,units,0)
    print ( startDate + " " + startDate )
    dates = new(4,typeof(startDate) )
    dates@units = units

    ndays = 365
    if (isleapyear(iy)) then
      ndays=366
    end if

    ndays = 92

    date = startDate

    firstTime = True

    do id = 0,ndays-1
      dayId = cd_calendar(date,-2)
      fileName = "/tamrind/era/3D/"+dayId+".nc"         


      if (fileexists(fileName) ) then
        in  := addfile (fileName, "w")
      else
        print ( "nonexistant output file" + fileName + " Exit!")
        exit
      end if
      
      
      do ivar=0,nvar-1
        if (isfilevar(in, variables(ivar))) then
        print ( variables(ivar) + " was found for " + dayId )
        else
          print ( variables(ivar) + " was NOT found for " + dayId )
          varName = variables(ivar) + "_GDS4_ISBL"          
          
          ;print (date + " " + cd_calendar(date,-3))
          dates = date + hours
          ;print (dates + " " + cd_calendar(dates,-3))
          dateFil = cd_calendar(dates,-3)
      
          ;print(dates + " " + dateFil) 

          fils := dirGrib + "ei.oper.an.pl.regn128sc." + dateFil + ".aiyyer492315.grb"


          if (  variables(ivar) .eq. "U" .or.  variables(ivar) .eq. "V") then
            fils := dirGrib + "ei.oper.an.pl.regn128uv." + dateFil + ".aiyyer492315.grb"
          end if


          ;print(fils)

          inGrib   := addfiles (fils, "r")
          ListSetType (inGrib, "join")             ; concatenate or "merge" (default)
          
; now read the data 
          dat := inGrib[:]->$varName$  
          ;printVarSummary(dat)
            
          dat!0 = "time"
          dat&time = dates
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
          
          ;printVarSummary(dat)
          print ( dat&time + " " + cd_calendar(dat&time,-3) + " " + dat(0,{850.},{10.},{300.}) )
      
          print ( variables(ivar) + " Now writing to the file" + fileName)
          in->$variables(ivar)$=dat

          print (" " )
        end if
      end do      
      date = date+24.
    end do


    print ("----------------")

  end do



end


