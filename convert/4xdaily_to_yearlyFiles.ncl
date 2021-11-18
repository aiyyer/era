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
 

  ; list of variables that we need
  ;variables = (/"PV","T","Z","U","V","W","Q"/)
  variables   = (/"W","U","PV","T","Z","Q"/)

  nvar=1



  do iy = 2015,2015






    startDate = cd_inv_calendar(iy,01,01,0,0,0,units,0)
    endDate   = cd_inv_calendar(iy,12,31,0,0,0,units,0)
    print ( startDate + " " + startDate )    
    ndays = 365
    if (isleapyear(iy)) then
      ndays=366
    end if
    
    date = startDate
    
    firstTime = True

    do ivar=0,nvar-1
      do id = 0,ndays-1

        dayId  = cd_calendar(date,-2)
        inFile = "/tamrind/era/3D/"+dayId+".nc"         
        in := addfile (inFile, "r")
        dat = in->$variables(ivar)$
        

        if (firstTime) then
          dimS = dimsizes(dat)

          outFile = "/tamrind/era/3D/yearly/"+iy+".nc"

          setfileoption("nc","format","netcdf4")
          setfileoption("nc","headerReserveSpace",64000)
          setfileoption("nc","preFill",False)

          ctim = 1
          dim_names = (/"time","level","lat","lon"/)

;time dimension is unlimited, but currently set to 1.
          dim_sizes = (/ctim,dimS(1),dimS(2),dimS(3)/)
          dim_unlimited = (/True,False,False,False/)
          
          print("Defining dimension sizes to be " + dim_sizes)
          filedimdef(f,dim_names,dim_sizes,dim_unlimited)
          
          
          Define the chunk sizes:
          mtim = 1
          mlev = dims(1)/3
          mlat = dimS(2)/10
          mlon = dimS(3)/10
          chunk_sizes = (/mtim,mlev,mlat,mlon/)
          filechunkdimdef(f,dim_names,chunk_sizes,dim_unlimited)
          
          
          Define some file properties:
          atts = True
          atts@description = "4xdaily to yearly files by Aiyyer"
          atts@timestamp = systemfunc("date")
          atts@source = "ERA-Interim via NCAR RDA"
          print("Defining file attributes")
          fileattdef(f,atts)
          
          
          Define file variables:
          print("Defining file variables")
          filevardef(f,"time","float","time")
          filevardef(f,"level","float","level")
          filevardef(f,"lat","float","lat")
          filevardef(f,"lon","float","lon")


          filevardef(f,variables(ivar),"float",(/"time","level","lat","lon"/))
          
          
          Define file variables attributes:
          print("Defining file variable attributes")
          tatts = True
          tatts@long_name = time"
          tatts@units = "hours since 1-1-1 00:00:0.0"
          filevarattdef(f,"time",tatts)
          
          latatts = True
          latatts@long_name = "latitude"
          latatts@units = "degrees_north"
          filevarattdef(f,"lat",latatts)
          
          lonatts = True
          lonatts@long_name = "longitude"
          lonatts@units = "degrees_east"
          filevarattdef(f,"lon",lonatts)
           
          levatts = True
          levatts@long_name = "isobaric level"
          levatts@units = "hPa"
          filevarattdef(f,"level",levatts)
  
          waveatts = 0.0
          waveatts@long_name = "Sine Wave on the sphere"
          waveatts@units = "None"
          waveatts@_FillValue = 1e32
          filevarattdef(f,"wave",waveatts)
          
          
          filevarchunkdef(f, "wave", chunk_sizes)
          filevarcompressleveldef(f, "wave", 2)
          
          
          Create coordinate arrays:
          (Note lon and lat write out here, but time will write later.)
          
          print("Creating coordinate arrays")
          time = fspan(0,ntim-1,ntim)
          lat = fspan(-90,90,nlat)
          f->lat = (/lat/)
          lon = fspan(-180,180,nlon)
          f->lon = (/lon/)
          
   
          
          
          if (isfilepresent(theflnm)) then           
            f = addfile(theflnm,"w")
          else
            print ("creating file")
            f = addfile(theflnm,"c")
          end if
          
        end if
        
   
        ih1 = id*4
        ih2 = ih1 + 3

        f->$variables(ivar)$(ih1:ih2)  = dat

     
        
        print ( dat&time(0) + " " + cd_calendar(dat&time(0),-3) + " "  + dat(0,{500},{20.},{20.}) )
            
        date = date+24.
      end do
    end do           
      
    print ("----------------")
    
  end do
  
  
  
end


