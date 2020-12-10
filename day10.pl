#!/usr/bin/env perl
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

my $input_file = $ARGV[0] || 'input10.txt';

my @adapters = sort { $a <=> $b } path( $input_file )->lines_utf8( { chomp => 1 } );

sub num_paths {
  my ($idx, @adapters) = @_;

  return 1 if ($idx >= @adapters);

  # At the start, include an extra count
  my $count = $idx == 0 ? 2 : 1;
  while ($idx < @adapters - 1 && $adapters[$idx+1] - $adapters[$idx] == 1) {
    $count++;
    $idx++;
   }
  my $paths = 1;
  $paths = 2 if ($count == 3);
  $paths = 4 if ($count == 4);
  $paths = 7 if ($count == 5);
print "Found $paths at $idx $adapters[$idx]\n";
  die "Found too many contiguous at $idx" if ($count > 5);

  return $paths * num_paths( $idx + 1, @adapters );
 }

my %diffs;

my $joltage = 0;
for my $a (@adapters) {
  my $diff = $a - $joltage;
  die "Can't use this adapter $a at joltage $joltage" if ($diff > 3);
  $diffs{ $diff }++;
  $joltage = $a;
 }

# The final adapter
$diffs{ 3 }++;
$joltage += 3;

print "The adapter score is $diffs{ 1 } * $diffs{ 3 } = ", $diffs{ 1 } * $diffs{ 3 }, "\n";

my $paths = num_paths( 0, @adapters );
print "The number of paths is $paths\n";

exit;
