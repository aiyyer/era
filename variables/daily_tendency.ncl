;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
;
; Reads daily ERA interim data and calculates the daily tendency fields
;--------------------------------------------------------------------------------------
; NCSU Tropical Dynamics
;
; A. Aiyyer 5.14.2019
;--------------------------------------------------------------------------------------
;
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load  "../../ncl/column_avg.ncl"


;
begin

;-----------------------------------------------------------------------------------------  
  ystart    =   1998
  nyears    =   17
  ndays     =   152


; derived variable
  variable = "ColAvgDse"

; the names of variables in the datafiles
  varName = variable

  dayLag = (/-24,0,24/)
;---------------------------------------------------------------------------------------------
  do iy = ystart,ystart+nyears-1 
    im = 06
    id = 02
    ih = 00
    mi = 00
    se = 00
    units = "hours since 1-1-1 00:00:0.0"
; for each year go from april to dec
    date = ut_inv_calendar(iy,im,id,ih,mi,se,units,0)
    
    dates = date + dayLag
    dates@units = units
    print(dates + " " + cd_calendar(dates,-2) )
    
    dateFils = cd_calendar(dates,-2)
    fileNames = "/tamrind/eradaily/2D_derived/" +dateFils+".nc"
    print(fileNames)

    in  := addfiles(fileNames, "r")
    ListSetType (in, "join")             ; concatenate or "merge" (default)

    dat   = in[:]->$varName$
    ;print(dates(1) + " " + cd_calendar(dates(1),-2) )


    datTend = dat(1,:,:)
    delete (in)
    datTend@long_name = "Tend(per/day) " + datTend@long_name
    outVar = "Tend"+varName
    
    do ntimes = 0,ndays-4
      
; now calculate the tendency
      datTend = (dat(2,:,:)-dat(0,:,:))/2.  ; units of per day
      ;print ( "ntimes = " + ntimes + " " + datTend({10.},{10.}))
; now write the tendency to the middle date
      dateFil = cd_calendar(dates(1),-2)
      print("will write " + dateFil)
      fileName = "/tamrind/eradaily/2D_derived/" +dateFil+".nc"
      out := addfile(fileName, "w")      
      out->$outVar$=datTend
      
; now read the next date and shift the data 
      dat(0:1,:,:) = dat(1:2,:,:)
      dates = dates + 24.          

      dateFil = cd_calendar(dates(2),-2)
      fileName = "/tamrind/eradaily/2D_derived/" +dateFil+".nc"
      print("will read  " + dateFil)

      in := addfile(fileName, "r")      
      dat(2,:,:) = in->$varName$
    end do  ; loop over day
  end do    ; loop over years
  
end


