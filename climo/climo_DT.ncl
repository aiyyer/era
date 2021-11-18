; this code will create climo data based on 
; long term average. climo for each day 0,6,12 and 18z
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;
begin
;
  print(systemfunc("date"))
;  


  vars = (/"PT", "U","V","Q", "Z", "PRES"/)

  indir = "/tamrind/era/DT/"
  odir  = "/tamrind/climo/era/dt/"
  
  indir = "/share/aiyyer/hurricaneCourse/era_int_2pvu/data/"
  odir  = "/share/aiyyer/hurricaneCourse/era_int_2pvu/climo/"


  indir = "/tamrind/era/DT/"
  odir  = "/tamrind/climo/era/DT/daily4x/"
  
  year1 = 1980
  year2 = 2018


  mon1 = 1
  mon2 = 12


  
  do im = mon1, mon2
    print ( "month = " + im)
    do id = 1,days_in_month(2019,im) ; just use 2020 as a dummy year
      do ih = 0,18,6 
        outfile = "climo_dt_" + sprinti("%0.2i", im) +   sprinti("%0.2i", id) +    sprinti("%0.2i", ih) + ".nc"        
        ;print(im + " " + outfile)
	do ivar = 0,5
	varIn  = vars(ivar) + "_GDS4_PVL"
	varOut = vars(ivar) + "Climo" 

	;print (varIn + " " + varOut)
	
        icount  = 0.
        do iy = year1, year2        
          infile = indir + iy+  sprinti("%0.2i", im) +   sprinti("%0.2i", id) +    sprinti("%0.2i", ih) + ".nc"
          f=addfile(infile,"r")
          data = f->$varIn$

          if ( iy .eq. year1 ) then 
              climo := data
              ;printVarSummary(data)
            end if
          
            climo = climo*icount/(icount+1.) + data/(icount+1.)
            ;print( icount + " " + iy +" "  + climo(0,{40.},{40.}) + " " + data(0,{40.},{40.}) )
            icount = icount + 1.
        
        end do
        

        if ( ivar .eq. 0 ) then
          outF = addfile (odir+outfile, "c" )
        else
          outF = addfile (odir+outfile, "w" )
        end if
        outF->$varOut$ = climo
       
	end do	

      end do
    end do
  end do


  end



