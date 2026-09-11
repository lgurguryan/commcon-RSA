#!/bin/bash

# Subjects
subjects=("sub-01" "sub-02" "sub-03")

#subjects=("sub-04" "sub-05" "sub-06" "sub-07" "sub-08" "sub-09" "sub-10" \
 #         "sub-11" "sub-12" "sub-13" "sub-14" "sub-15" "sub-16" "sub-17" "sub-18" "sub-19" "sub-20" \
 #         "sub-21" "sub-22" "sub-23" "sub-24" "sub-25" "sub-26" "sub-27" "sub-28" "sub-29" "sub-30" \
  #        "sub-31" "sub-32" "sub-33" "sub-34")

# Directory path 
base_dir="/Volumes/Poodle/ashs_output"

# Extract labels 
for sub in "${subjects[@]}"; do

    echo "Processing $sub ..."
    
    subject_dir="${base_dir}/${sub}/final"
    cd "$subject_dir" || { echo "Cannot find $subject_dir"; continue; }

    # PHC (label 5) 
    fslmaths ${sub}_right_lfseg_corr_usegray.nii.gz -thr 5 -uthr 5 ${sub}_right_PHC.nii.gz
    fslmaths ${sub}_left_lfseg_corr_usegray.nii.gz  -thr 5 -uthr 5 ${sub}_left_PHC.nii.gz

    # PRC (label 6) 
    fslmaths ${sub}_right_lfseg_corr_usegray.nii.gz -thr 6 -uthr 6 ${sub}_right_PRC.nii.gz
    fslmaths ${sub}_left_lfseg_corr_usegray.nii.gz  -thr 6 -uthr 6 ${sub}_left_PRC.nii.gz

    # RIGHT HIPPOCAMPUS
    fslmaths ${sub}_right_lfseg_corr_usegray.nii.gz -thr 1 -uthr 1 -bin right-CA1
    fslmaths ${sub}_right_lfseg_corr_usegray.nii.gz -thr 2 -uthr 2 -bin right-CA2_3
    fslmaths ${sub}_right_lfseg_corr_usegray.nii.gz -thr 3 -uthr 3 -bin right-DG
    fslmaths ${sub}_right_lfseg_corr_usegray.nii.gz -thr 7 -uthr 7 -bin right-SUB

    fslmaths right-CA1 -add right-CA2_3 -add right-DG -add right-SUB -bin ${sub}_right_Hippocampus.nii.gz

    # LEFT HIPPOCAMPUS
    fslmaths ${sub}_left_lfseg_corr_usegray.nii.gz -thr 1 -uthr 1 -bin left-CA1
    fslmaths ${sub}_left_lfseg_corr_usegray.nii.gz -thr 2 -uthr 2 -bin left-CA2_3
    fslmaths ${sub}_left_lfseg_corr_usegray.nii.gz -thr 3 -uthr 3 -bin left-DG
    fslmaths ${sub}_left_lfseg_corr_usegray.nii.gz -thr 7 -uthr 7 -bin left-SUB

    fslmaths left-CA1 -add left-CA2_3 -add left-DG -add left-SUB -bin ${sub}_left_Hippocampus.nii.gz

    echo "$sub done."

done
