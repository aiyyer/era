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
  
  units = "hours since 1-1-1 00:00:0.0"

  ; list of variables that we need
  variables = (/"PV","W","T","Z","U","V","W","Q"/)
  nvar=8

  do iy = 1980,2015

    startDate = cd_inv_calendar(iy,01,01,0,0,0,units,0)
    endDate   = cd_inv_calendar(iy,12,31,0,0,0,units,0)
    print ( startDate + " " + startDate )

    ndays = 365
    if (isleapyear(iy)) then
      ndays=366
    end if

    date = startDate

    firstTime = True

    do id = 0,ndays-1
      dayId = cd_calendar(date,-2)
      fileName = "/tamrind/era/3D/"+dayId+".nc"         
      in  := addfile (fileName, "r")
      do ivar=0,7
        if (isfilevar(in, variables(ivar))) then
          ;print ( variables(ivar) + " was found for " + dayId )
        else
          print ( variables(ivar) + " was NOT found for " + dayId )
        end if
      end do      
      date = date+24.
    end do


    print ("----------------")

  end do



end


