#!/bin/bash
#Main contributions:
#Anisbel Leon (leon@tropos.de) and Bernd Heinold (heinold@tropos.de)
base_path="/work/bb1005/b381361/my_experiments"
exp="ac3_arctic"
liste=$(ls -d ${base_path}/${exp}/${exp}_*.01_burden.nc)
## declare an array variable
declare -a regions=("Arctic" "Antarctica" "Spacific" "Npacific" "Satlantic" "Natlantic" "Indian")
declare -a lat_min=(60 -90 -60 0 -60 0 -60)
declare -a lat_max=(90 -60 0 60 0 60 23)
declare -a lon_min=(-180 -180 130 130 290 300 20)
declare -a lon_max=(180 180 290 290 360 360 120)

# get length of an array
arraylength=${#regions[@]}

# use for loop to read all values and indexes
for (( i=0; i<${arraylength}; i++ ));
do
echo "index: $i, value: ${regions[$i]}, ${lon_min[$i]}"
rm tmp_*
region=${regions[$i]}

for file in $liste
do
fnm="${file%_*}"
#dat=$(echo $fnm | cut -b 67-72)
#dat=$(echo $fnm | cut -b 59-72)
dat=$(echo $fnm | cut -b 59-74)

echo $fnm $dat

#- select burden of BC for all output time steps
cdo expr,PMOA=burden_LIP+burden_POL+burden_PRO ${fnm}_burden.nc tmp_emi0.nc
cdo -setctomiss,0 tmp_emi0.nc tmp_emi.nc


#- select grid box area for all output time steps (constant anyway)
cdo selname,gboxarea ${fnm}_emi.nc tmp_area.nc


# per region
cdo -sellonlatbox,${lon_min[$i]},${lon_max[$i]},${lat_min[$i]},${lat_max[$i]} tmp_emi.nc tmp_${region}.nc
cdo -sellonlatbox,${lon_min[$i]},${lon_max[$i]},${lat_min[$i]},${lat_max[$i]} tmp_area.nc tmp_area_${region}.nc

#- compute area-weighted total across the globe (kg m-2 s-1 --> kg yr-1), convert unit (kg yr-1 --> Tg yr-1)
cdo -mulc,1E-09 -fldsum -mul tmp_${region}.nc tmp_area_${region}.nc tmp_${region}_emi_glb_${dat}.nc

#- convert unit (kg m-2 s-1 --> ug m-2 s-1)
cdo -mulc,1E06 -setunit,'mg m-2' tmp_${region}.nc tmp_${region}_emi_whole_grid_glb_${dat}.nc

done

#- compute monthly mean, merge to one time series, compute yearly mean, average over all years
cdo -timmean -mergetime tmp_${region}_emi_glb*.nc  PMOA_${region}_burden_mean_glb_annual_total_1990_2019.nc
cdo -timmean  -yearmean -mergetime [ -apply,-monmean [ tmp_${region}_emi_whole_grid_glb_*.nc ] ] PMOA_${region}_burden_mean_whole_grid_glb_annual_total_1990_2019.nc


done
rm tmp*
