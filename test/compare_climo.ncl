; compares the climo files created using monthly, daily and 4xdaily files


begin


dir = "/typhoon/projects/data/climo/era/"
file1 = "monthly_to_jas_climo.nc"
fil = dir + file1
in   := addfile (fil, "r")
U1 = in->U


file2 ="daily_to_jas_climo.nc"
fil = dir + file2
in   := addfile (fil, "r")
U2 = in->U


file3 = "daily4x_to_jas_climo.nc"
fil = dir + file3
in   := addfile (fil, "r")
U3 = in->U



diff1 = U1-U2
diff2 = U1-U3
diff3 = U2-U3

print (avg(diff1) + " " + avg(diff2) + " " + avg(diff3) )

end
