use ExtUtils::MakeMaker;
use Cwd 'cwd';

$cwd = cwd;

WriteMakefile(NAME         => 'Image::Size',
              ($] >= 5.005 ?
               (ABSTRACT   => 'A library to extract height/width from images',
                AUTHOR     => 'Randy J. Ray (rjray@blackperl.com)') : ()),
              dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
              PREREQ_PM    => { File::Spec => 0 },
              EXE_FILES    => ['imgsize'],
              clean        => { FILES =>
                                'Image-Size-* Image-Size.spec ' .
                                '*.rpm rpmrc rpmmacro' },
              VERSION_FROM => 'Size.pm');

sub MY::tools_other
{
    package MY;

    my $text = shift->SUPER::tools_other(@_);

    "$text\nECHO=\@echo\nRPM=rpm\n";
}

sub MY::post_constants
{
    my $self = shift;

    "SPECFILE=$self->{DISTNAME}.spec";
}

sub MY::postamble
{
    my $self = shift;

    my @text;

    #
    # Generate the spec file from <DATA> with substitutions
    #
    print "Generating $self->{DISTNAME}.spec...\n";
    $self->{RELEASE} = 1 unless $self->{RELEASE};
    $self->{INSTALLDIR} = $Config{installsitelib} unless $self->{INSTALLDIR};
    open(SPECI, "< $self->{DISTNAME}.spec.in");
    if ($?)
    {
        die "Error opening template spec file: $!, stopped";
    }
    open(SPECO, "> $self->{DISTNAME}.spec");
    if ($?)
    {
        die "Error creating output spec file: $!, stopped";
    }

    for (<SPECI>)
    {
        s/(\$\{(\w+)\})/$self->{$2}/eg;
        print SPECO $_;
    }
    close(SPECO); close(SPECI);

    print "Generating rpmrc...\n";
    open(RPMRC, "> rpmrc");
    if ($?)
    {
        die "Error creating rpmrc file: $!, stopped";
    }
    else
    {
        print RPMRC <<END_rpmrc;
include: /usr/lib/rpm/rpmrc
macrofiles: /usr/lib/rpm/macros:rpmmacro
END_rpmrc
        close(RPMRC);
    }
    print "Generating rpmmacros...\n";
    open(MACRO, "> rpmmacro");
    if ($?)
    {
        die "Error creating macro file: $!, stopped";
    }
    else
    {
        print MACRO <<END_macro;
%_rpmfilename           %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm
%_builddir              %{_topdir}
%_sourcedir             %{_topdir}
%_specdir               %{_topdir}
%_srcrpmdir             %{_topdir}
%_rpmdir                %{_topdir}
%_topdir                $cwd
END_macro
        close(MACRO);
    }

    # Create the rules that create RPM and SRPM files
    push(@text, qq{
rpm: \$(SPECFILE) \$(DISTVNAME).tar\$(SUFFIX)
\t\$(RPM) -bb --clean --rcfile rpmrc \$(SPECFILE)

srpm: \$(SPECFILE) \$(DISTVNAME).tar\$(SUFFIX)
\t\$(RPM) -bs --clean --rcfile rpmrc \$(SPECFILE)
});

    join("\n", @text);
}
