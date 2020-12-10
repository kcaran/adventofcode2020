#!/usr/bin/env perl
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Code;

  sub weakness {
    my ($self, $num) = @_;
    for (my $i = 0; $i < @{ $self->{ code } } - 1; $i++) {
      my $sum = $self->{ code }[$i];
      my (@points) = ($self->{ code }[$i]);
      while ($sum < $num) {
        my $next_val = $self->{ code }[$i + @points];
        $sum += $next_val;
        push @points, $next_val;
       }
      if ($sum == $num) {
        @points = sort { $a <=> $b } @points;
        return $points[0] + $points[ @points - 1 ];
       }
     }
    return 0;
   }

  sub test {
    my ($self, $num) = @_;
    my $start = $self->{ start };
    my @test = sort { $a <=> $b } @{ $self->{ code } }[ $start .. $start + $self->{ size } - 1 ];
    for (my $i = 0; $i < @test - 1; $i++) {
      for (my $j = 0; $j < @test; $j++) {
        my $sum = $test[$i] + $test[$j];
        last if ($sum > $num);
        if ($sum == $num) {
          $self->{ start }++;
          push @{ $self->{ code } }, $num;
          return 0;
         }
       }
     }
    return $num;
   }

  sub new {
    my ($class, @input) = @_;
    my $self = {
      code => [ @input ],
      start => 0,
      size => scalar( @input ),
    };
    
    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input09.txt';
my $preamble = $ARGV[1] || 25;

my @input = Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } );
my $code = Code->new( @input[ 0 .. $preamble - 1 ] );

my $num = 0;
do {
  $num = $code->test( $input[$preamble++] );
} while ($num == 0);

print "The first illegal value is $num\n";

print "The weakness for the encryption is ", $code->weakness( $num ), "\n";

exit;
