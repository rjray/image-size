#!/usr/bin/perl -w

use Test::More;

eval "use Test::Pod::Coverage 1.00";

plan skip_all =>
    "Test::Pod::Coverage 1.00 required for testing POD coverage" if $@;
plan tests => 1;

pod_coverage_ok(Image::Size => { also_private => [ qr/size$/, 'img_eof' ] },
                'Image::Size');

exit;
