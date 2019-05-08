

begin



lat = 0.
lon = 10.

date = 20120701
hour = 00

date1 = date*100 + hour
dir1 = "/neem/jorussel/ERAI/variables/wave_filt/"
dir1 = "/data3/jorussel/ERAI/variables/full_vars/"

file1 = "uwndnd_era_2012.nc"
fnam = dir1 + file1
f=addfile(fnam,"r")
u1=f->uwndnd({date1},:,:,:)

file1 = "vwndnd_era_2012.nc"
fnam = dir1 + file1
f=addfile(fnam,"r")
v1=f->vwndnd({date1},:,:,:)

print ( u1({1000:100},{lat},{lon}) + " "  + v1({1000:100},{lat},{lon}) )
printVarSummary(u1)
printVarSummary(v1)



end






