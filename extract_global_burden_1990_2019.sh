#!/bin/bash
#Main contributions:
#Anisbel Leon (leon@tropos.de) and Bernd Heinold (heinold@tropos.de)
base_path="/work/bb1005/b381361/my_experiments"
exp="ac3_arctic"
liste=$(ls -d ${base_path}/${exp}/${exp}_*.01_burden.nc)
var="burden_SS"
rm tmp_*
for i in $liste
do
fnm="${i%_*}"
dat=$(echo $fnm | cut -b 59-74)
#dat=$(echo $fnm | cut -b 59-72)
echo $fnm $dat

#- select burden of BC for all output time steps
cdo selname,${var} ${fnm}_burden.nc tmp_burden.nc

#- select grid box area for all output time steps (constant anyway)
cdo selname,gboxarea ${fnm}_burden.nc tmp_area.nc

#- compute area-weighted total across the globe (kg/m2 --> kg), convert unit (kg --> Tg)
cdo -mulc,1E-09 -fldsum -mul tmp_burden.nc tmp_area.nc tmp_burden_glb_${dat}.nc

#- convert unit (kg m-2 s-1 --> ug m-2 s-1)
cdo -mulc,1E06 -setunit,'ug m-2' tmp_burden.nc tmp_burden_whole_grid_glb_${dat}.nc

done
#- compute monthly total, merge to one time series, compute yearly total, average over all years
#cdo -timmean -yearsum -mergetime [ -apply,-monsum [ tmp_burden_glb_*.nc ] ] ${var}_burden_mean_glb_annual_total.nc

#- compute monthly mean, merge to one time series, compute yearly mean, average over all years
cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_burden_glb_*.nc ] ] ${var}_burden_mean_glb_annual_total_1990_2019.nc

cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_burden_whole_grid_glb_*.nc ] ] ${var}_burden_mean_whole_grid_glb_annual_total_1990_2019.nc

rm tmp*
