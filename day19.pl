#!/usr/bin/env perl
#
# $Id: $
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

my $rules = {};
my $part_b;

sub decode_rule {
  my ($key) = @_;

  while ($rules->{ $key } =~ s/(\d+)/decode_rule($1)/eg) {
#   print "$key: $rules->{ $key }\n";
   }

  return $rules->{ $key };
 }

sub parse_rules {

  for my $k (keys %{ $rules }) {
    $rules->{ $k } = decode_rule( $k );
   }

  if ($part_b) {
    $rules->{ 0 } = "($rules->{ 42 })+ ($rules->{ 31 })+";
   }

  return;
 }

my @rules = ();
my @data = ();
my $input_file = $ARGV[0] || 'input19.txt';
$part_b = $ARGV[1];
for my $line (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
  next unless $line;
  if (my ($key, $rule) = ($line =~ /^(\d+): (.*)$/)) {
    $rule =~ s/"//g;
    $rule = "(?:$rule)" if ($rule =~ tr/|//);
    $rules->{ $key } = $rule;
   }
  else {
    push @data, $line;
   }
 }

parse_rules();

my $count = 0;
my $rule = $rules->{ 0 };
my $i = 0;
for my $d (@data) {
  if ($d =~ /^$rule$/x) {
    if ($part_b) {
      # For part b: 42+ 42 (42{n} 31{n}) 31 n = 0..?
      my ($num_42, $num_31) = (0, 0);
      while ($d =~ s/^($rules->{ 42 })//xg) { $num_42++; };
      while ($d =~ s/($rules->{ 31 })$//xg) { $num_31++; };
      $count++ if ($num_42 > $num_31);
     }
    else {
      $count++;
     }
   }
  $i++;
 }
print "The number of matches for rule 0 is $count\n";

exit;

