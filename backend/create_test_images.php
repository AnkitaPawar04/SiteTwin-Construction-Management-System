<?php
// Create test DPR images for testing

$width = 300;
$height = 300;

// Create a simple blue image with text
$image = imagecreatetruecolor($width, $height);
$blueColor = imagecolorallocate($image, 52, 152, 219);
$whiteColor = imagecolorallocate($image, 255, 255, 255);

// Fill with blue
imagefill($image, 0, 0, $blueColor);

// Add text
imagestring($image, 5, 80, 140, 'Test DPR Photo', $whiteColor);

// Save the image
$fileName = 'storage/app/public/dprs/project_1/dpr_11/dpr_11_' . time() . '_test.png';
imagepng($image, $fileName);
imagedestroy($image);

echo "Image created: $fileName\n";

// Create another one
$image2 = imagecreatetruecolor($width, $height);
$greenColor = imagecolorallocate($image2, 46, 204, 113);
$whiteColor = imagecolorallocate($image2, 255, 255, 255);

imagefill($image2, 0, 0, $greenColor);
imagestring($image2, 5, 70, 140, 'Test DPR Photo #2', $whiteColor);

$fileName2 = 'storage/app/public/dprs/project_1/dpr_11/dpr_11_' . (time() + 1) . '_test2.png';
imagepng($image2, $fileName2);
imagedestroy($image2);

echo "Image 2 created: $fileName2\n";
