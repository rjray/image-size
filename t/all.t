#!./perl

use lib '../blib/lib';
use IO::File;
use Image::Size qw(:all);

($dir = $0) =~ s/\w+\.t$//o;

print "1..14\n";

#
# Phase one, tests 1-10: basic types tested on files.
#
($x, $y) = imgsize("${dir}test.gif");
print (($x == 60 && $y == 40) ? "ok 1\n" : "not ok 1\n");

$html = html_imgsize("${dir}letter_T.jpg");
print (($html =~ /width=52\s+height=54/oi) ? "ok 2\n" : "not ok 2\n");

@attrs = attr_imgsize("${dir}xterm.xpm");
print (($attrs[1] == 64 && $attrs[3] == 38) ? "ok 3\n" : "not ok 3\n");

($x, $y) = imgsize("${dir}spacer50.xbm");
print (($x == 50 && $y == 10) ? "ok 4\n" : "not ok 4\n");

($x, $y, $err) = imgsize("some non-existant file");
print (($err =~ /can\'t open/oi) ? "ok 5\n" : "not ok 5\n");

# Dave is actually a valid GIF, but this should work:
($x, $y) = imgsize("${dir}dave.jpg");
print (($x == 43 && $y == 50) ? "ok 6\n" : "not ok 6\n");

# Test PNG image supplied by Tom Metro:
($x, $y) = imgsize("${dir}pass-1_s.png");
print (($x == 90 && $y == 60) ? "ok 7\n" : "not ok 7\n");

# Test PPM image code supplied by Carsten Dominik:
($x, $y, $id) = imgsize("${dir}letter_N.ppm");
print (($x == 66 && $y == 57 && $id eq 'PPM') ? "ok 8\n" : "not ok 8\n");

# Test TIFF image code supplied by Cloyce Spradling
($x, $y, $id) = imgsize("${dir}lexjdic.tif");
print (($x == 35 && $y == 32 && $id eq 'TIF') ? "ok 9\n" : "not ok 9\n");
($x, $y, $id) = imgsize("${dir}bexjdic.tif");
print (($x == 35 && $y == 32 && $id eq 'TIF') ? "ok 10\n" : "not ok 10\n");

# Test BMP code from Aldo Calpini
($x, $y, $id) = imgsize("${dir}xterm.bmp");
print (($x == 64 && $y == 38 && $id eq 'BMP') ? "ok 11\n" : "not ok 11\n");

#
# Phase two: tests on in-memory strings.
#
$fh = new IO::File "< ${dir}test.gif";
$data = '';
read $fh, $data, (stat "${dir}test.gif")[7];
$fh->close;
($x, $y, $id) = imgsize(\$data);
print (($x == 60 && $y == 40 && $id eq 'GIF') ? "ok 12\n" : "not ok 12\n");

#
# Phase three: tests on open IO::File objects.
#
$fh = new IO::File "< ${dir}test.gif";
($x, $y, $id) = imgsize($fh);
print (($x == 60 && $y == 40 && $id eq 'GIF') ? "ok 13\n" : "not ok 13\n");

# Reset to head
$fh->seek(0, 0);
# Move somewhere
$fh->seek(128, 0);
# Do it again. This time when we check results, $fh->tell should be 128
($x, $y, $id) = imgsize($fh);
print STDOUT (($x == 60 && $y == 40 && $id eq 'GIF' && ($fh->tell == 128)) ?
              "ok 14\n" : "not ok 14\n");

$fh->close;

exit;
