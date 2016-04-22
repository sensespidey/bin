#!/usr/bin/perl
# Simple script to preprocess a users.csv and groups.csv from Exchange 2003 for import into zimbra

# Set up
use strict; no strict qw(refs);

use Getopt::Long;
use Class::CSV;
use Data::Dumper;

# Variables
my %options; my $DEBUG = 1;
GetOptions(\%options, 'help|h', 'verbose|v', 'dir|d', 'users|u', 'groups|g', 'output|o');
if ($options{'verbose'}) { print STDERR "Increasing verbosity..\n"; $DEBUG++; }
if ($options{'help'}) { &usage; exit; }

# default files
if (!$options{'dir'}) { $options{'dir'} = "~/tmp/zcs"; }
if (!$options{'users'}) { $options{'users'} = 'users2016.csv'; }
if (!$options{'groups'}) { $options{'groups'} = 'groups2016.csv'; }
if (!$options{'output'}) { $options{'output'} = 'zmprov'; }

sub usage {
  print STDERR
  "Usage: $0 [-hv] -d <output-dir> -u <users-csv> -g <groups-csv> -o <out-csv>

  -h help (print this usage statement)
  -v verbose 
  -d dir directory for input/output files (default: ~/tmp/zcs)
  -u users CSV file (default: ~/tmp/zcs/users2016.csv)
  -g groups CSV file (default: ~/tmp/zcs/groups2016.csv)
  -o output CSV file prefix (default: zmprov - 2 files are written <prefix>.users.csv and <prefix>.groups.csv)
\n";
}

# MAIN ROUTINE
# 1. Parse
# 2. Map names to emails
# 3. Write relevant details to output CSVs

my %user_emails;
my $users = Class::CSV->parse(
  filename => glob($options{'dir'} . '/' . $options{'users'}),
  fields => [qw/Name AlternateRecipientForwarding Description DisplayName EmailAddress FirstName JobTitle LastName TelephoneNumber Username/]
);
my $users_out = Class::CSV->new( fields => [qw/email givenName sn cn description title telephoneNumber/]);

my $count = 0;
foreach my $line (@{$users->lines()}) {
  next if (!$count++);
  if ($line->EmailAddress =~ /.*\@rnao.org/i) {
    my $email = lc($line->EmailAddress);
    $email =~ s/rnao.org/rnao.ca/;

    $user_emails{$line->Name} = $email;
    $users_out->add_line({
        email           => $email,
        givenName       => $line->FirstName,
        sn              => trim($line->LastName),
        cn              => trim($line->Name),
        description     => trim($line->Description),
        title           => trim($line->JobTitle),
        telephoneNumber => trim($line->TelephoneNumber)
      }
    );
  }
  $count++;
}
&write_csv(glob($options{'dir'}.'/'.$options{'output'}.'.users.csv'), $users_out);

&debug(1, "Parsed and wrote $count user emails..");
&debug(2, Dumper(\%user_emails));

my %group_emails;
my $groups = Class::CSV->parse(
  filename => glob($options{'dir'} . '/' . $options{'groups'}),
  fields => [qw/Name GroupMembersAll MailboxAlias NumberOfDirectMembers PrimarySMTPAddress/]
);
my $groups_out = Class::CSV->new( fields => [qw/groupAddress groupMembers/]);

$count = 0;
foreach my $line(@{$groups->lines()}) {
  next if (!$count++);

  my $group_mail = lc($line->PrimarySMTPAddress);
  $group_mail =~ s/rnao.org/rnao.ca/;
  my @group_members = split(/;/, $line->GroupMembersAll);

  chomp(@group_members);
  map { s!\(Users/rnao.org\)!!; s!^\s+!!; s!\s+$!!; } @group_members;

  my @group_emails = map { $user_emails{$_}; } @group_members;
  $group_emails{$group_mail} = \@group_emails;
  $count++;

  $groups_out->add_line({
      groupAddress => $group_mail,
      groupMembers => join " ", @group_emails,
    }
  );
}
&write_csv(glob($options{'dir'}.'/'.$options{'output'}.'.groups.csv'), $groups_out);

&debug(1, "Parsed $count distribution group emails..");
&debug(2, Dumper(\%group_emails));

sub debug {
  my($level, $msg) = @_;
  
  if ($DEBUG >= $level) {
    printf("%d: %s\n", $level, $msg);
  }
}

sub write_csv {
  my($filename, $class_csv) = @_;
  open(my $fh, '>', $filename) or die "Unable to open $filename for writing: $!";
  print $fh $class_csv->string();
  close($fh);
}

sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
