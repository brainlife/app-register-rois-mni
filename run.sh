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
outdir='raw'

## make output directories
[ ! -d output ] && mkdir output output/rois
output='./output/rois/'

[ ! -d ${outdir} ] && mkdir ${outdir}

## making output directories
for DIRS in ${acpcdir} ${standard_nonlin_warp}
do
	mkdir ${DIRS}
done

## set if conditions
[[ ${input_type} == 'T1' ]] && output_type='t1' || output_type='t2'
[[ ${warp_to_use} == 'warp' ]] && warp_file="warp.nii.gz" && premat_line="--premat $(eval "echo $affine")" || warp_file="inverse-warp.nii.gz" && premat_line=''

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

## if warp does not exist, perform alignment. else, just applywarp
if [ ! -f ${warp} ]; then

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

	## acpc align input
	# creating a rigid transform from linear alignment to MNI
	[ ! -f acpcmatrix ] && echo  "acpc alignment" && python3.7 \
		./aff2rigid.py \
		./${input_type}_to_standard_lin.mat \
		acpcmatrix

	# applying rigid transform to bias corrected image
	[ ! -f ./${acpcdir}/${output_type}.nii.gz ] && applywarp --rel \
		--interp=spline \
		-i ${input} \
		-r ${template} \
		--premat=acpcmatrix \
		-o ./${output_type}_acpc.nii.gz

	# dilate and fill holes in template brain mask
	[ ! -f ${TEMPLATE}_mask_dil1.nii.gz ] && fslmaths \
		${template_mask} \
		-fillh \
		-dilF ${TEMPLATE}_mask_dil1

	# flirt again
	[ ! -f acpc_to_standard_lin.mat ] && echo "acpc to MNI linear flirt" && flirt \
		-interp spline \
		-dof 12 \
		-in ./${output_type}_acpc.nii.gz \
		-ref ${template} \
		-omat acpc_to_standard_lin.mat \
		-out acpc_to_standard_lin

	# fnirt
	[ ! -f ./${input_type}_to_standard_nonlin.nii.gz ] && echo  "fnirt nonlinear alignment" && fnirt \
		--in=./${output_type}_acpc.nii.gz \
		--ref=${template} \
		--fout=${input_type}_to_standard_nonlin_field \
		--jout=${input_type}_to_standard_nonlin_jac \
		--iout=${input_type}_to_standard_nonlin \
		--logout=${input_type}_to_standard_nonlin.txt \
		--cout=${input_type}_to_standard_nonlin_coeff \
		--config=./fnirt_config.cnf \
		--aff=acpc_to_standard_lin.mat \
		--refmask=${TEMPLATE}_mask_dil1.nii.gz

	# compute inverse warp
	[ ! -f ./standard_to_${input_type}_nonlin_field.nii.gz ] && echo  "compute inverse warp" && invwarp \
		-r ${template} \
		-w ${input_type}_to_standard_nonlin_coeff \
		-o standard_to_${input_type}_nonlin_field

	[ ! -f ./acpc/${output_type}.nii.gz ] && mv ${output_type}_acpc.nii.gz ./acpc/${output_type}.nii.gz
	
	# moving warp fields from non-linear warp to warp directory
	[ ! -f ${standard_nonlin_warp}/inverse-warp.nii.gz ] && mv ./standard_to_${input_type}_nonlin_field.nii.gz ${standard_nonlin_warp}/inverse-warp.nii.gz

	[ ! -f ${standard_nonlin_warp}/warp.nii.gz ] && mv ./${input_type}_to_standard_nonlin_field.nii.gz ${standard_nonlin_warp}/warp.nii.gz

	# other outputs
	[ ! -f ${standard_nonlin_warp}/affine.txt ] &&  mv acpcmatrix ${standard_nonlin_warp}/affine.txt
	[ ! -f ${outdir}/fnirt_config.cnf ] && mv *.nii.gz ${outdir}/ && mv fnirt_config.cnf ${outdir}/ && mv *.txt ${outdir}/ && mv *.mat ${outdir}/
else
	[ ! -f ${standard_nonlin_warp}/inverse-warp.nii.gz ] && cp ${inv_warp} ${standard_nonlin_warp}/inverse-warp.nii.gz
	[ ! -f ${standard_nonlin_warp}/warp.nii.gz ] && cp ${warp} ${standard_nonlin_warp}/warp.nii.gz
	[ ! -f ${standard_nonlin_warp}/affine.txt ] && cp ${affine} ${standard_nonlin_warp}/affine.txt
	[ ! -f ./acpc/${output_type}.nii.gz ] && cp ${input} ./acpc/${output_type}.nii.gz
fi

## warp rois
echo "apply fnirt warp"
for i in ${roi_files[*]}
do
    if [ ! -f ${output}/${i} ]; then
		applywarp \
			--rel \
			--interp=${interp} \
			-i ${rois}/${i} \
			-r ${template} \
			${premat_line} \
			-w ${standard_nonlin_warp}/${warp_file} \
			-o ${output}/${i}

		echo "binarize and fill holes"
		fslmaths ${output}/${i} -bin -fillh ${output}/${i}
	fi
done

## final check
[ ! -f ${output}/${roi_files[0]} ] && echo "failed" || echo "passed"
# && exit 1 || exit 0
