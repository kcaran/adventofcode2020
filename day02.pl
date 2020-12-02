#!/usr/bin/env perl
#
# $Id: $
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

sub check_pass {
  my ($range, $let, $pass) = @_;

  $let = substr( $let, 0, 1 );
  my @cnt = ($pass =~ /$let/g);

  my ($min, $max) = ($range =~ /^(\d+)\-(\d+)/);

  return ($min <= @cnt && @cnt <= $max) ? 1 : 0;
 }

sub check_pass_2nd {
  my ($range, $let, $pass) = @_;

  $let = substr( $let, 0, 1 );
  my ($pos1, $pos2) = ($range =~ /^(\d+)\-(\d+)/);

  my $count = (substr( $pass, $pos1 - 1, 1 ) eq $let) + (substr( $pass, $pos2 - 1, 1 ) eq $let);

  return ($count == 1 ? 1 : 0);
 }

my $input_file = $ARGV[0] || 'input02.txt';

my @passwords = path( $input_file )->lines_utf8( { chomp => 1 } );

my $valid_1 = 0;
my $valid_2 = 0;
 
for my $p (@passwords) {
   $valid_1 += check_pass( split( /\s+/, $p ) );
   $valid_2 += check_pass_2nd( split( /\s+/, $p ) );
  }

print "The number of valid passwords for part 1 is $valid_1\n";
print "The number of valid passwords for part 2 is $valid_2\n";

exit;
