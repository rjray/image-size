use ExtUtils::MakeMaker;
WriteMakefile(NAME => 'Image::Size',
              ($] >= 5.005 ?
               (ABSTRACT   => 'A library to extract height/width from images',
                AUTHOR     => 'Randy J. Ray (rjray@tsoft.com)') : ()),
              dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
              clean => { FILES => 'imgsize' },
              realclean => { FILES => 'imgsize' },
              EXE_FILES => ['imgsize'],
              VERSION_FROM => 'Size.pm');
