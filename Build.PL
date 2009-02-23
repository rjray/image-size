###############################################################################
#
#   Module::Build file for Image::Size
#
###############################################################################

use 5.006;
use strict;
use warnings;

use File::Spec;

use Module::Build;

my $class =
    Module::Build->subclass(class => 'Image::Size::Builder',
                            code => q|
        sub ACTION_dist
        {
            my $self = shift;

            # Create the text ChangeLog
            $self->do_system('changelog2x',
                             qw(--template text --input ChangeLog.xml),
                             qw(--output ChangeLog));

            $self->SUPER::ACTION_manifest();
            $self->SUPER::ACTION_dist();
        }
    |);

my $builder =
    $class->new(
                module_name        => 'Image::Size',
                license            => 'perl',
                dist_author        => 'Randy J. Ray <rjray@blackperl.com>',
                dist_abstract      =>
                'A library to extract height/width from images',
                dist_version       => '3.2',
                build_requires     => {
                                       'Module::Build' => '0.28',
                                       'Test::More'    => '0.80',
                                      },
                requires           => {
                                       'perl'                      => '5.006',
                                       'File::Spec'                => '0.8',
                                      },
                recommends         => {
				       'Compress::Zlib'      => '2',
                                       'Test::Pod'           => '0',
                                       'Test::Pod::Coverage' => '0',
                                      },
                add_to_cleanup     => [ qw(Image-Size-*
                                           ChangeLog
                                           MANIFEST
                                           MANIFEST.bak
					   META.yml
                                           Makefile.PL) ],
                create_makefile_pl => 'traditional',
                sign               => 'here, please',
               );

$builder->create_build_script();

exit 0;
