#!/bin/bash
base_path="/work/bb1005/b381361/my_experiments"
exp="ac3_arctic"
liste=$(ls -d ${base_path}/${exp}/${exp}_*.01_burden.nc)
var="burden_SS"
rm tmp_*
rm tmp_*
folder_1="1990-2004"
folder_2="2005-2019"
rm -rf $folder_1 $folder_1
mkdir $folder_1
mkdir $folder_2


for i in $liste
do
fnm="${i%_*}"
#dat=$(echo $fnm | cut -b 69-82)
dat=$(echo $fnm | cut -b 59-72)

echo $fnm $dat

#- select burden of BC for all output time steps

cdo selname,${var} ${fnm}_burden.nc tmp_burden.nc
#cdo expr,burden_PMOA=burden_POL+burden_LIP+burden_PRO ${fnm}_burden.nc tmp_burden.nc

#- select grid box area for all output time steps (constant anyway)
cdo selname,gboxarea ${fnm}_burden.nc tmp_area.nc



#- compute area-weighted total across the globe (kg/m2 --> kg), convert unit (kg --> Tg)
cdo -mulc,1E-09 -fldsum -mul tmp_burden.nc tmp_area.nc tmp_burden_glb_${dat}.nc

#- convert unit (kg m-2 s-1 --> ug m-2 s-1)
cdo -mulc,1E06 -setunit,'mg m-2' tmp_burden.nc tmp_burden_whole_grid_glb_${dat}.nc

done

#file_to_group='tmp_'${region}'_burden_glb'
#file_to_group1='tmp_burden_glb_yr'
#file_to_group2='annual'
file_to_group='tmp_burden_whole_grid_glb'
file_to_group1='tmp_burden_whole_grid_yr'
file_to_group2='whole_grid'

cp ${file_to_group}_199*.nc ${folder_1}
cp ${file_to_group}_2000*.nc $folder_1
cp ${file_to_group}_2001*.nc $folder_1
cp ${file_to_group}_2002*.nc $folder_1
cp ${file_to_group}_2003*.nc $folder_1
cp ${file_to_group}_2004*.nc $folder_1

cp ${file_to_group}_2005*.nc $folder_2
cp ${file_to_group}_2006*.nc $folder_2
cp ${file_to_group}_2007*.nc $folder_2
cp ${file_to_group}_2008*.nc $folder_2
cp ${file_to_group}_2009*.nc $folder_2
cp ${file_to_group}_201*.nc $folder_2

cdo -timmean -yearmean -mergetime [ -apply,-monmean [ ${folder_1}/${file_to_group}*.nc ] ] ${var}_burden_mean_global_${file_to_group2}_total_1990_2004.nc
cdo -timmean -yearmean -mergetime [ -apply,-monmean [ ${folder_2}/${file_to_group}*.nc ] ] ${var}_burden_mean_global_${file_to_group2}_total_2005_2019.nc


#cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_burden_glb_199*.nc ] ] ${var}_burden_mean_arctic_annual_total_1990-1999.nc
#cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_burden_glb_200*.nc ] ] ${var}_burden_mean_arctic_annual_total_2000-2009.nc
#cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_burden_glb_201*.nc ] ] ${var}_burden_mean_arctic_annual_total_2010-2019.nc


#- compute monthly mean, merge to one time series, compute yearly mean, average over all years
cdo -timmean -yearmean -mergetime [ -apply,-monmean [${file_to_group}_*.nc ] ] ${var}_burden_mean_global_annual_total.nc
cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_burden_whole_grid_glb_*.nc ] ] ${var}_burden_mean_whole_grid_global_annual_total.nc

rm tmp*
