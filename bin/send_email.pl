#!/usr/bin/perl

use Mail::Mailer;

my $msgfile = "/Users/spiderman/tmp/silc-rebuild3.txt";
my $addrfile = "/Users/spiderman/tmp/silc-addresses.txt";

die "couldn't open message file" unless open(MSG,$msgfile);

my $msg = "";
while (<MSG>) {
	$msg .= $_;
}

die "couldn't open addr file" unless open(ADDR,$addrfile);

while (<ADDR>) {

$mailer = Mail::Mailer->new("sendmail");
$mailer->open( { 	To      => $_,
	        	From    => 'derek@anarres.ca',
	     		Subject => 'silc.anarres.ca will be OFFLINE briefly :(',
		})
   or die "Can't open: $!\n";

print $mailer $msg;
$mailer->close();
}

