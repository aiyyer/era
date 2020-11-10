; code to extract data from ERA files and create yearly files
;
;
;
; NCSU Tropical Dynamics
; A. Aiyer NOV 10, 2020
;
;
;
; Notes: This version is for creating U,V VOR and DIV data for Robert VDD
;
;=================================================================================


begin

  units = "hours since 1-1-1 00:00:0.0"
; list of variables that we need

  level = 850

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
      fileName = "/tamrind/era/3D/"+dayId+".nc"  ;+"_"+variables(ivar)+".nc"  
      
      
      in  := addfile (fileName, "r")
      U  := in->U(:,{850},::-1,:)
      V  := in->U(:,{850},::-1,:)
      
      VOR := U
      DIV := V
      
      VOR@long_name = "Vorticity"
      DIV@long_name = "Divergence"
      VOR@units = "s**-1"
      DIV@units = "s**-1"   
      
      uv2vrdvf (U,V,VOR,DIV)

      if (firstTime) then
   
        lat   = U&lat
        lon   = U&lon
        hours = U&time
	nlat  = dimsizes(lat)  
	nlon  = dimsizes(lon)      
        ntime = ndays*4
        diro = "/lotus/projects/data/robert/"                     ; Output directory
        filo = diro+ "ERAi_U_V_"+iy+".nc"            ; Output file        
        if (isfilepresent (filo)) then
          print("Output file already present. Please check. Exiting code")
          exit
        end if
	fout  = addfile (filo, "c")  ; open output file
        setfileoption(fout,"DefineMode",True)
        dimNames = (/"time", "lat", "lon"/)  
	dimSizes = (/ -1   ,  nlat,  nlon/) 
	dimUnlim = (/ True , False, False/)   
	filedimdef(fout,dimNames,dimSizes,dimUnlim) 
        filevardef(fout, "lon"  ,typeof(lon),getvardims(lon)) 
        filevardef(fout, "lat"  ,typeof(lat),getvardims(lat)) 
        filevardef(fout, "time"  ,typeof(hours),getvardims(hours)) 

        fout->U=U
        fout->V=V
        fout->VOR=VOR
        fout->DIV=DIV


        firstTime = False
      end if


      print ( id + " " + cd_calendar(date,-2) )
      
      T1 = id*4 
      T2 = T1 + 3

      fout->time(T1:T2) =U&time
      fout->U(T1:T2,:,:)=(/U/)  
      fout->V(T1:T2,:,:)=(/V/)  
      fout->VOR(T1:T2,:,:)=(/VOR/)  
      fout->DIV(T1:T2,:,:)=(/DIV/)  

    

      date = date+24.
    end do
   
  end do
  

end
