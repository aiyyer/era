; reads the longterm daily average data and creates a synoptic
; climo by doing a running mean 
;
; ----------------------------------------------------------------
; This code is for data on a single level: e.g., dynamic tropopuase
; 
;
;
; 4x daily
;
;
; Last Updated:

;
;      Oct 5, 2020 :  synoptic_climo_4xdaily_runave.ncl
;
;      oct 12, 2020: now smooths each synoptic hour independently
;                    this is a more appropriate climo for each hour 
;
;      Nov 18, 2021: adapted for single level
;---------------------------------------------------------------

;load "../../ncl/codeTime_sub.ncl"
load "../../ncl/aiyyer_string_routines.ncl"
  
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl" 

begin
  
  N  = 3 ;  this does a N*2+1 day running average = 7 when N=3
  NN = N*2 + 1

  dh = 6  ; 6 hourly era interim data
  ih = 00
  mi = 00
  se = 00

; list of variables that we need
  variables = (/"PT", "U","V","Q", "Z", "PRES"/)
  variables = variables+"Climo"
  
; output file
  setfileoption("nc", "Format",  "NetCDF4")
  fileName = "/tamrind/climo/era/synoptic_DT_climo_4xdaily_smooth.nc"
  createFile= True
  if ( createFile ) then
    outFile = addfile(fileName, "c")
  else
    outFile = addfile(fileName, "w")
  end if
  
  
  
  do ivar = 0,0
    
    imon = 01	
    iday = 01
    units = "hours since 1-1-1 00:00:0.0"
    year = 1979 ; choose a non-leap year
    sdate = ut_inv_calendar(year,imon,iday,0,0,0,units,0)    
    ndays = 365
    times := new(ndays,typeof(sdate)) 
    times@units    = sdate@units
    times@calendar = sdate@calendar
    
    
    firstTime = True
    
    do id = 0,ndays-1      

      do ih = 0,18,6
        stime = cd_string(sdate,"%N%D%H")
        ;print ( id + " " + ih + " " +  tointeger(cd_calendar(sdate,-3)) + " " +  stime)   
        fileName = "/tamrind/climo/era/DT/daily4x/climo_dt_"+stime+".nc"

        inFile = addfile(fileName, "r")
        dat=inFile->$variables(ivar)$

        if ( firstTime ) then
          datArray := dat
          firstTime = False
        else
          datArray := array_append_record(datArray,dat,0)
        end if
        sdate = sdate + dh
      end do
    end do 
    
    datArray!0 = "time"
   ; printVarSummary(datArray)
   ; print(datArray&time + " " + cd_calendar(datArray&time,-3) )

    datArraySm = datArray
    datArraySm = datArray@_FillValue


    dimArray = dimsizes(datArray)
    ntimes = dimArray(0)
    dates = datArray&time

    do ih = 0,3
      opt = -1 ; opt < 0 : utilize cyclic conditions 
      datArraySm(ih:ntimes-3+ih-1:4,:,:)=runave_n_Wrap(datArray(ih:ntimes-3+ih-1:4,:,:),NN,opt,0)
     ; print ( cd_calendar(dates(ih:ntimes-3+ih-1:4),-3) + " " + datArray(ih:ntimes-3+ih-1:4,{40.},{50.}) + " " + datArraySm(ih:ntimes-3+ih-1:4,{40.},{50.}) )
    end do

    print(datArraySm&time + " " + cd_calendar(datArraySm&time,-3) +  " " + datArraySm(:,{40.},{50.})  +  " " + datArray(:,{40.},{50.}))

    
    exit
    
  end do
  print ("*********************************************************")
  print ("****Normal code termination******************************")
  print ("*********************************************************")
  
  


end


