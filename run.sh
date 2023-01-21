#!/bin/bash

set -x

## input parameters
input=`jq -r '.input' config.json`
rois=`jq -r '.rois' config.json`
TEMPLATE=`jq -r '.template' config.json`
input_type=`jq -r '.input_type' config.json`
interp=`jq -r '.interp' config.json`
warp=`jq -r '.warp' config.json`
inv_warp=`jq -r '.inverse_warp' config.json`
affine=`jq -r '.affine' config.json`
roi_files=$(ls ${rois})
tempdir='tmp'
acpcdir='acpc'
standard_nonlin_warp='standard_nonlin_warp'
warp_to_use=`jq -r '.warp_to_use' config.json`
binarize=`jq -r '.binarize' config.json`
acpc_or_input=`jq -r '.acpc_or_input' config.json`
outdir='raw'

## make output directories
[ ! -d rois ] && mkdir rois rois/rois
output='./rois/rois/'

[ ! -d ${outdir} ] && mkdir ${outdir}

## making output directories
for DIRS in ${acpcdir} ${standard_nonlin_warp}
do
	mkdir ${DIRS}
done

## set if conditions
[[ ${input_type} == 'T1' ]] && output_type='t1' || output_type='t2'
if [[ ${warp_to_use} == 'warp' ]]; then
	warp_file=${warp}
	premat_line="--premat=$(eval "echo $affine")"
else
	warp_file=${inv_warp}
	if [[ ${acpc_or_input} == 'input' ]]; then
		premat_line="--premat=$(eval "echo $affine")"
	else
		premat_line=''
	fi
fi

## set template for alignment
case $TEMPLATE in
nihpd_asym*)
	space="NIHPD"
	[ $input_type == "T1" ] && template=templates/${TEMPLATE}_t1w.nii
	[ $input_type == "T2" ] && template=templates/${TEMPLATE}_t2w.nii
	template_mask=templates/${template}_mask.nii
	;;
MNI152_1mm)
	space="MNI152_1mm"
	[ $input_type == "T1" ] && template=templates/MNI152_T1_1mm.nii.gz
	[ $input_type == "T2" ] && template=templates/MNI152_T2_1mm.nii.gz
	template_mask=templates/MNI152_T1_1mm_brain_mask.nii.gz
	;;
MNI152_0.7mm)
	space="MNI152_0.7mm"
	[ $input_type == "T1" ] && template=templates/MNI152_T1_0.7mm.nii.gz
	[ $input_type == "T2" ] && template=templates/MNI152_T2_0.7mm.nii.gz
	template_mask=templates/MNI152_T1_0.7mm_brain_mask.nii.gz
	;;
MNI152_0.8mm)
	space="MNI152_0.8mm"
	[ $input_type == "T1" ] && template=templates/MNI152_T1_0.8mm.nii.gz
	[ $input_type == "T2" ] && template=templates/MNI152_T2_0.8mm.nii.gz
	template_mask=templates/MNI152_T1_0.8mm_brain_mask.nii.gz
	;;
MNI152_2mm)
	space="MNI152_2mm"
	[ $input_type == "T1" ] && template=templates/MNI152_T1_2mm.nii.gz
	[ $input_type == "T2" ] && template=templates/MNI152_T2_2mm.nii.gz
	template_mask=templates/MNI152_T1_2mm_brain_mask.nii.gz
	;;
esac

## warp rois
echo "apply fnirt warp"
for i in ${roi_files[*]}
do
	roi_to_warp=${rois}/${i}
    
    if [ ! -f ${output}/${i} ]; then
		applywarp \
			--rel \
			--interp=${interp} \
			-i ${roi_to_warp} \
			-r ${template} \
			${premat_line} \
			-w ${warp_file} \
			-o ${output}/${i}
	fi

	if [[ ${binarize} == true ]]; then
		echo "binarize and fill holes"
		fslmaths ${output}/${i} -bin -fillh ${output}/${i}
	fi
done

## final check
[ ! -f ${output}/${roi_files[0]} ] && echo "failed" && exit 1 || echo "passed"
if [ -f ./fnirt_config.cnf ]; then
	mv *.nii.gz ${outdir}/
	mv *.txt ${outdir}/
	mv *.mat ${outdir}/
fi
