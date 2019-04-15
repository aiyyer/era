
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
; read the monthly average data and creates the long term climo
;
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
begin


  baseDir = "/typhoon/eramon/"
  prefix = "ei.moda.an.pl.regn128"
  fileName = "jas_era_climo_1980_2010.nc"
  outFile = addfile(fileName, "w")

; list of variables that we need

  VAR = (/"Z","U","V","W","Q","T","PV"/)
  
  PARAM = VAR + "_GDS4_ISBL_S123"
  ystart    =  1980
  yend      =  2010
  nvars     =    1


; define the averaging months
  nmon = 3
  mons = (/7,8,9/)


;---------------------------------------------------------------------------------------------

    do ivar = 0, nvars-1

      print ( ivar + " " +  PARAM(ivar) )
      icount    = 0.
      do iy = ystart,yend              
        
        TIME = mons
        TIME = ((iy*100 + mons)*100 + 01)*100
        ;print (TIME)
       

        
        if ( VAR(ivar) .eq. "U" .or. VAR(ivar) .eq. "V" ) then
        fils := baseDir + prefix + "uv." + TIME + ".aiyyer312469.grb"
        else
        fils := baseDir + prefix + "sc." + TIME + ".aiyyer312469.grb"
        end if
        ;print (fils)       

        in      := addfiles (fils, "r")
        ListSetType (in, "join")             ; concatenate or "merge" (default)
        
        dat := in[:]->$PARAM(ivar)$
        datAve = dim_avg_n_Wrap(dat,0)
        if ( icount .eq. 0 ) then
          climo = datAve
          climo = 0.
        end if

        climo = (climo*icount + datAve )/(icount + 1.)
        print ( iy + " " + icount + " " +  datAve({650.}, {0.}, {180.}) + " " +  climo({650.}, {0.}, {180.} ))
        icount = icount + 1.
     
      end do ; loop over years

      print ( "Now writing to output file")
      outFile->$VAR(ivar)$=climo
  
end do    ; loop over variables

end


