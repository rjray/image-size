###############################################################################
#
#   Module::Build file for Image::Size
#
###############################################################################

use 5.006001;
use strict;
use warnings;

use File::Spec;

use Module::Build;

my $class = Module::Build->subclass(
    class => 'Image::Size::Builder',
    code => q|
        sub ACTION_dist
        {
            my $self = shift;

            # Create the text ChangeLog
            $self->do_system('changelog2x',
                             qw(--template text
                                --input ChangeLog.xml
                                --output ChangeLog));
            # Create the text README
            $self->do_system('textile2x',
                             qw(--format plaintext
                                --input README.textile
                                --output README));

            $self->SUPER::ACTION_manifest();
            $self->SUPER::ACTION_dist();
        }
|);

my $builder = $class->new(
    module_name        => 'Image::Size',
    license            => 'perl',
    dist_author        => 'Randy J. Ray <rjray@blackperl.com>',
    dist_abstract      => 'A library to extract height/width from images',
    dist_version_from  => 'lib/Image/Size.pm',
    build_requires     =>
    {
        'Module::Build' => '0.28',
        'Test::More'    => '0.80',
    },
    requires           =>
    {
        'perl'       => '5.006001',
        'File::Spec' => '0.8',
    },
    recommends         =>
    {
        'Compress::Zlib' => '2',
    },
    script_files       => [ qw(imgsize) ],
    add_to_cleanup     => [ qw(Image-Size-*
                               ChangeLog
                               README
                               MANIFEST
                               MANIFEST.bak
                               META.yml
                               META.json
                               Makefile.PL) ],
    meta_merge         =>
    {
        resources =>
        {
            homepage   => 'http://search.cpan.org/dist/Image-Size',
            bugtracker => 'http://rt.cpan.org/Public/Dist/Display.html?Name=Image-Size',
            repository => 'http://github.com/rjray/image-size',
        }
    },
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();

exit 0;
