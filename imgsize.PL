#!/usr/bin/perl
#
# No-brainer to size an image supplied on the command-line. All the real
# work is done in Image::Size
#

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
