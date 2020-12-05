#!/usr/bin/env perl
#
# Converting binary to decimal. The easiest way is 'oct()', not pack()!
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

sub id {
  my ($pass) = @_;

  $pass =~ tr/FBLR/0101/; 

  my $row = oct( '0b' . substr( $pass, 0, 7 ) );
  my $seat = oct( '0b' . substr( $pass, 7, 3 ) );

  return $row * 8 + $seat;
 }

#
# Check if there is a difference of exactly 2 between seats
#
sub my_row {
  my (@passes) = @_;
  for (my $i = 1; $i < @passes - 1; $i++) {
    if ($passes[$i] - $passes[$i-1] == 2) {
      return ($passes[$i] - 1);
     }
   }
  return; 
 }

my $input_file = $ARGV[0] || 'input05.txt';

my @passes;
my $max_id = 0;
for my $pass (path( $input_file )->lines_utf8( { chomp => 1 } )) {
  my $id = id( $pass );
  $max_id = $id if ($id > $max_id);
  push @passes, $id;
 }

print "The maximum id is $max_id\n";

print "My seat id is ", my_row( sort { $a <=> $b } @passes ), "\n";

exit;
