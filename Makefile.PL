use ExtUtils::MakeMaker;
WriteMakefile(NAME => 'Image::Size',
              dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
              clean => { FILES => 'imgsize' },
              realclean => { FILES => 'imgsize' },
              EXE_FILES => ['imgsize'],
              VERSION_FROM => 'Size.pm');
