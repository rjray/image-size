#!/usr/bin/perl

use Module::Build;

my $build = Module::Build->new(
    module_name       => 'Image::Size',
    autosplit         => 'lib/Image/Size.pm',
    license           => 'perl',
    requires          => { perl => '5.006',
                           File::Spec => 0, Compress::Zib => 2 },
    build_requires    => { Test::More => 0 },
    build_recommends  => { Image::Magick => 6 },
    # This *should* be "build_recommends", since it is only for the tests
    recommends        => { Test::Pod => 0, Test::Pod::Coverage => 0 },
    dist_author       => 'Randy J. Ray <rjray@blackperl.com>',
    dist_abstract     => 'A library to extract height/width from images',
    dist_version      => '3.1.1',
    script_files      => [ 'imgsize' ],
    sign              => 'yes, please',
);

$build->add_to_cleanup(qw(META.yml Image-Size-*));
$build->create_build_script;
