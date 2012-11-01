#!/usr/bin/perl -w
#
# Extracts the delay of the last hop in a mailbox file
#
#
# Two modes, but you'll have to edit the file to switch between them :(
# 1. outputs human readable dates
$MODE="human";
# 2. outputs seconds since epoch
#$MODE="epoch";
#
use Mail::Box::Manager;
use Time::ParseDate;
use POSIX qw(strftime);

#
# Command line arguments
#
if (defined $ARGV[0]) {
	$MAILBOX=$ARGV[0];	
	if (! -r $MAILBOX ) {
		die "Error: mailbox $MAILBOX is not readable";
	}
} else {
	die "Error: did not provide a mailbox file as first argument";
}

#
# Open the mailbox
#
my $mgr = Mail::Box::Manager->new;
my $folder = $mgr->open(folder => $MAILBOX);

my $emails = $folder->messages;
# Different to "grep '^Subject' $MAILBOX | wc -l", because that counts subject lines in included mail messages
# print "Number of emails: $emails\n"; 

print "# arrival time, last hop time, difference (seconds)\n";

foreach $message ($folder->messages) {
#	print "============== New email ==============\n";
#	print "Subject: " . $message->subject() . "\n";
#	print $message->head . "\n";
	$header = $message->head();
	if ($header =~ m/(Received: .*?)(Received:.*?)Received/s) {
		$rec1 = $1;
		$rec2 = $2;
		$rec1 =~ s/^.*;\n*\s*//s; chomp $rec1;
		$rec2 =~ s/^.*;\n*\s*//s; chomp $rec2;

#		print "rec1: $rec1; rec2: $rec2\n";
		$sec1 = parsedate($rec1);
		$sec2 = parsedate($rec2);
#		print "sec1: $sec1; sec2: $sec2\n";

		if ($MODE=~ /human/) {
#			print "$MODE\n";
			$time1 = strftime "%Y-%m-%d-%H:%M:%S", localtime($sec1);
			$time2 = strftime "%Y-%m-%d-%H:%M:%S", localtime($sec2);
#			print "time1: $time1\n";
			print "$time1, $time2, " . ($sec1-$sec2) . "\n";
		} elsif ($MODE=~ /epoch/) {
			print "$sec1, $sec2, " . ($sec1-$sec2) . "\n";
		}

	} else {
		print "Did not match the regex\n";
	}
}


