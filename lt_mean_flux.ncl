
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
begin

  fileName = "jas_flux_climo_1980_2010.nc"
  outFile = addfile(fileName, "c")

; list of variables that we need

  PARAM = (/"TTR","TSR","STR","SSR","SSHF","SLHF"/)
  
  ystart    =  1980
  yend      =  2010
  nvars     =    6
; choose the range of dates for the averaging over season
  Dstart  = 0701 ;daily data
  Dend    = 0930 ;daily data

  

;---------------------------------------------------------------------------------------------

    do ivar = 0, nvars-1

      print ( ivar + " " +  PARAM(ivar) )
      icount    = 0
      do iy = ystart,yend              
        
        sDate = iy*10000 +  Dstart
        eDate = iy*10000 +  Dend
        allTimes := yyyymmdd_time(iy,iy, "integer")
        TIME := allTimes({sDate:eDate})
        fils := "/typhoon/eradaily/" + TIME + ".nc"    
        in      := addfiles (fils, "r")
        ListSetType (in, "join")             ; concatenate or "merge" (default)
        
        dat := in[:]->$PARAM(ivar)$
;        printVarSummary(dat)
         
        datAve = dim_avg_n_Wrap(dat,0)
        if ( icount .eq. 0 ) then
          climo = datAve
          climo = 0.
        end if

        climo = (climo*icount + datAve )/(icount + 1.)
        print ( iy + " "  + icount + " " + datAve({0.},{180.}) + " " +climo({0.}, {180.} ))
	icount = icount + 1     
      end do ; loop over years

      print ( "Now writing to output file")
      outFile->$PARAM(ivar)$=climo
  
end do    ; loop over years

end


