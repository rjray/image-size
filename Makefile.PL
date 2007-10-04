# $Id$
use ExtUtils::MakeMaker;
use Cwd 'cwd';

$cwd = cwd;

WriteMakefile(NAME         => 'Image::Size',
              ($] >= 5.005 ?
               (ABSTRACT   => 'A library to extract height/width from images',
                AUTHOR     => 'Randy J. Ray (rjray@blackperl.com)') : ()),
              dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
              PREREQ_PM    => { File::Spec => 0, Test::More => 0, },
              EXE_FILES    => ['imgsize'],
              clean        => { FILES =>
                                'Image-Size-* *.spec *.rpm rpmrc rpmmacro' },
              VERSION_FROM => 'lib/Image/Size.pm',
              LICENSE      => 'perl',
              SIGN         => 'here, please');
