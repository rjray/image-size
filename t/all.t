#!./perl

use lib '../blib/lib';
use Image::Size qw(:all);

($dir = $0) =~ s/\w+\.t$//o;

print "1..6\n";

($x, $y) = imgsize("${dir}home.gif");
print (($x == 30 && $y == 30) ? "ok 1\n" : "not ok 1\n");

$html = html_imgsize("${dir}chalk.jpg");
print (($html =~ /width=96\s+height=96/oi) ? "ok 2\n" : "not ok 2\n");

@attrs = attr_imgsize("${dir}xterm.xpm");
print (($attrs[1] == 64 && $attrs[3] == 38) ? "ok 3\n" : "not ok 3\n");

($x, $y) = imgsize("${dir}spacer50.xbm");
print (($x == 50 && $y == 10) ? "ok 4\n" : "not ok 4\n");

($x, $y) = imgsize("some non-existant file");
print (($y =~ /can\'t open/oi) ? "ok 5\n" : "not ok 5\n");

# Dave is actually a valid GIF, but the library still depends on extension:
($x, $y) = imgsize("${dir}dave.jpg");
print (($y =~ /this is not a jpeg/oi) ? "ok 6\n" : "not ok 6\n");

exit;
