#!/bin/bash

ROI_DIR="/Volumes/Poodle/VmPFC_symmetric_20141024/resampled"

OUT_LEFT="${ROI_DIR}/vmPFC_left_resampled.nii.gz"
OUT_RIGHT="${ROI_DIR}/vmPFC_right_resampled.nii.gz"

left_files=("$ROI_DIR"/*left*_bin.nii.gz)
right_files=("$ROI_DIR"/*right*_bin.nii.gz)

# -------- LEFT --------
if [ ${#left_files[@]} -eq 0 ]; then
    echo "No left ROI files found"
else
    fslmaths "${left_files[0]}" "$OUT_LEFT"
    for ((i=1; i<${#left_files[@]}; i++)); do
        fslmaths "$OUT_LEFT" -add "${left_files[$i]}" "$OUT_LEFT"
    done
    fslmaths "$OUT_LEFT" -bin "$OUT_LEFT"
fi

# -------- RIGHT --------
if [ ${#right_files[@]} -eq 0 ]; then
    echo "No right ROI files found"
else
    fslmaths "${right_files[0]}" "$OUT_RIGHT"
    for ((i=1; i<${#right_files[@]}; i++)); do
        fslmaths "$OUT_RIGHT" -add "${right_files[$i]}" "$OUT_RIGHT"
    done
    fslmaths "$OUT_RIGHT" -bin "$OUT_RIGHT"
fi

echo "Done."