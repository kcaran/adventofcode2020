#!/usr/bin/env perl
#
# $Id: $
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package War;

  sub win {
    my ($self) = @_;

    return unless (@{ $self->{ p1 } } == 0 || @{ $self->{ p2 } } == 0);

    my $deck = @{ $self->{ p1 } } ? $self->{ p1 } : $self->{ p2 };
    my $score = 0;
    for my $i (1 .. @{ $deck }) {
      $score += $i * $deck->[ @{ $deck } - $i ];
     }

    return $score;
   }

  sub round {
    my ($self) = @_;

    my $p1 = shift @{ $self->{ p1 } };
    my $p2 = shift @{ $self->{ p2 } };
    if ($p1 > $p2) {
      push @{ $self->{ p1 } }, $p1, $p2;
     }
    else {
      push @{ $self->{ p2 } }, $p2, $p1;
     }
   }

  sub new {
    my ($class, $input) = @_;
    my $self = {
      p1 => [],
      p2 => [],
    };

    my ($p1) = ($input =~ /Player 1:\s+(.*?)\n\n/sm);
    my ($p2) = ($input =~ /Player 2:\s+(.*?)\Z/sm);
    $self->{ p1 } = [ split( /\s+/, $p1 ) ];
    $self->{ p2 } = [ split( /\s+/, $p2 ) ];
    bless $self, $class;

    return $self;
  }
};

my $input_file = $ARGV[0] || 'input22.txt';

my $input = path( $input_file )->slurp_utf8( { chomp => 1 } );

my $war = War->new( $input );
my $score;
while (!($score = $war->win())) {
   $war->round();
 }
print "The winning score is $score\n";

exit;
