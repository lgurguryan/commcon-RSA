#!/bin/bash

# Paper: https://www.oxcns.org/papers/645%20Huang%20Rolls%20et%20al%202022%20An%20Extended%20Human%20Connectome%20Project%20Atlas.pdf

# A1 (includes primary_auditory)

# Define paths
ATLAS="/Volumes/Chi/HCPex_v1.1/HCPex.nii"
OUTDIR="/Volumes/Chi/HCPex_v1.1/ROIs"
OUTPUT_MASK="${OUTDIR}/left_A1_mask.nii.gz"

# Start with the 1st label (54) & create the mask 
fslmaths "$ATLAS" -thr 54 -uthr 54 -bin "$OUTPUT_MASK"


# Make sure final mask is binary
fslmaths "$OUTPUT_MASK" -bin "$OUTPUT_MASK"

echo "Left A1 mask saved: $OUTPUT_MASK"

