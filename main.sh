#!/bin/bash

scan() {
	DUPLEX=$1
	if [[ -n $1 ]]; then
		scanimage \
		-d "brother4:net1;dev0"\
		--mode "True Gray" \
		--source "Automatic Document Feeder(centrally aligned,Duplex)" \
		--format=tiff \
		-x 210 \
		-y 297 \
		--batch \
		--brightness 10 \
		--contrast 10 \
		--progress
	else
		scanimage \
		-d "brother4:net1;dev0"\
		--mode "True Gray" \
		--format=tiff \
		-x 210 \
		-y 297 \
		--batch \
		--brightness 10 \
		--contrast 10 \
		--progress
	fi
}

# gray() {
# 	convert $1 -set colorspace Gray -separate -average w-$1
# }

unpap() {
	unpaper -s a4 \
        --overwrite \
        --no-grayfilter \
        --no-wipe \
        --no-noisefilter \
        --no-blurfilter \
        --no-blackfilter \
        $1 x-$1
}

add_ocr() {
	tesseract -l deu x-$1 $1 pdf
}

ghost() {
	gs \
	 -dPDFA \
	 -dBATCH \
	 -dNOPAUSE \
	 -sProcessColorModel=DeviceRGB \
	 -sDEVICE=pdfwrite \
	 -sPDFACompatibilityPolicy=1 \
	 -dColorImageDownsampleType=/Bicubic \
	 -dColorImageResolution=90 \
	 -dGrayImageDownsampleType=/Bicubic \
	 -dGrayImageResolution=90 \
	 -dMonoImageDownsampleType=/Bicubic	\
	 -dMonoImageResolution=90 \
	 -sOutputFile=../output.pdf \
	 $@
}

pushd x
scan $DUPLEX;
for img in $(ls out*.tif); do
    echo $img;
    unpap $img;
	add_ocr $img;
done
ghost $(ls out*.tif.pdf);
popd
rm x/*;
