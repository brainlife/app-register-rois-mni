#!/bin/bash

set -x

## input parameters
input=`jq -r '.t1' config.json`
TEMPLATE="MNI152_2mm"
input_type='T1'
interp="nn"
rois="template_rois"
roi_files=$(find ${rois}/*.nii.gz)
roi_files=($roi_files)
tempdir='tmp'
warp_to_use="inv_warp"
outdir='raw'

## make output directories
[ ! -d rois ] && mkdir rois rois/rois
output='./rois/rois/'

[ ! -d ${outdir} ] && mkdir ${outdir}

## set if conditions
[[ ${input_type} == 'T1' ]] && output_type='t1'

warp_file="inverse-warp.nii.gz"
premat_line=''

## set template for alignment
space="MNI152_2mm"
[ $input_type == "T1" ] && template=templates/MNI152_T1_2mm.nii.gz
template_mask=templates/MNI152_T1_2mm_brain_mask.nii.gz

## make config file for fnirt
cp -v ./templates/fnirt_config.cnf ./
sed -i "/--ref=/s/$/${TEMPLATE}/" ./fnirt_config.cnf
sed -i "/--refmask=/s/$/${TEMPLATE}_mask_dil1/" ./fnirt_config.cnf

## align input to template of choice
# flirt
[ ! -f ${input_type}_to_standard_lin.nii.gz ] && echo  "flirt linear alignment" && flirt -interp spline \
	-dof 12 -in ${input} \
	-ref ${template} \
	-omat ${input_type}_to_standard_lin.mat \
	-out ${input_type}_to_standard_lin \
	-searchrx -30 30 -searchry -30 30 -searchrz -30 30

# dilate and fill holes in template brain mask
[ ! -f ${TEMPLATE}_mask_dil1.nii.gz ] && fslmaths \
	${template_mask} \
	-fillh \
	-dilF ${TEMPLATE}_mask_dil1

# fnirt
[ ! -f ./${input_type}_to_standard_nonlin.nii.gz ] && echo  "fnirt nonlinear alignment" && fnirt \
	--in=./${input_type}_to_standard_lin.nii.gz \
	--ref=${template} \
	--fout=${input_type}_to_standard_nonlin_field \
	--jout=${input_type}_to_standard_nonlin_jac \
	--iout=${input_type}_to_standard_nonlin \
	--logout=${input_type}_to_standard_nonlin.txt \
	--cout=${input_type}_to_standard_nonlin_coeff \
	--config=./fnirt_config.cnf \
	--aff=${input_type}_to_standard_lin.mat \
	--refmask=${TEMPLATE}_mask_dil1.nii.gz

# compute inverse warp
[ ! -f ./standard_to_${input_type}_nonlin_field.nii.gz ] && echo  "compute inverse warp" && invwarp \
	-r ${template} \
	-w ${input_type}_to_standard_nonlin_coeff \
	-o standard_to_${input_type}_nonlin_field

warp_file=./standard_to_${input_type}_nonlin_field.nii.gz

## warp rois
echo "apply fnirt warp"
for i in ${roi_files[*]}
do
	i=${i##${rois}/}
	roi_to_warp=${rois}/${i}
    
    if [ ! -f ${output}/${i} ]; then
		applywarp \
			--rel \
			--interp=${interp} \
			-i ${roi_to_warp} \
			-r ${input} \
			-w ${warp_file} \
			-o ${output}/${i}

		echo "binarize and fill holes"
		fslmaths ${output}/${i} -bin -fillh ${output}/${i}
	fi
done

## final check
[ ! -f ${output}/${roi_files[0]} ] && echo "failed" && exit 1 || echo "passed" && mv *.nii.gz ${outdir}/ && mv fnirt_config.cnf ${outdir}/ && mv *.txt ${outdir}/ && mv *.mat ${outdir}/

