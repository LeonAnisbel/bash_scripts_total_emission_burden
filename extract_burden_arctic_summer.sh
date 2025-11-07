#!/bin/bash
#Main contributions:
#Anisbel Leon (leon@tropos.de) and Bernd Heinold (heinold@tropos.de)
base_path="/work/bb1005/b381361/my_experiments"
exp="ac3_arctic"

var="burden_SS"
rm tmp_*
rm tmp_*
folder_1="1990-2004"
folder_2="2005-2019"
rm -rf $folder_1 $folder_1
mkdir $folder_1
mkdir $folder_2


months=('04' '05' '06' '07' '08' '09')
for mo in "${months[@]}"
do
liste=$(ls -d ${base_path}/${exp}/${exp}_*${mo}.01_burden.nc)

for i in $liste
do
fnm="${i%_*}"
#dat=$(echo $fnm | cut -b 69-82)
dat=$(echo $fnm | cut -b 59-72)

echo $fnm $dat

#- select burden of BC for all output time steps
cdo selname,${var} ${fnm}_burden.nc tmp_burden_global.nc
cdo sellonlatbox,-180,180,66,90 tmp_burden_global.nc tmp_burden.nc

#- select grid box area for all output time steps (constant anyway)
cdo selname,gboxarea ${fnm}_burden.nc tmp_area_global.nc
cdo sellonlatbox,-180,180,66,90 tmp_area_global.nc tmp_area.nc


#- compute area-weighted total across the globe (kg/m2 --> kg), convert unit (kg --> Tg)
cdo -mulc,1E-09 -fldsum -mul tmp_burden.nc tmp_area.nc tmp_burden_glb_${dat}.nc

#- convert unit (kg m-2 s-1 --> ug m-2 s-1)
cdo -mulc,1E06 -setunit,'mg m-2' tmp_burden.nc tmp_burden_whole_grid_glb_${dat}.nc
done
done
#- compute monthly total, merge to one time series, compute yearly total, average over all years
#cdo -timmean -yearsum -mergetime [ -apply,-monsum [ tmp_burden_glb_*.nc ] ] ${var}_burden_mean_glb_annual_total.nc
cp tmp_burden_glb_199*.nc $folder_1
cp tmp_burden_glb_2000*.nc $folder_1
cp tmp_burden_glb_2001*.nc $folder_1
cp tmp_burden_glb_2002*.nc $folder_1
cp tmp_burden_glb_2003*.nc $folder_1
cp tmp_burden_glb_2004*.nc $folder_1

#,tmp_${region}_emi_glb_2000*.nc,tmp_${region}_emi_glb_2001*.nc,tmp_${region}_emi_glb_2002*.nc,tmp_${region}_emi_glb_2003*.nc,tmp_${region}_emi_glb_2004*.nc $folder_1
cp tmp_burden_glb_2005*.nc $folder_2
cp tmp_burden_glb_2006*.nc $folder_2
cp tmp_burden_glb_2007*.nc $folder_2
cp tmp_burden_glb_2008*.nc $folder_2
cp tmp_burden_glb_2009*.nc $folder_2
cp tmp_burden_glb_201*.nc $folder_2

cdo -timmean -yearmean -mergetime [ -apply,-monmean [ ${folder_1}/tmp_burden_glb*.nc ] ] ${var}_burden_mean_arctic_annual_total_1990_2004.nc
cdo -timmean -yearmean -mergetime [ -apply,-monmean [ ${folder_2}/tmp_burden_glb*.nc ] ] ${var}_burden_mean_arctic_annual_total_2005_2019.nc


#cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_burden_glb_199*.nc ] ] ${var}_burden_mean_arctic_annual_total_1990-1999.nc
#cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_burden_glb_200*.nc ] ] ${var}_burden_mean_arctic_annual_total_2000-2009.nc
#cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_burden_glb_201*.nc ] ] ${var}_burden_mean_arctic_annual_total_2010-2019.nc


#- compute monthly mean, merge to one time series, compute yearly mean, average over all years
cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_burden_glb_*.nc ] ] ${var}_burden_mean_arctic_annual_total.nc
cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_burden_whole_grid_glb_*.nc ] ] ${var}_burden_mean_whole_grid_arctic_annual_total.nc

rm tmp*
