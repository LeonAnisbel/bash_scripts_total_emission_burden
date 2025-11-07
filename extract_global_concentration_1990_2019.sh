#!/bin/bash
#Main contributions:
#Anisbel Leon (leon@tropos.de) and Bernd Heinold (heinold@tropos.de)
base_path="/work/bb1178/b324073"
exp="ac3_arctic"
file_id="tracer"
list=$(ls -d ${base_path}/${exp}/${exp}_*.01_${file_id}.nc)


rm tmp*
for i in $list; do
fnm="${i%_*}"
echo $fnm
#fnm1=$(echo ${i} | cut -c1-67 )
dat=$(echo $fnm | cut -c44-74)
echo $dat 
cdo selname,geosp,aps,lsp,gboxarea  ${fnm}_${file_id}.nc tmp0.nc

#cdo setrtoc,-1.e99,0,0 ${fnm}_${file_id}.nc tmpnonzeros.nc
cdo expr,PMOA_tot=POL_AS+PRO_AS+LIP_AS ${fnm}_${file_id}.nc tmpsum.nc
cdo selname,rhoam1 ${fnm}_vphysc.nc tmpdens.nc
cdo merge tmpsum.nc tmpdens.nc tmpmix_${dat}.nc

cdo expr,PMOA=PMOA_tot*rhoam1 tmpmix_${dat}.nc tmpmoa.nc
cdo setunit,'kg/m3' -setcode,157 -selname,PMOA tmpmoa.nc tmp1.nc
cdo merge tmp0.nc tmp1.nc tmp_conc_whole_grid_glb_${dat}.nc

done


cdo -timmean -yearmean -mergetime [ -apply,-monmean [ tmp_conc_whole_grid_glb_*.nc ] ] PMOA_conc_mean_whole_grid_glb_annual_total_1990_2019.nc

# interpolation to pressure levels from file pres.txt
plev=$(awk '{print $3","}' pres.txt)
cdo after PMOA_conc_mean_whole_grid_glb_annual_total_1990_2019.nc PMOA_conc_mean_whole_grid_glb_annual_total_1990_2019_plev.nc << EON
   TYPE=30 CODE=157  LEVEL=${plev}
EON
rm tmp*





























