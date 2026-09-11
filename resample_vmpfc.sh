#!/bin/bash

# The rois come from: https://www.bic.mni.mcgill.ca/ServicesAtlases/VmPFC (the symetric pop maps)

# Folder with vmpfc rois
ROI_DIR="/Volumes/Poodle/VmPFC_symmetric_20141024"

# Reference BOLD to match
REF_BOLD="/Volumes/BrusselsGriffon/CommCon/derivatives/fmriprep/sub-01/func/sub-01_task-commpost_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii"

# Output folder for resampled ROIs
OUT_DIR="${ROI_DIR}/resampled"
mkdir -p "$OUT_DIR"

# Loop over all .mni.gz 
for roi in "$ROI_DIR"/*.nii.gz; do
    # Get just the filename
    roi_base=$(basename "$roi")
    
    # Output path
    out_resampled="${OUT_DIR}/${roi_base%.mni.gz}_resampled.nii.gz"
    
    # Resample 
    flirt -in "$roi" -ref "$REF_BOLD" -applyxfm -usesqform -out "$out_resampled"
    
    # Binarize 
    out_bin="${OUT_DIR}/${roi_base%.mni.gz}_resampled_bin.nii.gz"
    fslmaths "$out_resampled" -thr 0.5 -bin "$out_bin"
    

done

echo "All ROIs resampled and binarized"