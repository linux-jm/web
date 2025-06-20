#!/usr/bin/env perl

use File::Basename qw/basename/;
use Getopt::Std qw/getopts/;

$debug = 0;
$page_count = 0;
$pages = (
    "over80", 0,
    "over70", 0,
    "over60", 0
);
%opts = ();
%exclude_pages = ();

sub print_header {
    print <<EOF;
<HTML>
<HEAD><TITLE>Translation status of LDP man-pages</TITLE>
<STYLE type="text/css">
<!--
 tr.over80 { background-color: #AAFFAA; }
 tr.over70 { background-color: #FFAAFF; }
 tr.title { background-color: yellow; text-align: center; font-weight: bold; }
-->
</STYLE>
</HEAD>
<BODY>
<TABLE BORDER=1>
<TR class="over80"><TD COLSPAN=3>Released pages but not completed (released if &gt;=80%)</TD></TR>
<TR class="over70"><TD COLSPAN=3>Near release pages (&gt;= 70%)</TD></TR>
<TR><TH>page name</TH><TH>remaining</TH><TH>comp. %</TH></TR>
EOF
}

sub print_footer {
    my $over80 = $pages{"over80"};
    my $over70 = $pages{"over70"};
    my $over60 = $pages{"over60"};
    my $others = $page_count - ($over80 + $over70 + $over60);
    print <<EOF;
<TR class="title"><TD COLSPAN=3>Summary</TD></TR>
<TR><TD COLSPAN=3>
<UL>
<LI>Total uncompleted: $page_count
<LI>&gt;=80%: $over80
<LI>&gt;=70%: $over70
<LI>&gt;=60%: $over60
<LI>&lt;60%: $others
</UL>
</TD></TR>
</TABLE>
</BODY></HTML>
EOF
}

sub print_poname {
    my $poname = shift;
    printf("<TR class=\"title\"><TD COLSPAN=3>%s</TD></TR>\n", $poname);
}

sub print_manpage {
    my ($page, $all, $remaining, $ratio) = @_;
    if ($ratio >= 80) {
        print '<TR class="over80">';
    } elsif ($ratio >= 70) {
        print '<TR class="over70">';
    } else {
	print '<TR>';
    }
    printf("<TD>%s</TD><TD>%d/%d</TD><TD>%.2f</TD>",
	   $page, $remaining, $all, $ratio);
    print "</TR>\n";
}

sub process_postat {
    my $postat = shift;
    my $poname = basename($postat);
    my $poname_print = 1;

    open(POSTAT, $postat);
    while (<POSTAT>) {
	next if /^#/;
	# format: pagename, #complete, #remaining, #total
	my ($page, $comp, $remaining, $total) = split(',');
	next if (defined $opts{"e"} && defined $exclude_pages{$page});
	$ratio = $comp / $total * 100;
	if ($poname_print) {
	    print_poname($poname);
	    $poname_print = 0;
	}
	print_manpage($page, $total, $remaining, $ratio);
	$page_count++;
	if ($ratio >= 80) {
	    $pages{"over80"}++;
	} elsif ($ratio >= 70) {
	    $pages{"over70"}++;
	} elsif ($ratio >= 60) {
	    $pages{"over60"}++;
	}
    }
}

sub read_exclude_list {
    my $file = shift;
    open(EXCLUDES, $file);
    while(<EXCLUDES>) {
	next if /^#/;
	chop;
	my $page = $_;
	$exclude_pages{$page} = 1;
    }
}

getopts("de:", \%opts);
if (defined $opts{"d"}) {
    $debug = 1;
}
if (defined $opts{"e"}) {
    read_exclude_list($opts{"e"});
}

print_header();
foreach my $name (sort @ARGV) {
    print STDERR "$name...\n" if $debug;
    process_postat($name);
}
print_footer();
