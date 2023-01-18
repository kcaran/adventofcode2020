#!/usr/bin/env perl
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Floor;

  my %moves = (
	'e' => [ 0, 2 ],
	'w' => [ 0, -2 ],
	'ne' => [ 1, 1 ],
	'se' => [ -1, 1 ],
	'nw' => [ 1, -1 ],
	'sw' => [ -1, -1 ],
	);

  sub black {
    my ($self, $row, $col) = @_;

    return $self->{ map }{ "$row,$col" } ? 1 : 0;
   }

  sub neighbors {
    my ($self, $tile) = @_;

    my @pos = split( ',', $tile );
    my $blacks = 0;

    for my $off (values %moves) {
      $blacks += 1 if ($self->black( $pos[0] + $off->[0], $pos[1] + $off->[1] ));
     }

    return $blacks;
   }

  sub day {
    my ($self) = @_;

    my %flips;
    for my $tile (keys %{ $self->{ map } }) {
      my $blacks = $self->neighbors( $tile );
      $flips{ $tile } = 1 if ($blacks == 0 || $blacks > 2);

      my @pos = split( ',', $tile );
      for my $off (values %moves) {
        my $n = ($pos[0] + $off->[0]) . "," . ($pos[1] + $off->[1]);
        next if $self->{ map }{ $n };
        $flips{ $n } = 1 if ($self->neighbors( $n ) == 2);
       }
     }

    for my $f (keys %flips) {
      $self->flip( $f );
     }

    return;
   }

  sub flip {
    my ($self, $tile) = @_;

    if ($self->{ map }{ $tile }) {
      delete $self->{ map }{ $tile };
     }
    else {
      $self->{ map }{ $tile } = 1;
     }

    return;
   }

  sub move {
    my ($self, $inst) = @_;

    my $pos = [0, 0];
    for my $dir (@{ $inst }) {
      my $off = $moves{ $dir };
      $pos->[0] += $off->[0];
      $pos->[1] += $off->[1];
     }

    $self->flip( "$pos->[0],$pos->[1]" );

    return;
   }

  sub instructions {
   my ($self, $line) = @_;

   my @inst;
   while ($line) {
     $line =~ s/^(e|w|ne|nw|se|sw)//;
     push @inst, $1;
    }

   return @inst;
  }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
      map => {},
      inst => [],
    };
    bless $self, $class;

    for my $line ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
      push @{ $self->{ inst } }, [ $self->instructions( $line ) ];
     }

    return $self;
   }
}

my $input_file = $ARGV[0] || 'input24.txt';

my $floor = Floor->new( $input_file );
for my $inst (@{ $floor->{ inst } }) {
  $floor->move( $inst );
 }

my $black = %{ $floor->{ map } };
print "There are $black black tiles\n";

for my $i (1 .. 100) {
  $floor->day();
 }

$black = %{ $floor->{ map } };
print "After 100 days, there are $black black tiles\n";

exit;
