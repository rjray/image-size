# $Id$
require 5.006;
use ExtUtils::MakeMaker;

WriteMakefile(NAME         => 'Image::Size',
              ($] >= 5.005 ?
               (ABSTRACT   => 'A library to extract height/width from images',
                AUTHOR     => 'Randy J. Ray (rjray@blackperl.com)') : ()),
              dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
              PREREQ_PM    => { File::Spec => 0, Test::More => 0,
                                Compress::Zlib => 2 },
              EXE_FILES    => ['imgsize'],
              PL_FILES     => {},
              clean        => { FILES =>
                                'Image-Size-* *.spec *.rpm rpmrc rpmmacro' },
              VERSION      => '3.1.1',
              LICENSE      => 'perl',
              SIGN         => 'here, please');
