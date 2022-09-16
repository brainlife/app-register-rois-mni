#!/bin/bash

## input parameters
t2=`jq -r '.t2' config.json`
rois=`jq -r '.rois' config.json`
TEMPLATE=`jq -r '.template' config.json`
input_type=`jq -r '.input_type' config.json`
roi_files=$(ls ${rois})
tempdir='tmp'
standard='standard'
acpcdir='acpc'
standard_nonlin_warp='standard_nonlin_warp'

## make output directory
[ ! -d output ] && mkdir output output/rois
output='./output/rois/'

## set if conditions
[[ ${input_type} == 'T1' ]] && output_type='t1' || output_type='t2'

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
    template_mask=templates/MNI152_T1_2mm_brain_mask_dil.nii.gz
    ;;
esac

## make config file for fnirt
cp -v ./templates/fnirt_config.cnf ./
sed -i "/--ref=/s/$/${TEMPLATE}/" ./fnirt_config.cnf
sed -i "/--refmask=/s/$/${TEMPLATE}_mask_dil1/" ./fnirt_config.cnf

## align input to template of choice
# flirt
echo  "flirt linear alignment"
[ ! -f ${input_type}_to_standard_lin ] && flirt -interp spline \
	-dof 12 -in ${t2} \
	-ref ${template} \
	-omat ${input_type}_to_standard_lin.mat \
	-out ${input_type}_to_standard_lin \
	-searchrx -30 30 -searchry -30 30 -searchrz -30 30

## acpc align input
echo  "acpc alignment"
# creating a rigid transform from linear alignment to MNI
[ ! -f acpcmatrix ] && python3.7 \
	./aff2rigid.py \
	./${input_type}_to_standard_lin.mat \
	acpcmatrix

# applying rigid transform to bias corrected image
[ ! -f ./${acpcdir}/${output_type}.nii.gz ] && applywarp --rel \
	--interp=spline \
	-i ${t2} \
	-r ${template} \
	--premat=acpcmatrix \
	-o ./${output_type}_acpc.nii.gz

# dilate and fill holes in template brain mask
[ ! -f ${TEMPLATE}_mask_dil1 ] && fslmaths \
	${template_mask} \
	-fillh \
	-dilF ${TEMPLATE}_mask_dil1

# flirt again
echo "acpc to MNI linear flirt"
[ ! -f acpc_to_standard_lin.mat ] && flirt \
	-interp spline \
	-dof 12 \
	-in ./${output_type}_acpc.nii.gz \
	-ref ${template} \
	-omat acpc_to_standard_lin.mat \
	-out acpc_to_standard_lin

# fnirt
echo  "fnirt nonlinear alignment"
[ ! -f ${input_type}_to_standard_nonlin ] && fnirt \
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

echo "apply fnirt warp"
for i in ${roi_files[*]}
do
    [ ! -f ${standard}/${output_type}.nii.gz ] && applywarp \
        --rel \
        --interp=spline \
        -i ${rois}/${i} \
        -r ${template} \
        -w ${input_type}_to_standard_nonlin_field \
        -o ${output}/${i}
done

echo  "compute inverse warp"
[ ! -f standard_to_${input_type}_nonlin_field ] && invwarp \
	-r ${template} \
	-w ${input_type}_to_standard_nonlin_coeff \
	-o standard_to_${input_type}_nonlin_field