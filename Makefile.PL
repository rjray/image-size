use ExtUtils::MakeMaker;
WriteMakefile(NAME => 'Image::Size',
              dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
              EXE_FILES => ['imgsize'],
              VERSION_FROM => 'Size.pm');
