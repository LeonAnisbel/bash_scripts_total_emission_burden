#!/bin/bash
#Main contributions:
#Anisbel Leon (leon@tropos.de) and Bernd Heinold (heinold@tropos.de)
base_path="/work/bb1005/b381361/my_experiments"
exp="ac3_arctic"
liste=$(ls -d ${base_path}/${exp}/${exp}_*.01_wetdep.nc)
var="wdep_LIP"
region="arctic"
rm tmp_*
folder_1="1990-2004"
folder_2="2005-2019"
rm -rf $folder_1 $folder_1
mkdir $folder_1
mkdir $folder_2

for i in $liste
do
fnm="${i%_*}"
dat=$(echo $fnm | cut -b 69-82)
dat=$(echo $fnm | cut -b 59-72)
echo $fnm $dat

#- select burden of BC for all output time steps
cdo selname,${var} ${fnm}_wetdep.nc tmp_wdep0.nc
cdo -setctomiss,0 tmp_wdep0.nc tmp_wdep.nc

#cdo -setmissval,-999 tmp_emi0.nc tmp_emi.nc

#- select grid box area for all output time steps (constant anyway)
cdo selname,gboxarea ${fnm}_emi.nc tmp_area.nc

#- compute area-weighted total across the globe (kg m-2 s-1 --> kg yr-1), convert unit (kg yr-1 --> Tg yr-1)
#cdo -mulc,1E-09 -mulc,86400 -fldsum -mul tmp_emi.nc tmp_area.nc tmp_emi_glb_${dat}.nc

# overall  mean, Arctic
cdo -sellonlatbox,-180,180,66,90 tmp_wdep.nc tmp_${var}_${region}.nc
cdo -sellonlatbox,-180,180,66,90 tmp_area.nc tmp_area_${region}.nc
#- compute area-weighted total across the globe (kg m-2 s-1 --> kg yr-1), convert unit (kg yr-1 --> Tg yr-1)
cdo -mulc,1E-09 -mulc,86400 -fldsum -mul tmp_${var}_${region}.nc tmp_area_${region}.nc tmp_${region}_wdep_glb_${dat}.nc

#- convert unit (kg m-2 s-1 --> ug m-2 s-1)
cdo -mulc,1E09 -setunit,'ug m-2 s-1' tmp_wdep.nc tmp_wdep_whole_grid_glb_${dat}.nc

done


cp tmp_${region}_wdep_glb_199*.nc ${folder_1}
cp tmp_${region}_wdep_glb_2000*.nc $folder_1
cp tmp_${region}_wdep_glb_2001*.nc $folder_1
cp tmp_${region}_wdep_glb_2002*.nc $folder_1
cp tmp_${region}_wdep_glb_2003*.nc $folder_1
cp tmp_${region}_wdep_glb_2004*.nc $folder_1

#,tmp_${region}_wdep_glb_2000*.nc,tmp_${region}_wdep_glb_2001*.nc,tmp_${region}_wdep_glb_2002*.nc,tmp_${region}_wdep_glb_2003*.nc,tmp_${region}_wdep_glb_2004*.nc $folder_1
cp tmp_${region}_wdep_glb_2005*.nc $folder_2
cp tmp_${region}_wdep_glb_2006*.nc $folder_2
cp tmp_${region}_wdep_glb_2007*.nc $folder_2
cp tmp_${region}_wdep_glb_2008*.nc $folder_2
cp tmp_${region}_wdep_glb_2009*.nc $folder_2
cp tmp_${region}_wdep_glb_201*.nc $folder_2


for (( year=2005; year<=2019; year+=1 )); do
       echo $year
       cdo -yearsum -mergetime ${folder_2}/tmp_${region}_wdep_glb*.nc ${folder_2}/tmp_wdep_glb_yr_${year}.nc
done
cdo -timmean -mergetime ${folder_2}/tmp_wdep_glb_yr*.nc  ${var}_wdep_mean_${region}_annual_2005_2019.nc

for (( year=1990; year<=2004; year+=1 )); do
       echo $year
       cdo -yearsum -mergetime ${folder_1}/tmp_${region}_wdep_glb*.nc ${folder_1}/tmp_wdep_glb_yr_${year}.nc  #${var}_wdep_mean_${region}_annual_2005_2019.nc
done
cdo -timmean -mergetime ${folder_1}/tmp_wdep_glb_yr*.nc  ${var}_wdep_mean_${region}_annual_1990_2004.nc


cp tmp_wdep_whole_grid_glb_199*.nc ${folder_1}
cp tmp_wdep_whole_grid_glb_2000*.nc $folder_1
cp tmp_wdep_whole_grid_glb_2001*.nc $folder_1
cp tmp_wdep_whole_grid_glb_2002*.nc $folder_1
cp tmp_wdep_whole_grid_glb_2003*.nc $folder_1
cp tmp_wdep_whole_grid_glb_2004*.nc $folder_1
cdo -timmean -yearmean -mergetime [ -apply,-monmean [ ${folder_1}/tmp_wdep_whole_grid_glb_*.nc ] ] ${var}_wdep_mean_whole_grid_glb_annual_total_1990_2004.nc


cp tmp_wdep_whole_grid_glb_2005*.nc ${folder_2}
cp tmp_wdep_whole_grid_glb_2006*.nc $folder_2
cp tmp_wdep_whole_grid_glb_2007*.nc $folder_2
cp tmp_wdep_whole_grid_glb_2008*.nc $folder_2
cp tmp_wdep_whole_grid_glb_2009*.nc $folder_2
cp tmp_wdep_whole_grid_glb_201*.nc $folder_2
cdo -timmean -yearmean -mergetime [ -apply,-monmean [ ${folder_2}/tmp_wdep_whole_grid_glb_*.nc ] ] ${var}_wdep_mean_whole_grid_glb_annual_total_2005_2019.nc


for (( year=1990; year<=2019; year+=1 )); do
       echo $year
       cdo -yearsum -mergetime tmp_${region}_wdep_glb*.nc tmp_wdep_glb_yr_${year}.nc  #${var}_wdep_mean_${region}_annual_2005_2019.nc
done
cdo -timmean -mergetime tmp_wdep_glb_yr*.nc  ${var}_wdep_mean_${region}_annual_1990_2019.nc

cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_wdep_whole_grid_glb_*.nc ] ] ${var}_wdep_mean_whole_grid_glb_annual_total_1990_2019.nc

rm tmp*

