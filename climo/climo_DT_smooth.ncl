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


  vars = (/"U","V","Q", "Z", "PRES"/)

  indir = "/tamrind/era/DT/"
  odir  = "/tamrind/climo/era/dt/"
  
  indir = "/share/aiyyer/hurricaneCourse/era_int_2pvu/data/"
  odir  = "/share/aiyyer/hurricaneCourse/era_int_2pvu/climo/"
  year1 = 1990
  year2 = 2018


  mon1 = 12
  mon2 = 12


  
  do im = mon1, mon2
    do id = 1,days_in_month(2020,im) ; just use 2020 as a dummy year
      do ih = 0,18,6 
        outfile = "climo_dt_" + sprinti("%0.2i", im) +   sprinti("%0.2i", id) +    sprinti("%0.2i", ih) + ".nc"
        
        print(im + " " + outfile)
        


	do ivar = 0,4


	varIn  = vars(ivar) + "_GDS4_PVL"
	varOut = vars(ivar) + "Climo" 

	print (varIn + " " + varOut)
	
        icount  = 0.
        do iy = year1, year2        
          infile = indir + iy+  sprinti("%0.2i", im) +   sprinti("%0.2i", id) +    sprinti("%0.2i", ih) + ".nc"
          f=addfile(infile,"r")
          data = f->$varIn$(0,:,:)

          if ( iy .eq. year1 ) then 
              climo := data
              printVarSummary(data)
            end if
          
            climo = climo*icount/(icount+1.) + data/(icount+1.)
            print( icount + " " + iy +" "  + climo({40.},{40.}) + " " + data({40.},{40.}) )
            icount = icount + 1.
        
        end do
        
        outF = addfile (odir+outfile, "w" )
        outF->$varOut$ = climo
       
	end do	

      end do
    end do
  end do


  end



