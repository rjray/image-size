###############################################################################
#
# This code lifted almost verbatim from wwwis by Alex Knowles, alex@ed.ac.uk
#
# Minor changes (removed setting of globals) to imgsize() and structuring into
# Perl5 package form by rjray@uswest.com.
#
# Release 1.1:
#   Fixed bug in jpegsize
#   Clarified some comments and docs
# Up to release 1.0:
#   Turned sizing into a library
#   Added two wrappers to pre-format size into HTML or CGI attributes
#   Added cacheing of sizes for multiple calls (I have a script that emits the
#     same image 35+ times!)
#   Simple test suite to test each image type I have a sample of (all save for
#     PNG) and some of the error conditions. MakeMaker utility automatically
#     configures in the test suite.
#
###############################################################################

package Image::Size;

=head1 NAME

Image::Size - read the dimensions of an image in several popular formats

=head1 SYNOPSIS

    use Image::Size;
    # Get the size of globe.gif
    ($globe_x, $globe_y) = &imgsize("globe.gif");
    # Assume X=60 and Y=40 for remaining examples

    use Image::Size 'html_imgsize';
    # Get the size as "HEIGHT=X WIDTH=Y" for HTML generation
    $size = &html_imgsize("globe.gif");
    # $size == "HEIGHT=60 WIDTH=40"

    use Image::Size 'attr_imgsize';
    # Get the size as a list passable to routines in CGI.pm
    @attrs = &attr_imgsize("globe.gif");
    # @attrs == ('-HEIGHT', 60, '-WIDTH', 40)

=head1 DESCRIPTION

The B<Image::Size> library is based upon the C<wwwis> script written by
Alex Knowles I<(alex@ed.ac.uk)>, a tool to examine HTML and add HEIGHT and
WIDTH parameters to image tags. The sizes are cached internally based on
file name, so multiple calls on the same file name (such as images used
in bulleted lists, for example) does not repeat computation.

B<Image::Size> provides three interfaces for possible import:

=over

=item imgsize(file)

Returns a two-item list of the X and Y dimensions (height and width, in
that order) of I<file>. Errors are noted by a -1 value for the first element,
and an error string for the second.

=item html_imgsize(file)

Returns the height and width (X and Y) of I<file> pre-formatted as a single
string C<"HEIGHT=X WIDTH=Y"> suitable for addition into generated HTML IMG
tags.

=item attr_imgsize(file)

Returns the height and width of I<file> as part of a 4-element list useful
for routines that use hash tables for the manipulation of named parameters,
such as the Tk or CGI libraries. A typical return value looks like
C<("-HEIGHT", X, "-WIDTH", Y)>.

=back

By default, only C<imgsize()> is imported. Any one or
combination of the three may be imported, or all three may be with the
tag B<:all>.

=head1 DIAGNOSTICS

The base routine, C<imgsize>, returns a -1 as the first value in its list
when an error has occured. The second return element contains a descriptive
error message.

The second and third forms blindly format the returned data of C<imgsize>,
and as such may return corrupted data in the event of an error.

=head1 CAVEATS

Current implementation can operate only on files, and uses the suffix
of the file name to determine how to examine the file. Thus, files with
no suffix or an incorrect suffix will not be sized correctly. Suffixes
are treated in a case-independant manner. Currently recognized suffixes
are: JPEG, JPG, GIF, PNG, XBM and XPM.

I have no PNG-format files on which to test the PNG sizing. I can only
trust that it works.

This will reliably work on perl 5.002 or newer. Perl versions prior to
5.003 do not have the B<IO::File> module by default, which this module
requires. You will have to retrieve and install it, or upgrade to 5.003,
in which it is included as part of the core.

=head1 SEE ALSO

C<http://www.tardis.ed.ac.uk/~ark/wwwis/> for a description of C<wwwis>
and how to obtain it.

=head1 AUTHORS

Perl module interface by Randy J. Ray I<(rjray@uswest.com)>, original
image-sizing code by Alex Knowles I<(alex@ed.ac.uk)> and Andrew Tong
I<(werdna@ugcs.caltech.edu)>, used with their joint permission.

=cut

require 5.002;

use strict;
use IO::File;
use AutoLoader;
use Exporter;
use vars qw($revision $VERSION); # Defeat "used only once" warnings

@Image::Size::ISA         = qw(Exporter AutoLoader);
@Image::Size::EXPORT      = qw(imgsize);
@Image::Size::EXPORT_OK   = qw(imgsize html_imgsize attr_imgsize);
%Image::Size::EXPORT_TAGS = (q/all/ => [@Image::Size::EXPORT_OK]);

$Image::Size::revision    = q/$Id: Size.pm,v 1.2 1996/09/04 21:18:52 rjray Exp $/;
$Image::Size::VERSION     = "1.1";

# Package lexical - invisible to outside world, used only in imgsize
my %_cache = ();

1;

sub imgsize
{
    my ($file, $optional) = @_;
    
    if (defined $_cache{$file})
    {
        return (split(/,/, $_cache{$file}));
    }

    my $stream;
    my ($x, $y);

    if (defined $optional)
    {
        if ((ref $optional) eq "SCALAR")
        {
            ($file = "$optional/$file") =~ s|//|/|o;
        }
        elsif ((ref $optional) eq "CODE")
        {
            $file = &optional($file);
        }
        # For now, I ignore other type for $optional
    }

    #first try to open the file
    if (! ($stream = new IO::File "< $file"))
    {
        $y = "Can't open image file $file: $!";
        $x = -1;
    }
    else
    {
        if ($file =~ /.jpg/oi || $file =~ /.jpeg/oi)
        {
            ($x, $y) = &jpegsize($stream);
        }
        elsif ($file =~ /.gif/oi)
        {
            ($x, $y) = &gifsize($stream);
        }
        elsif ($file =~ /.xbm/oi)
        {
            ($x, $y) = &xbmsize($stream);
        }
        elsif ($file =~ /.xpm/oi)
        {
            ($x, $y) = &xpmsize($stream);
        }
        elsif ($file =~ /.png/oi)
        {
            ($x, $y) = &pngsize($stream);
        }
        else
        {
            $y = "$file is not gif, xbm, xpm, jpeg or png (or has bad name)";
            $x = -1;
        }
        
        $stream->close;
    }

    #
    # Added as an afterthought: I'm probably not the only one who uses the
    # same shaded-sphere image for several items on a bulleted list:
    #
    $_cache{$file} = join(',', $x, $y);
    return ($x, $y);
}

