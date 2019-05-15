;
;
;
;


begin

  
  ystart    = 1998
  nyears    =   17

  ih = 00
  mi = 00
  se = 00

  ; list of variables that we need
  variables = (/"Mse","Dse","Q","Z","T","PV","V","U","W"/)
  nvar=8

  fileName = "/tamrind/eradaily/3Dclimo/jas.nc"
  fileName = "/typhoon/projects/data/climo/era/daily_to_jas_1998_2014climo.nc"
; system ("rm " + fileName)
  outFile = addfile(fileName, "w")


  do ivar = 2,nvar-1

    icount = 0.
    do iy = ystart,ystart+nyears-1 
      units = "days since 1-1-1 00:00:0.0"
      im = 07
      id = 01
      sdate = ut_inv_calendar(iy,im,id,ih,mi,se,units,0)
      im = 09
      id = 30
      edate = ut_inv_calendar(iy,im,id,ih,mi,se,units,0)
      
      ndays = tointeger(edate-sdate+1)
      print (iy + " " + sdate + " " + edate + " " + ndays)
      
      dateArray = fspan(sdate,edate,ndays)
      dateArray@units = units
      ;rint (cd_calendar(dateArray,-2))
      dates := cd_calendar(dateArray,-2)
      fils  := "/tamrind/eradaily/3D/"+ dates  +".nc" 
      ;fils  := "/tamrind/eradaily/3D_derived/"+ dates  +".nc" 

      ;print(fils)
      in   := addfiles (fils, "r")
      ListSetType (in, "join")             ; concatenate or "merge" (default)
; now read the data 
      dat := in[:]->$variables(ivar)$      
      delete(in)
      ;printVarSummary(dat)
      
; now average the data over all days of this year
      datAve := dim_avg_n_Wrap(dat,0)
      
      if ( iy .eq. ystart )
        datClim = datAve
      end if
      datClim = datClim*icount/(icount+1.) + datAve/(icount+1.)
      icount = icount + 1.

    end do
    printVarSummary(datClim)    
    outFile->$variables(ivar)$=datClim


  end do


  print ("*********************************************************")
  print ("****Normal code termination******************************")
  print ("icount = " + icount)
  print ("*********************************************************")

end


