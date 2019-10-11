#!/usr/bin/perl

use strict;
our @MODULES;

use Test::More;

# Verify that the individual modules will load

BEGIN
{
    @MODULES = qw(Image::Size);

    plan tests => scalar(@MODULES);
}

use_ok($_) for (@MODULES);

exit 0;
