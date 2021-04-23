; reads the longterm daily average data and creates a synoptic
; climo by doing a running mean
;
; first run longterm_climo_4xdaily.ncl
;
; 4x daily
;
;
; Last Updated:
;
;      Oct 5, 2020
;
;      oct 12, 2020: now smooths each synoptic hour independently
;                    this is a more appropriate climo for each hour 
;---------------------------------------------------------------

;load "../../ncl/codeTime_sub.ncl"
load "../../ncl/aiyyer_string_routines.ncl"
  
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl" 

begin
  


  ih = 00
  mi = 00
  se = 00

  ; list of variables that we need
  variables = (/"PV","T","Z","U","V","W","Q","PV"/)
  


; output file
  setfileoption("nc", "Format",  "NetCDF4")
  fileName = "/tamrind/climo/era/synoptic_climo_4xdaily_smooth.nc"
  createFile= False
  if ( createFile ) then
    outFile = addfile(fileName, "c")
  else
    outFile = addfile(fileName, "w")
  end if
  
  
  
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
    
    
    firstTime = 1
    
    do id = 0,ndays-1
      
      dd = tointeger(cd_calendar(sdate,-3))
      stime = cd_string(sdate,"%N%D")
      
      
      fileName = "/tamrind/climo/era/daily/climo_"+stime+".nc"
      inFile = addfile(fileName, "r")
      dailyClim=inFile->$variables(ivar)$

      ;print ( id + " " + fileName)
     ; print (dailyClim&time + " " + cd_calendar(dailyClim&time,-3)+" " + dailyClim(:,{500},{20},{320}) )




      if ( firstTime .eq. 1 ) then
        dims = dimsizes(dailyClim)
        nz = dims(1)
        ny = dims(2)
        nx = dims(3)
        firstTime=0
        nt = ndays*4
        print ("nt = " + nt)
        climSmooth := new ( (/4,ndays,nz,ny,nx/), typeof(dailyClim) )
        climSmooth!0 = "hour"
        climSmooth!1 = "day"
        climSmooth!2 = "level"
        climSmooth!3 = "lat"
        climSmooth!4 = "lon"
        climSmooth&level = dailyClim&level
        climSmooth&lat =   dailyClim&lat
        climSmooth&lon =   dailyClim&lon
        print ("Created climsSmoothArray")
        ;printVarSummary(climSmooth)
        deltaT  = new (4,typeof(sdate))
        dates = new(nt,typeof(dailyClim&time))

        dates@units = dailyClim&time@units
        ;printVarSummary(dates)
       
      end if


      itA = id*4
      itB = (id+1)*4-1
      ;print ( sdate + " " + cd_calendar(sdate,-3) + " " + itA + " " + itB )

      climSmooth(:,id,:,:,:) = (/dailyClim/)

      deltaT =  6.*fspan(0,3,4) + (/sdate/)
      dates(itA:itB)  = deltaT

     ; print (cd_calendar(dates(itA:itB),-3 ) + " " + climSmooth(:,id,{500},{20},{320}) )

      sdate = sdate + 24.  ; increment of hours

  end do


; now do a N day running average  
  N = 7 ; odd
  NN = (N-1)/2

  do ih = 0,3
    tdat = climSmooth(ih,:,{500},{20},{320})
    climSmooth(ih,:,:,:,:) = runave_n_Wrap(climSmooth(ih,:,:,:,:),N,0,0)
    ;print(tdat + " " +  climSmooth(ih,:,{500},{20},{320}) )
  end do
  

  climArray := new ( (/nt,nz,ny,nx/), typeof(dailyClim) )
  climArray!0 = "time"
  climArray!1 = "level"
  climArray!2 = "lat"
  climArray!3 = "lon"
  climArray&level = dailyClim&level
  climArray&lat = dailyClim&lat
  climArray&lon = dailyClim&lon
  climArray&time = dates
  do id = 0,ndays-1
      itA = id*4
      itB = (id+1)*4-1
      climArray(itA:itB,:,:,:) = (/climSmooth(:,id,:,:,:)/)
  end do


; done averaing over all years for this day
  nA = NN*4 
  nB = nt- 1 - nA
  
  print ( "Writing out to file" )
  outFile->$variables(ivar)$=climArray(nA:nB,:,:,:)
  
 

    print (  cd_calendar(climArray&time(nA:nB),-3) + " " + climArray(nA:nB,{500},{20},{320})) 
end do
  print ("*********************************************************")
  print ("****Normal code termination******************************")
  print ("*********************************************************")
  
  


end


