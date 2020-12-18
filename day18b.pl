#!/usr/bin/env perl
#
# $Id: $
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

sub calc {
  my ($term) = @_;

  # For part b, evaluate all the plusses before the multiplication
  while ($term =~ s/(\d+\s\+\s\d+)/eval( $1 )/e) {
   }

  while ($term =~ s/(\d+\s\*\s\d+)/eval( $1 )/e) {
   }

  return $term;
 }

sub parse {
  my ($input) = @_;

  while ($input =~ s/\(([^()]+)\)/calc($1)/ge) {
    print "$input\n";
   }

  return calc( $input );
 }

my @input = @ARGV if (@ARGV);
@input = Path::Tiny::path( 'input18.txt' )->lines_utf8( { chomp => 1 } ) unless (@ARGV);

my $total = 0;
for my $i (@input) {
  $total += parse( $i );
 }

print "The total is $total\n";

exit;

