#!/bin/bash
#Main contributions:
#Anisbel Leon (leon@tropos.de) and Bernd Heinold (heinold@tropos.de)
base_path="/work/bb1005/b381361/my_experiments"
exp="ac3_arctic"
liste=$(ls -d ${base_path}/${exp}/2009-2019/${exp}_*.01_emi.nc)
var="emi_LIP"
region="arctic"
rm tmp_*


for i in $liste
do
fnm="${i%_*}"
#dat=$(echo $fnm | cut -b 67-72)
#dat=$(echo $fnm | cut -b 59-72)
dat=$(echo $fnm | cut -b 69-74)

echo $fnm $dat

#- select burden of BC for all output time steps
cdo selname,${var} ${fnm}_emi.nc tmp_emi0.nc
cdo -setctomiss,0 tmp_emi0.nc tmp_emi.nc

#cdo -setmissval,-999 tmp_emi0.nc tmp_emi.nc

#- select grid box area for all output time steps (constant anyway)
cdo selname,gboxarea ${fnm}_emi.nc tmp_area.nc

#- compute area-weighted total across the globe (kg m-2 s-1 --> kg yr-1), convert unit (kg yr-1 --> Tg yr-1)
cdo -mulc,1E-09 -mulc,86400 -fldsum -mul tmp_emi.nc tmp_area.nc tmp_emi_glb_${dat}.nc


# per region
#cdo -sellonlatbox,130,240,30,63 tmp_emi.nc tmp_${var}_${region}.nc
#cdo -sellonlatbox,130,240,30,63 tmp_area.nc tmp_area_${region}.nc

#- compute area-weighted total across the globe (kg m-2 s-1 --> kg yr-1), convert unit (kg yr-1 --> Tg yr-1)
#cdo -mulc,1E-09 -mulc,86400 -fldsum -mul tmp_${var}_${region}.nc tmp_area_${region}.nc tmp_${region}_emi_glb_${dat}.nc


#- convert unit (kg m-2 s-1 --> ug m-2 s-1)
cdo -mulc,1E09 -setunit,'ug m-2 s-1' tmp_emi.nc tmp_emi_whole_grid_glb_${dat}.nc

done


for (( year=2009; year<=2019; year+=1 )); do
       echo $year
       cdo -yearsum -mergetime tmp_emi_glb_${year}*.nc tmp_emi_glb_yr_${year}.nc       
       
done



#- compute monthly mean, merge to one time series, compute yearly mean, average over all years
cdo -timmean -yearmean -mergetime tmp_emi_glb_yr*.nc  ${var}_emi_mean_glb_annual_total_2009_2019.nc

#cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_${region}_emi_*.nc ] ] ${var}_emi_mean_${region}_annual_total.nc
cdo -timmean  -yearmean -mergetime [ -apply,-monmean [ tmp_emi_whole_grid_glb_*.nc ] ] ${var}_emi_mean_whole_grid_glb_annual_total_2009_2019.nc


rm tmp*
