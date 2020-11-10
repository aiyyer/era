; reads daily era interim data and creates a synoptic
; climo for each day of the year
;
; 4x daily
;
;
; Last Updated:
;
;      Oct 5, 2020
;---------------------------------------------------------------

;load "../../ncl/codeTime_sub.ncl"
load "../../ncl/aiyyer_string_routines.ncl"
  
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl" 

begin
  level = 500
  ystart    = 1980
  nyears    =  35

  ih = 00
  mi = 00
  se = 00

  ; list of variables that we need
  variables = (/"Z","U","V","W","Q","PV"/)
  nvar=8


; output file

  lat = 40.
  lon = 300.

  firstTime = True


  do ivar = 0,0

    imon = 04	
    iday = 01
    units = "hours since 1-1-1 00:00:0.0"
    year = 1979 ; choose a non-leap year
    sdate = ut_inv_calendar(year,imon,iday,0,0,0,units,0)
    
    ndays = 265
    times := new(ndays,typeof(sdate)) 
    times@units    = sdate@units
    times@calendar = sdate@calendar
    


    do id = 0,ndays-1

      print ( sdate + " " + cd_calendar(sdate,-3) )      
      
      dd = tointeger(cd_calendar(sdate,-3))
      stime = cd_string(sdate,"%N%D")

      fileName = "/tamrind/climo/era/daily/climo_debug"+stime+".nc"
      outFile = addfile(fileName, "c")

;---------------------------------------------------------------
      ic = 0.      
      
      do iy = ystart,ystart+nyears-1
        date = cd_calendar(sdate,-5) 
        filDat = ymd_string(iy,date(0,1),date(0,2))        
        fil = "/tamrind/era/3D/"+ filDat  +".nc" 
        
        
        in  := addfile (fil, "r")
        dat := in->$variables(ivar)$(:,{level},{lat},{lon})
        ;printVarSummary(dat)
       
        ;print ( dat&time(0) + " " +  cd_calendar( dat&time(0),-3) + " " +  dat&time(3) + " " +  cd_calendar( dat&time(3),-3))
        
        
; the attribute time is causing trouble later when data is accessed
; in other programs. delete it. we do not need this since we are
; defining time as one of the array indices
        
       ; delete(dat@time)
       ; delete(dat@time_units)
        
        
        if (firstTime) then
          clim := dat
          clim = 0.0
          dims = dimsizes(clim)
          nh=dims(0)
         
          if ( nh .ne. 4 ) then
            print ( "nh should be 4. But found = " + nh )
            print ( "exit")
            exit
          end if
          firstTime = False
        end if        

      clim = clim*ic/(ic+1.) + dat/(ic+1.)
      print ( id + " " + ic + " " + filDat + " "  + clim(0) + " " + dat(0)+ " "  + clim(3) + " " + dat(3) )
      ic=ic + 1.
    end do
    print ( " ic = " + ic + " " + cd_calendar(clim&time(0),-3) )


    clim&time =  6.*fspan(0,3,4) + sdate
    clim&time@units = sdate@units
;---------------------------------------------------------------
; done averaing over all years for this day
    print ( "Writing out to file" )
    printVarSummary(clim)
    outFile->$variables(ivar)$=clim   
    exit

    sdate = sdate + 24.  ; increment of hours
  end do
  

end do
  print ("*********************************************************")
  print ("****Normal code termination******************************")
  print ("*********************************************************")
  
  
  
  climAll&time = times

; now do a N day running average
  
  N = 5 ; odd
  NN = (N-1)/2
  climAll := runave_n_Wrap(climAll,5,0,0) 
  yend = ystart + nyears-1
  
  climAll@info = "Synoptic climo. Years averaged = " + ystart + " to " + yend
  
  climAll@long_name = climAll@long_name + " 5 day smooth"
  
  
  
; now write to file
  climAll&time = times

	print ( "wrote data for " + variables(ivar)) 
end


