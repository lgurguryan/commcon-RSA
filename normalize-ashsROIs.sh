#!/bin/bash

# Subjects
#subjects=(sub 01 sub-02 sub-03 sub-04 sub-05 sub-06 sub-07 sub-08 sub-09 sub-10 sub-11 sub-12 \
#          sub-13 sub-14 sub-15 sub-16 sub-17 sub-18 sub-19 sub-20 sub-21 sub-22 sub-23 sub-24 sub-25 \
#          sub-26 sub-27 sub-28 sub-29 sub-30 sub-31 sub-32 sub-33 sub-34)  
subjects=(sub-17)  

# ROIs 
#roi_names=(left_Hippocampus right_Hippocampus left_PHC right_PHC left_PRC right_PRC)
roi_names=(left_Hippocampus right_Hippocampus left_PHC right_PHC left_PRC right_PRC)

# Paths (spaces escaped with \)
t2_dir="/Volumes/Poodle/T2-from-sophon"
ashs_dir="/Volumes/Poodle/ashs_output"
fmriprep_dir="/Volumes/BrusselsGriffon/CommCon/derivatives/fmriprep"

# Loop over subjects
for sub in "${subjects[@]}"; do
    echo "Processing $sub"

    t1_preproc="${fmriprep_dir}/${sub}/anat/${sub}_desc-preproc_T1w.nii.gz"
    t1_to_mni="${fmriprep_dir}/${sub}/anat/${sub}_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5" #comes from fMRIPrep
    t2_image="${t2_dir}/${sub}_T2w_fixed.nii.gz" # Used for ASHS 
    output_prefix="${ashs_dir}/${sub}/final/${sub}_T2_to_T1_"

    # Register T2 → T1
    echo "Registering T2 to T1"
    antsRegistrationSyNQuick.sh \
        -d 3 \
        -f $t1_preproc \
        -m $t2_image \
        -o $output_prefix

    # Transform files you get from ANTs
    t2_to_t1_affine="${output_prefix}0GenericAffine.mat"
    t2_to_t1_warp="${output_prefix}1Warp.nii.gz"

    # Warp ROI to MNI
    for roi in "${roi_names[@]}"; do
        input_roi="${ashs_dir}/${sub}/final/${sub}_${roi}.nii.gz"
        #input_roi="${ashs_dir}/${sub}/final/${roi}.nii.gz"
        output_roi="${ashs_dir}/${sub}/final/${sub}_${roi}_MNI.nii.gz"

        echo "Warping $roi to MNI space"
        
        antsApplyTransforms \
            -d 3 \
            -i $input_roi \
            -r $fmriprep_dir/${sub}/anat/${sub}_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz \
            -o $output_roi \
            -n NearestNeighbor \
            -t $t1_to_mni \
            -t $t2_to_t1_warp \
            -t $t2_to_t1_affine
           
    # Define BOLD reference
    bold_ref="${fmriprep_dir}/${sub}/func/${sub}_task-commpost_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"
    output_roi_bold="${ashs_dir}/${sub}/final/${sub}_${roi}_MNI-BOLD.nii.gz"

    # Create identity matrix for FLIRT = don't move the image in any way 
    echo -e "1 0 0 0\n0 1 0 0\n0 0 1 0\n0 0 0 1" > identity.mat

    # Resample MNI ROI to BOLD voxel grid
    flirt -in "$output_roi" \
          -ref "$bold_ref" \
          -out "$output_roi_bold" \
          -interp nearestneighbour \
          -applyxfm \
          -init identity.mat


        echo "$roi done for $sub."
    done

done