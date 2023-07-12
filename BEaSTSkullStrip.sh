#!/usr/bin/env bash
# 
# BEaSTSkullStrip.sh
# Using BEaST to do SkullStriping
# [see here](https://github.com/FCP-INDI/C-PAC/wiki/Concise-Installation-Guide-for-BEaST) for instructions for BEaST.
# 
# Qingyang Li
# 2013-07-29

# With major edits from Alex W
#  
# The script requires FSL, AFNI, BEaST, and MINC toolkit.


SECONDS=0

MincPATH='/opt/minc/1.9.18'
source $MincPATH/minc-toolkit-config.sh

MincLibPATH="$MincPATH/share/beast-library-1.1/"

MNItemplatePATH=~/Atlas/
MNI_DATAPATH=~/Atlas/

cwd=$PWD

if [ $# -lt 1  ]
then
  echo " USAGE ::  "
  echo "  BEaSTSkullStrip.sh <input> [output prefix] " 
  echo "   input: anatomical image with skull, in nifti format " 
  echo "   output: The program will output two nifti files " 
  echo "      1) a skull stripped brain image; "  
  echo "      2) a skull stripped brain mask. "
  echo "   Option: output prefix: the filename of the output files without extention"
  echo " Example: BEaSTSkullStrip.sh ~/data/head.nii.gz ~/brain " 
  exit
fi

if [ $# -eq 1 ]
then
  inputDir=$(dirname $1)
  if [ $inputDir == "." ]; then
    inputDir=$cwd
  fi

  filename=$(basename $1)
  inputFile=$inputDir/$filename

  extension="${filename##*.}"
  if [ $extension == "gz" ]; then
    filename="${filename%.*}"
  fi
  filename="${filename%.*}"

  outputDir=$inputDir
  out=$inputDir/${filename}_brain

else
  outputDir=$(dirname $2)

  if [ $outputDir == "." ]; then
    outputDir=$cwd
    outfile=$(basename $2)
    out=$outputDir/$outfile
  else
    mkdir -p $outputDir
    out=$2
  fi

  inputDir=$(dirname $1)
  filename=$(basename $1)
  inputFile=$inputDir/$filename

  extension="${filename##*.}"
  if [ $extension == "gz" ]; then
    filename="${filename%.*}"
  fi
  filename="${filename%.*}"

fi

echo " ++ input directory is $inputDir"
echo " ++ input basename is $filename"
echo " ++ output directory is $outputDir"
echo " ++ output will be $out"
tmpdir=$(mktemp -d $outputDir/tmp.XXXXXXXXXX)
echo " ++ working dir will be $tmpdir"

cd $tmpdir

imcp ${inputFile} head

headfile=$(ls head.*)
echo $headfile
headextension="${headfile##*.}"
if [ $headextension == "gz" ]; then
  gunzip $headfile
fi

nii2mnc head.nii head.mnc

# Normalize the input
beast_normalize head.mnc head_mni.mnc anat2mni.xfm -modeldir $MNItemplatePATH

# Run BEaST to do SkullStripping
# configuration file can be replaced by $MincLibPATH/default.2mm.conf or $MincLibPATH/default.4mm.conf

mincbeast -fill -median -conf $MincLibPATH/default.1mm.conf $MincLibPATH head_mni.mnc brain_mask_mni.mnc

# Transform brain mask to it's original space
mincresample -invert_transformation -like head.mnc -transformation anat2mni.xfm brain_mask_mni.mnc brain_mask.mnc

# Convert image from MNC to NII format.

mnc2nii brain_mask.mnc brain_mask_tmp.nii

# Resample mask to original image
flirt -in brain_mask_tmp.nii -ref head.nii -applyxfm -usesqform -out brain_mask
fslmaths brain_mask -thr 0.5 -bin brain_mask

# Generate and output brain image and brain mask
fslmaths head.nii -mul brain_mask ${out}_brain
immv brain_mask ${out}_brain_mask

# delete all intermediate files
cd $cwd
rm -rf $tmpdir

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."