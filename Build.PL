#!/usr/bin/perl

use Module::Build;

my $build = Module::Build->new(
    module_name       => 'Image::Size',
    autosplit         => 'lib/Image/Size.pm',
    license           => 'artistic',
    requires          => { perl => '5.6.0',
                           File::Spec => 0 },
    build_requires    => { Test::More => 0 },
    dist_author       => 'Randy J. Ray <rjray@blackperl.com>',
    dist_abstract     => 'A library to extract height/width from images',
    dist_version_from => 'lib/Image/Size.pm',
    script_files      => [ 'imgsize' ],
    sign              => 'yes, please',
);

$build->add_to_cleanup(qw(META.yml Image-Size-*));
$build->create_build_script;
