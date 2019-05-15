;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;
;FOR USE WITH ERA INTERIM DATA
;
; This program creates daily accumulated flux (watts/m-sq) of radiative, surface sensible
; and surface latent heat
;
; The radiative fluxes ae: Surface longwave and shortwave; and top  of the atmosphere
; longwave and shortwave
;
;
; NCSU Tropical dynamics (NTD)
; A. Aiyyer
; 12/01/2018
; This code is part of the ERA Interim analysiis package at NTD
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


; list of variables that we need
  varFile = (/"ttr_179","tsr_178","str_177","ssr_176","sshf_146","slhf_147"/)


; Data downloaded from NCAR/DSS
; what are the filenames called? set the prefix here
  variables = (/"TTR","TSR","STR","SSR","SSHF","SLHF"/)
; the names of variables in the datafiles
  varName = variables + "_GDS4_SFC"
  
  ystart    = 1998
  nyears    = 18
  nvars     =  6




  units = "hours since 1-1-1 00:00:0.0"
  
;---------------------------------------------------------------------------------------------
; data is in yearly files from 1980 to 2010. Thereafter it is in monthly files
;
  do iy = ystart,ystart+nyears-1
    ndays = 366
    date = ut_inv_calendar(iy,1,1,0,0,0,units,0)

    do iday = 0,ndays-1
      dateFil := cd_calendar(date,-2)
      fileName = "/tamrind/eradaily/2D/"+dateFil+".nc" 
      f = addfile(fileName, "r")	
      
      do ivar = 1,nvars-1
        
        if ( isfilevar(f,variables(ivar)) ) then
          ;dat=f->$variables(ivar)$
          ;print ( iday + " " + dateFil + " " + variables(ivar) + " " + dat({10.},{340.}) )
        else
          print ( iday + " " + dateFil + " " + variables(ivar) + " is missing")
        end if
      end do  ; loop over variables
      date = date + 24.

    end do
    print ( " " ) 
  end do    ; loop over years
  
  end
  
  
