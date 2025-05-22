#!/usr/bin/perl

use Mail::Mailer;

my $msgfile = "~/txt/message.txt";
my $addrfile = "~/txt/addresses.txt";

die "couldn't open message file" unless open(MSG,$msgfile);

my $msg = "";
while (<MSG>) {
	$msg .= $_;
}

die "couldn't open addr file" unless open(ADDR,$addrfile);

while (<ADDR>) {

$mailer = Mail::Mailer->new("sendmail");
$mailer->open( { 	To      => $_,
	        	From    => 'me@mydomain.ca',
	     		Subject => 'Subject',
		})
   or die "Can't open: $!\n";

print $mailer $msg;
$mailer->close();
}

