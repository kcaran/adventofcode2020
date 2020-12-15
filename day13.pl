#!/usr/bin/env perl
#
# I had no idea what the Chinese Remainder Theorem or how to use it!
#
# Find the LCM of the buses you have seen so far, and then brute force
# the multiple of that LCM that satisfies the next bus.
#
# https://www.reddit.com/r/adventofcode/comments/kcb3bb/2020_day_13_part_2_can_anyone_tell_my_why_this/
#
# * Find a match for the first two. All subsequent matches will be a multiple
# of the LCM.
# * Iterating the LCM, find the third match. Re-calculate the LCM for all three
# * Continue.
#
# This solution assumes the inputs will be prime, which they are, so the
# LCM is simply the product.
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

my $input_file = $ARGV[0] || 'input13.txt';
my $input = Path::Tiny::path( $input_file )->slurp_utf8( { chomp => 1 } );
chomp $input;

sub bus_score {
  my ($timestamp, %buses) = @_;

  my $wait = $timestamp;
  my $bus = 0;
  for my $b (values %buses) {
    my $next = $b - ($timestamp % $b);
    if ($next < $wait) {
      $wait = $next;
      $bus = $b;
     }
   }

  return $bus * $wait;
 }

sub align {
  my ($timestamp, $lcm, $bus, $val) = @_;

  while (($timestamp + $val) % $bus != 0) {
    $timestamp += $lcm;
   }

  return( $timestamp, $lcm * $bus );
 }

sub timestamp {
  my (%buses) = @_;

  my $timestamp = 0;
  my $lcm = 1;
  for my $time (sort { $a <=> $b } keys %buses) {
    if ($timestamp == 0) {
      $timestamp = $buses{ $time } + $time;
      $lcm = $buses{ $time };
      next;
     }

    ($timestamp, $lcm) = align( $timestamp, $lcm, $buses{ $time }, $time );
   }

  return $timestamp;
 }

my $timestamp = $input =~ s/^(\d+)\n// && $1;

my %buses;
my $count = -1;
for my $bus (split( /,/, $input )) {
  $count++;
  next if ($bus eq 'x');
  $buses{ $count } = $bus;
 };

print "The score of the next bus is ", bus_score( $timestamp, %buses ), "\n";


print "The timestamp winner is ", timestamp( %buses ), "\n";
exit;
