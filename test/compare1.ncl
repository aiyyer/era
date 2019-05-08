

begin



lat = 0.
lon = 10.

date = 20120701
hour = 00

date1 = date*100 + hour
dir1 = "/neem/jorussel/ERAI/variables/full_vars/"
file1 = "uwnd_era_2012.nc"
fnam = dir1 + file1
f=addfile(fnam,"r")
u1=f->uwnd({date1},:,:,:)

file1 = "vwnd_era_2012.nc"
fnam = dir1 + file1
f=addfile(fnam,"r")
v1=f->vwnd({date1},:,:,:)




date2 = date
dir2 = "/tamrind/era/data/all/" 
file2 = date2 + ".nc"
fnam = dir2+file2
f=addfile(fnam,"r")
u2=lonFlip(f->U(:,:,{-15:45},:))
v2=lonFlip(f->V(:,:,{-15:45},:))
printVarSummary(u2)



print ( u1({1000:100},{lat},{lon}) + " "  + u2(0,{1000:100},{lat},{lon}) )
print ( " " ) 
print ( v1({1000:100},{lat},{lon}) + " "  + v2(0,{1000:100},{lat},{lon}) )



printVarSummary(u1)
printVarSummary(u2)

times = u2&time
print(cd_calendar(times,-3))


end






