#!/usr/bin/env perl
#
# $Id: $
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

my $subject = 7;
my $log_subject = log( $subject );

sub calc_loop {
  my ($key1, $key2) = @_;
  my $value = 1;
  my $loop = 0;

  while (1) {
    $loop++;
    $value = ($value * 7) % 20201227;
    return ($loop, -1) if ($key1 == $value);
    return (-1, $loop) if ($key2 == $value);
   }

  return;
 }

sub calc_value {
  my ($subject, $loop) = @_;
  my $value = $subject % 20201227;

  $loop--;
  while ($loop) {
    $loop--;
    $value = ($value * $subject) % 20201227;
   }

  return $value;
 }

my $input_file = $ARGV[0] || 'input25.txt';

my ($card, $door) = path( $input_file )->lines_utf8( { chomp => 1 } );

my ($card_loop, $door_loop) = calc_loop( $card, $door );

my $key;
$key = calc_value($card, $door_loop) if ($door_loop > 0);
$key = calc_value($door, $card_loop) if ($card_loop > 0);

print "The encryption key is $key\n";
exit;
