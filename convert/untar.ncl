;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
; Notes
;
; Reads the 4x daily ERA grib files and writes to netcdf files
;
;
;
; NCSU Tropical Dynamics 
; A. Aiyyer
; 08/2018
;
; 03/2021 : ver 2 for new PV and Omega data that are in 
;           consolidated files
; 
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
begin


; list of variables that we need
  variables = (/"PV"/)

; the names of variables in the datafiles
  varName = variables + "_GDS4_ISBL"


  dir = "/typhoon/era/daily/"

  files = systemfunc("ls " + dir + "*.tar")


  nfiles = dimsizes(files)

  do i = 1, nfiles-1
     system ( "tar -xvf " + files(i) )
     print ( i + " " + files(i) )
  end do

  end