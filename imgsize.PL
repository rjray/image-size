use Config;
use File::Basename qw(basename dirname);
chdir(dirname($0));
($file = basename($0)) =~ s/\.PL$//;
$file =~ s/\.pl$//
	if ($Config{'osname'} eq 'VMS' or
	    $Config{'osname'} eq 'OS2');  # "case-forgiving"
open OUT,">$file" or die "Can't create $file: $!";
chmod(0755, $file);
print "Extracting $file (with variable substitutions)\n";

print OUT <<"!GROK!THIS!";
$Config{'startperl'} -w
    eval 'exec perl -S \$0 "\$@"'
	if 0;

!GROK!THIS!

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

=head1 SEE ALSO

L<Image::Size>

=head1 AUTHOR

Randy J. Ray <rjray@uswest.com>

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

$rtn = \&html_imgsize;
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

sub return_attr { sprintf("(%s => %d, %s => %d)", attr_imgsize($_[0])) }

sub return_imgsize { sprintf("%d %d", imgsize($_[0])) }

sub return_fmt { sprintf($opt_f, imgsize($_[0])) }
!NO!SUBS!
