#!/usr/bin/env perl
#
# $Id: $
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

sub calc_sum {
  my ($expenses, $total) = @_;

  my @sorted = sort { $a <=> $b } @{ $expenses };

  for (my $i = 0; $i < @sorted - 1; $i++) {
    for (my $j = $i + 1; $j < @sorted; $j++) {
      if ($sorted[$i] + $sorted[$j] == $total) {
        return ($sorted[$i], $sorted[$j]);
       }
      elsif ($sorted[$i] + $sorted[$j] > $total) {
        last;
       }
     }
   }
 }

sub calc_sum_three {
  my ($expenses, $total) = @_;

  my @sorted = sort { $a <=> $b } @{ $expenses };

  for (my $i = 0; $i < @sorted - 2; $i++) {
    for (my $j = $i + 1; $j < @sorted - 1; $j++) {
      for (my $k = $j + 1; $k < @sorted; $k++) {
        if ($sorted[$i] + $sorted[$j] + $sorted[$k] == $total) {
          return ($sorted[$i], $sorted[$j], $sorted[$k]);
         }
        elsif ($sorted[$i] + $sorted[$j] + $sorted[$k] > $total) {
          last;
         }
       }
     }
   }
 }

my $input_file = $ARGV[0] || 'input01.txt';

my @expenses = path( $input_file )->lines_utf8( { chomp => 1 } );

my ($a, $b, $c);

($a, $b) = calc_sum( \@expenses, 2020 );

print "The product of $a and $b is ", ($a * $b), "\n";

($a, $b, $c) = calc_sum_three( \@expenses, 2020 );

print "The product of $a, $b, and $c is ", ($a * $b * $c), "\n";

exit;
