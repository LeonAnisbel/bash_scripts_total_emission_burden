#!/bin/bash
#Main contributions:
#Anisbel Leon (leon@tropos.de) and Bernd Heinold (heinold@tropos.de)
base_path="/work/bb1005/b381361/my_experiments"
exp="ac3_arctic"

var="emi_SS"
region="arctic"
rm tmp_*
folder_1="1990-2004"
folder_2="2005-2019"
rm -rf $folder_1 $folder_1
mkdir $folder_1
mkdir $folder_2


months=('04' '05' '06' '07' '08' '09')
for mo in "${months[@]}"
do
liste=$(ls -d ${base_path}/${exp}/${exp}_*${mo}.01_emi.nc)
for i in $liste
do
fnm="${i%_*}"
dat=$(echo $fnm | cut -b 69-82)
dat=$(echo $fnm | cut -b 59-72)
echo $fnm $dat

#- select burden of BC for all output time steps
cdo selname,${var} ${fnm}_emi.nc tmp_emi0.nc
cdo -setctomiss,0 tmp_emi0.nc tmp_emi.nc

#cdo -setmissval,-999 tmp_emi0.nc tmp_emi.nc

#- select grid box area for all output time steps (constant anyway)
cdo selname,gboxarea ${fnm}_emi.nc tmp_area.nc

#- compute area-weighted total across the globe (kg m-2 s-1 --> kg yr-1), convert unit (kg yr-1 --> Tg yr-1)
cdo -mulc,1E-09 -mulc,86400 -fldsum -mul tmp_emi.nc tmp_area.nc tmp_emi_glb_${dat}.nc

# overall  mean, Arctic
cdo -sellonlatbox,-180,180,66,90 tmp_emi.nc tmp_${var}_${region}.nc
cdo -sellonlatbox,-180,180,66,90 tmp_area.nc tmp_area_${region}.nc
#- compute area-weighted total across the globe (kg m-2 s-1 --> kg yr-1), convert unit (kg yr-1 --> Tg yr-1)
cdo -mulc,1E-09 -mulc,86400 -fldsum -mul tmp_${var}_${region}.nc tmp_area_${region}.nc tmp_${region}_emi_glb_${dat}.nc

#- convert unit (kg m-2 s-1 --> ug m-2 s-1)
cdo -mulc,1E09 -setunit,'ug m-2 s-1' tmp_emi.nc tmp_emi_whole_grid_glb_${dat}.nc
done
done


cp tmp_${region}_emi_glb_199*.nc ${folder_1}
cp tmp_${region}_emi_glb_2000*.nc $folder_1
cp tmp_${region}_emi_glb_2001*.nc $folder_1
cp tmp_${region}_emi_glb_2002*.nc $folder_1
cp tmp_${region}_emi_glb_2003*.nc $folder_1
cp tmp_${region}_emi_glb_2004*.nc $folder_1

#,tmp_${region}_emi_glb_2000*.nc,tmp_${region}_emi_glb_2001*.nc,tmp_${region}_emi_glb_2002*.nc,tmp_${region}_emi_glb_2003*.nc,tmp_${region}_emi_glb_2004*.nc $folder_1
cp tmp_${region}_emi_glb_2005*.nc $folder_2
cp tmp_${region}_emi_glb_2006*.nc $folder_2
cp tmp_${region}_emi_glb_2007*.nc $folder_2
cp tmp_${region}_emi_glb_2008*.nc $folder_2
cp tmp_${region}_emi_glb_2009*.nc $folder_2
cp tmp_${region}_emi_glb_201*.nc $folder_2


for (( year=2005; year<=2019; year+=1 )); do
       echo $year
       cdo -yearsum -mergetime ${folder_2}/tmp_${region}_emi_glb*.nc ${folder_2}/tmp_emi_glb_yr_${year}.nc
done
cdo -timmean -mergetime ${folder_2}/tmp_emi_glb_yr*.nc  ${var}_emi_mean_${region}_annual_2005_2019.nc



for (( year=1990; year<=2004; year+=1 )); do
       echo $year
       cdo -yearsum -mergetime ${folder_1}/tmp_${region}_emi_glb*.nc ${folder_1}/tmp_emi_glb_yr_${year}.nc  #${var}_emi_mean_${region}_annual_2005_2019.nc
done
cdo -timmean -mergetime ${folder_1}/tmp_emi_glb_yr*.nc  ${var}_emi_mean_${region}_annual_1990_2004.nc


for (( year=1990; year<=2019; year+=1 )); do
       echo $year
       cdo -yearsum -mergetime tmp_${region}_emi_glb*.nc tmp_emi_glb_yr_${year}.nc  #${var}_emi_mean_${region}_annual_2005_2019.nc
done
cdo -timmean -mergetime tmp_emi_glb_yr*.nc  ${var}_emi_mean_${region}_annual_1990_2019.nc




#- compute monthly total, merge to one time series, compute yearly total, average over all years
#cdo -timmean -yearsum -mergetime [ -apply,-monsum [ tmp_burden_glb_*.nc ] ] ${var}_burden_mean_glb_annual_total.nc

#- compute monthly mean, merge to one time series, compute yearly mean, average over all years
#cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_emi_glb_*.nc ] ] ${var}_emi_mean_glb_annual_total.nc


#cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_${region}_emi_*.nc ] ] ${var}_emi_mean_${region}_annual_total.nc


cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_emi_whole_grid_glb_*.nc ] ] ${var}_emi_mean_whole_grid_glb_annual_total_1990_2019.nc

rm tmp*
