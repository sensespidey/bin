#!/usr/bin/perl
#
# Usage: drop-bouncer [-s <sitename> | -u <slash virtual user>]
#                     -e <email address> [-e <email> ...]
#
# Removes the user using the listed email address from the site specified.
#
#  -s, --sitename  specify the name of the site from which to drop the user
#                  [nologo.org, slash.openflows.org, reconstructionreport.org]
#  -u, --user      slash virtual user (see perldoc DBIx::Password)
#  -e, --email     email address of user which is bouncing [email@inter.net]


use DBI;
use DBIx::Password;
use strict;
use Getopt::Long;

my($help,$slashuser,$sitename,@emails);
my(%optctl) = ('help' => \$help, 'user' => \$slashuser, 'sitename' => \$sitename, 'email'=>\@emails);
my(@opts) = ('help','user=s','sitename=s','email=s');
my($args) = GetOptions(\%optctl,@opts);

if ($help || ($sitename eq "" && $slashuser eq "")) {
  die(usage());
}

if (@emails == 0) { printf("No email specified!\n"); die(usage());}

# if a sitename was provided, then convert that into a slash virtual user
# name
if ($sitename && $slashuser eq "") {
  printf("translating given sitename: [%s]\n",$sitename);
  my($sitefile) = "/usr/local/slash/slash.sites";
  unless (open(SITEFILE,$sitefile)) {
    printf("Couldn't find $sitefile!\n"); die(usage());
  }

  # read through the file, splitting lines on : and, checking for sitename in
  # last element (be careful: the user might've put a www. on the front
  # that doesn't show up.
  $sitename =~ s/^www\.//;
  while (<SITEFILE>) { 
    my($user,$sysuid,$site) = split(/:/); # get 1st and 3rd elements
    printf("[sitefile]: user=%s\tsite=%s\n",$user,$site);
    if ($site =~ /$sitename/) { $slashuser = $user; }
  }
  close(SITEFILE);
}

printf("found slashuser: [%s]\n",$slashuser);

my $dbh = DBIx::Password->connect($slashuser);

foreach (@emails) { 

  printf("email: $_\n");
  drop_bouncer($dbh,$_);
  
}

sub drop_bouncer {
  my($dbh,$email) = @_;
  $email = $dbh->quote($email);
  my($sth);

  my($sql) = "select uid from users where realemail =" . $email;
  $sth = $dbh->prepare($sql); $sth->execute();
  my($uid) = $sth->fetchrow_array();
  $sth->finish();
  printf("found uid for [%s]: %s\n",$email,$uid);

  $sql = "select param_id from users_param where uid=" . $uid;
  $sth = $dbh->prepare($sql); $sth->execute();
  my($param_id) = $sth->fetchrow_array();
  $sth->finish();
  printf("found param_id for uid(%s) [%s]: %s\n",$uid,$email,$param_id);

  $sql = "delete from users_param where param_id =" . $param_id;
  $sth = $dbh->prepare($sql); $sth->execute();
  $sth->finish();
  printf("deleted param_id from users_param table\n");
}

sub usage {
  my $return;
  $return .= sprintf("Usage: drop-bouncer [-s <sitename> | -u <slash virtual user>]\n");
  $return .= sprintf("                    -e <email address> [-e <email> ...]\n");
  $return .= sprintf(" Removes the user using the listed email address from the site specified.\n");
  $return .= sprintf("\n");
  $return .= sprintf("  -s, --sitename  specify the name of the site from which to drop the user\n");
  $return .= sprintf("                  [nologo.org, slash.openflows.org, reconstructionreport.org]\n");
  $return .= sprintf("  -u, --user      slash virtual user (see perldoc DBIx::Password)\n");
  $return .= sprintf("  -e, --email     email address of user which is bouncing [email\@inter.net]\n");
  $return .= sprintf("\n");
  return $return;
}
