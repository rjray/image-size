#!/usr/bin/perl -w

# Tests related to Image::Magick and Graphics::Magick

BEGIN: {
    use Test::More tests => 2;
    use_ok('Image::Size');
}

# This test should work whether or not Image::Magick is installed. 
ok(!(exists $INC{'Image/Magick.pm'}),
   'Image::Magick should not be loaded until it is needed if it available')
    || diag "Image::Magick loaded at:  $INC{'Image/Magick.pm'}";
