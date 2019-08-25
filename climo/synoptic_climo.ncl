; reads daily era interim data and creates a synoptic
; climo for each day of the year
;
;

;load "../../ncl/codeTime_sub.ncl"
load "../../ncl/aiyyer_string_routines.ncl"
begin

  
  ystart    = 1980
  nyears    =  35

  ih = 00
  mi = 00
  se = 00

  ; list of variables that we need
  variables = (/"Mse","Dse","Q","Z","T","PV","V","U","W"/)
  nvar=8

  fileName = "synoptic_climo.nc"
  setfileoption("nc", "Format",  "NetCDF4")
  outFile = addfile(fileName, "c")

  
  units = "hours since 1-1-1 00:00:0.0"

  year = 1979 ; choose a non-leap year


  firstTime = True


  do ivar = 3,3
    imon = 05
    iday = 01
    sdate = ut_inv_calendar(year,imon,iday,0,0,0,units,0)

    ndays = 213
    times = new (ndays,typeof(sdate)) 

    print ( cd_calendar(sdate,-3) )
   
    do id = 0,ndays-1

;---------------------------------------------------------------
      ic = 0.      
      do iy = ystart,ystart+nyears-1
        date = cd_calendar(sdate,-5) 
        filDat = ymd_string(iy,date(0,1),date(0,2))
      
        fil = "/tamrind/eradaily/3D/"+ filDat  +".nc" 
        in   := addfile (fil, "r")
        dat := in->$variables(ivar)$      

        if (firstTime) then
          clim = dat
          clim = 0.0
      
          dims = dimsizes(clim)
          nz=dims(0)
          ny=dims(1)
          nx=dims(2)

          climAll = new( (/ndays,nz,ny,nx/), typeof(clim) )

          climAll!0 = "time"
          climAll!1 = "level"
          climAll!2 = "lat"
          climAll!3 = "lon"
          
          climAll&level = clim&level
          climAll&lat  = clim&lat
          climAll@long_name = clim@long_name
          climAll@_FillValue = clim@_FillValue
          climAll@units = clim@units
          climAll&lon = clim&lon
          
          firstTime = False
        end if        
        clim = clim*ic/(ic+1.) + dat/(ic+1.)
        print ( ic + " " + filDat + " "  + clim(0,20,20) + " " + dat(0,20,20) )
        ic=ic + 1.
      end do
      print ( " " )
;---------------------------------------------------------------
; done averaing over all years for this day


      times(id) = sdate
      climAll(id,:,:,:) = clim
     
      sdate = sdate + 1
    end do
 



; now do a N day running average

    N = 5 ; odd
    NN = (N-1)/2
    climAll := runave_n_Wrap(climAll,5,0,0)

    yend = ystart + nyears-1
     
    climAll@info = "Synoptic climo. Years averaged = " + ystart + " to " + yend
 
    climAll@long_name = climAll@long_name + " 5 day smooth"
; now write to file
    climAll&time = times
    outFile->$variables(ivar)$=climAll(NN:ndays-NN-1,:,:,:)


  end do


  print ("*********************************************************")
  print ("****Normal code termination******************************")
  print ("*********************************************************")

end


