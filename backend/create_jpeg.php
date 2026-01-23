<?php
// Minimal valid JPEG header that can be displayed
$jpegData = base64_decode(
    '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0a' .
    'HBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIy' .
    'MjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIA' .
    'AhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8VAFQEB' .
    'AQAAAAAAAAAAAAAAAAAAAX/EQAUEQEAAAAAAAAAAAAAAAAAAAAw/9oADAMBAAIRAxEAPwCwAA8A' .
    '/9k='
);

file_put_contents(
    'd:\\Hackathon\\quasar-updated\\backend\\storage\\app\\public\\dprs\\project_1\\dpr_11\\test_photo_1.jpg',
    $jpegData
);

file_put_contents(
    'd:\\Hackathon\\quasar-updated\\backend\\storage\\app\\public\\dprs\\project_1\\dpr_11\\test_photo_2.jpg',
    $jpegData
);

echo "JPEG files created successfully\n";
echo "File 1 size: " . filesize('d:\\Hackathon\\quasar-updated\\backend\\storage\\app\\public\\dprs\\project_1\\dpr_11\\test_photo_1.jpg') . " bytes\n";
echo "File 2 size: " . filesize('d:\\Hackathon\\quasar-updated\\backend\\storage\\app\\public\\dprs\\project_1\\dpr_11\\test_photo_2.jpg') . " bytes\n";
