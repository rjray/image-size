#!/usr/local/bin/perl

use Config;
use File::Basename qw(&basename &dirname);

# List explicitly here the variables you want Configure to
# generate.  Metaconfig only looks for shell variables, so you
# have to mention them as if they were shell variables, not
# %Config entries.  Thus you write
#  $startperl
# to ensure Configure will look for $Config{startperl}.

# This forces PL files to create target in same directory as PL file.
# This is so that make depend always knows where to find PL derivatives.
chdir(dirname($0));
($file = basename($0)) =~ s/\.PL$//;
$file =~ s/\.pl$//
	if ($Config{'osname'} eq 'VMS' or
	    $Config{'osname'} eq 'OS2');  # "case-forgiving"

open OUT,">$file" or die "Can't create $file: $!";

print "Extracting $file (with variable substitutions)\n";

# In this section, perl variables will be expanded during extraction.
# You can use $Config{...} to use Configure variables.

print OUT <<"!GROK!THIS!";
$Config{'startperl'}
    eval 'exec perl -S \$0 "\$@"'
	if 0;
!GROK!THIS!

# In the following, perl variables are not expanded during extraction.

print OUT <<'!NO!SUBS!';

#
# No-brainer to size an image supplied on the command-line. All the real
# work is done in Image::Size
#

=head1 NAME

imgsize - read the dimensions of an image in several popular formats

=head1 SYNOPSIS

 imgsize [ -r | -a | -f fmt ] file

=head1 DESCRIPTION

No-brainer to size an image supplied on the command-line. All the real
work is done in L<Image::Size>

=head1 OPTIONS

By default, the width and height are returned as attributes for an IMG tag
in HTML, essentially "C<WIDTH=40 HEIGHT=30>". The following options may be
used to return alternate formats (all report width first, then height):

=over

=item C<-r>

Return "raw" format data. Just the numbers separated by a single space.

=item C<-a>

Return a Perl-style list of attributes suitable for passing to the C<img()>
method of the CGI module (see L<CGI>).

=item C<-f> B<fmt>

Pass the string specified in I<fmt> to C<sprintf> and thus use it to format
the results to your taste. C<sprintf> will be passed two numbers, so any
other formatting directives will be lost. The numbers are passed as width
first, then height.

=head1 SEE ALSO

L<Image::Size>

=head1 AUTHOR

Randy J. Ray <rjray@tsoft.com>

=cut

use strict;
use Image::Size qw(:all);
use Getopt::Std;
use vars qw($opt_h $opt_r $opt_a $opt_f);

my $rtn;

&getopts('hraf:');

#
# Usage reporting: if -h, or no @ARGV, or more than one of the rest...
#
die sprintf("Usage: %s [ -r | -a | -f fmt ] file ...\n", ($0 =~ m|.*/(.*)|o))
    if ($opt_h || (! @ARGV) || (($opt_a && $opt_r) || ($opt_a && $opt_f) ||
                                ($opt_r && $opt_f)));

$rtn = \&return_html;
$opt_a &&
    ($rtn = \&return_attr);
$opt_r &&
    ($rtn = \&return_imgsize);
$opt_f &&
    ($rtn = \&return_fmt);

if (@ARGV > 1)
{
    foreach (@ARGV)
    {
        print STDOUT sprintf("$_: %s\n", &$rtn($_));
    }
}
else
{
    print STDOUT sprintf("%s\n", &$rtn($ARGV[0]));
}

exit;

#
# Note the doubled calls here. This is just a quick, semi-clean attempt at
# functionality. As it happens, the second call will be a cache hit within
# the Image::Size package.
#

sub return_attr
{
    my ($width, $height, $err) = imgsize($_[0]);

    return ((defined $width) ?
            sprintf("(%s => %d, %s => %d)", attr_imgsize($_[0])) :
            "error: $err");
}

sub return_imgsize
{
    my ($width, $height, $err) = imgsize($_[0]);

    return ((defined $width) ?
            sprintf("%d %d", imgsize($_[0])) :
            "error: $err");
}

sub return_fmt
{
    my ($width, $height, $err) = imgsize($_[0]);

    return ((defined $width) ?
            sprintf($opt_f, imgsize($_[0])) :
            "error: $err");
}

sub return_html
{
    my ($width, $height, $err) = imgsize($_[0]);

    return ((defined $width) ?
            sprintf("WIDTH=%d HEIGHT=%d", imgsize($_[0])) :
            "error: $err");
}
!NO!SUBS!

close OUT or die "Can't close $file: $!";
chmod 0755, $file or die "Can't reset permissions for $file: $!\n";
exec("$Config{'eunicefix'} $file") if $Config{'eunicefix'} ne ':';
