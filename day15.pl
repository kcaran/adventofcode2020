#!/usr/bin/env perl
#
# $Id: $
#
use strict;
use warnings;
use utf8;

my $total = $ARGV[0] || 2020;
my $input = $ARGV[1] || '8,11,0,19,1,2';

my @start = split( ',', $input );
my %nums;

my $count = 1;
for my $s (@start) {
print "$s $count\n";
  $nums{ $s } = $count++;
 }

my $next_num = 0;
while ($count < $total) {
  if ($nums{ $next_num }) {
    my $diff = $count - $nums{ $next_num };
    $nums{ $next_num } = $count;
    $next_num = $diff;
   }
  else {
    $nums{ $next_num } = $count;
    $next_num = 0;
   }
  $count++;
 }

print "The next number spoken is $next_num\n";

exit;
