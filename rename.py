#!/usr/bin/env python3.6

import os



print("hello")

path= "./../precip/"
path= "/ecmwf/precip/"
fils = os.listdir(path)

for f in os.listdir(path):
    src = path + f

    #dst = path + f[24:35] + "grib"
    #dst = path + f[32:39] + "grib"

    dst = path + f[24:35] + "grib"
    print (dst)

    #os.rename(src,dst)
