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

  sub move {
    my ($self, $inst) = @_;

    my $pos = [0, 0];
    for my $dir (@{ $inst }) {
      my $off = $moves{ $dir };
      $pos->[0] += $off->[0];
      $pos->[1] += $off->[1];
     }

    my $tile = join( ',', @{ $pos } );
    if ($self->{ map }{ $tile }) {
      delete $self->{ map }{ $tile };
     }
    else {
      $self->{ map }{ $tile } = 1;
     }

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

exit;