sub html_imgsize
{
    return sprintf("WIDTH=%d HEIGHT=%d", imgsize(@_));
}

sub attr_imgsize
{
    return ((imgsize(@_), '-WIDTH', '-HEIGHT')[2, 0, 3, 1]);
}

__END__

###########################################################################
# Subroutine gets the size of the specified GIF
###########################################################################
sub gifsize
{
    my ($GIF) = @_;
    
    my $type = 0;
    my $s = 0;
    my ($a, $b, $c, $d, $x, $y);
    
    read($GIF, $type, 6); 
    if (! ($type =~ /GIF8[7,9]a/) || ! (read($GIF, $s, 4) == 4))
    {
        $y = "Invalid or Corrupted GIF";
        $x = -1;
    }
    else
    {
        ($a, $b, $c, $d) = unpack("C"x4,$s);
        $x = $b<<8|$a;
        $y = $d<<8|$c;
    }
    
    return ($x, $y);
}

sub xbmsize
{
    my ($XBM) = @_;
    my ($input) = "";
    my ($x, $y);
    
    $input .= <$XBM>;
    $input .= <$XBM>;
    if ($input =~ /\#define\s*\S*\s*(\d*)\s*\n\#define\s*\S*\s*(\d*)\s*\n/i)
    {
        ($x, $y) = ($1, $2);
    }
    else
    {
        $y = "Hmmm... Doesn't look like an XBM file";
        $x = -1;
    }

    return ($x, $y);
}

# Added by Randy J. Ray, 30 Jul 1996
# Size an XPM file by looking for the "X Y N W" line, where X and Y are
# dimensions, N is the total number of colors defined, and W is the width of
# a color in the ASCII representation, in characters. We only care about X & Y.
sub xpmsize
{
    my ($xpm) = @_;
    my $line;
    my ($x, $y) = (-1, "Could not determine XPM size");

    while ($line = <$xpm>)
    {
        next unless ($line =~ /"(\d+)\s+(\d+)\s+\d+\s+\d+"/o);
        ($x, $y) = ($1, $2);
        last;
    }

    return ($x, $y);
}


#  pngsize : gets the width & height (in pixels) of a png file
# cor this program is on the cutting edge of technology! (pity it's blunt!)
sub pngsize
{
    my ($PNG) = @_;
    my ($head) = "";
    my ($x) = -1;
    my ($y) = -1;
    
    if (read($PNG, $head, 8) == 8 &&
        $head eq "\x89\x50\x4e\x47\x0d\x0a\x1a\x0a" &&
        read($PNG, $head, 4) == 4 &&
        read($PNG, $head, 4) == 4 &&
        $head eq "IHDR" &&
        read($PNG, $head, 8) == 8)
    {
        ($x, $y) = unpack("I"x2, $head);
    }
    else
    {                           
        $y = "Hmmm... Doesn't look like a PNG file\n";
        $x = -1;
    }

    return ($x, $y);
}

# jpegsize : gets the width and height (in pixels) of a jpeg file
# Andrew Tong, werdna@ugcs.caltech.edu           February 14, 1995
# modified slightly by alex@ed.ac.uk
# and further still by rjray@uswest.com
sub jpegsize
{
    my ($JPEG) = @_;
    my ($done) = 0;
    my ($x, $y);
    my ($ch, $c1, $c2, $a, $b, $c, $d, $s, $junk, $length);
    
    # Get rid of "Use of unitialized value..." carping
    $c1 = $c2 = $ch = $s = $length = $junk = 0;
    read($JPEG, $c1, 1); read($JPEG, $c2, 1);
    if(! ((ord($c1) == 0xFF) && (ord($c2) == 0xD8)))
    {
        $y = "This is not a JPEG!";
        $x = -1;
        $done = 1;
    }
    while (ord($ch) != 0xDA && !$done)
    {
        # Find next marker (JPEG markers begin with 0xFF)
        # This can hang the program!!
        while (ord($ch) != 0xFF) { read($JPEG, $ch, 1) }
        # JPEG markers can be padded with unlimited 0xFF's
        while (ord($ch) == 0xFF) { read($JPEG, $ch, 1) }
        # Now, $ch contains the value of the marker.
        if ((ord($ch) >= 0xC0) && (ord($ch) <= 0xC3))
        {
            read($JPEG, $junk, 3); read($JPEG, $s, 4);
            ($a, $b, $c, $d) = unpack("C"x4, $s);
            $y = $a<<8|$b;
            $x = $c<<8|$d;
            $done = 1;
        } else {
            # We **MUST** skip variables, since FF's within variable names are
            # NOT valid JPEG markers
            read($JPEG, $s, 2); 
            ($c1, $c2) = unpack("C"x2, $s);
            $length = $c1<<8|$c2;
            if ($length < 2)
            {
                $y = "Erroneous JPEG marker length";
                $x = -1;
                $done = 1;
            }
            else
            {
                read($JPEG, $junk, $length-2);
            }
        }
    }

    return ($x, $y);
}
