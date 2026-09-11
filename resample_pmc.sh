#!/bin/bash

# Folder 
ROI_DIR="/Volumes/Poodle/Baldassano_ROIs"

# Reference BOLD to match
REF_BOLD="/Volumes/BrusselsGriffon/CommCon/derivatives/fmriprep/sub-01/func/sub-01_task-commpost_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii"

# Output folder for resampled ROIs
OUT_DIR="${ROI_DIR}/resampled"
mkdir -p "$OUT_DIR"

# Loop over all .mni.gz 
for roi in "$ROI_DIR"/*.nii; do
    # Get just the filename
    roi_base=$(basename "$roi")
    
    # Output path
    out_resampled="${OUT_DIR}/${roi_base%.mni.gz}_resampled.nii"
    
    # Resample 
    flirt -in "$roi" -ref "$REF_BOLD" -applyxfm -usesqform -out "$out_resampled"
    
    # Binarize 
    out_bin="${OUT_DIR}/${roi_base%.mni.gz}_resampled_bin.nii"
    fslmaths "$out_resampled" -thr 0.5 -bin "$out_bin"
    

done

echo "All ROIs resampled and binarized"