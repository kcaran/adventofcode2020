#!/usr/bin/env perl
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Tickets;

  sub departure {
    my ($self) = @_;
    my $score = 1;
    for my $i (0 .. @{ $self->{ code } } - 1) {
      my $code = $self->{ code }[$i];
      die "We found more than one code at $i" if (@{ $code } != 1);
      $score *= $self->{ yours }[$i] if ($code->[0] =~ /departure/);
     }

    return $score;
   }

  sub errors {
    my ($self, $ticket) = @_;

    my $score = 0;
    for my $n (split( ',', $ticket )) {
      $score += $n unless ($self->{ rules }[$n]);
     }

    return $score;
   }

  sub yours {
    my ($self, $input) = @_;

    my ($yours) = ($input =~ /your ticket:\n(.*?)\n/msg);

    $self->{ yours } = [ split( ',', $yours ) ];
    $self->scan( $yours );

    return $self;
   }

  sub nearby {
    my ($self, $input) = @_;

    my ($nearby) = ($input =~ /nearby tickets:\n(.*)$/msg);
    for my $ticket (split( '\n', $nearby )) {
      my $error = $self->errors( $ticket );
      if ($error) {
        $self->{ score } += $error;
       }
      else {
        push @{ $self->{ nearby } }, $ticket;
        $self->scan( $ticket );
       }
     }

    return $self;
   }

  sub single {
    my ($self, $count, $rule) = @_;

    $self->{ field }{ $rule } = $count;
    for my $i (0 .. @{ $self->{ code } } - 1) {
      next if ($i == $count);
      $self->{ code }[$i] = [ grep { $_ ne $rule } @{ $self->{ code }[$i] } ];
      if (@{ $self->{ code }[$i] } == 1) {
        my $rule = $self->{ code }[$i][0];
        $self->single( $i, $rule ) if (!$self->{ field }{ $rule });
       }
     }

    return $self;
   }

  sub scan {
    my ($self, $ticket) = @_;

    my $count = 0;
    for my $n (split( ',', $ticket )) {
      my @rules = @{ $self->{ rules }[$n] };
      if ($self->{ code }[$count]) {
        my @new = ();
        for my $r (@rules) {
          push @new, $r if (grep { $_ eq $r && (!$self->{ field }{ $r } || $self->{ field }{ $r } == $count) } @{ $self->{ code }[$count] });
         }
        @rules = @new;
       }

      $self->{ code }[$count] = [ @rules ];
      if (@rules == 1 && !$self->{ field }{ $rules[0] }) {
        $self->single( $count, $rules[0] );
       }
      $count++;
     }
    return $self;
   }

  sub rules {
    my ($self, $input) = @_;

    while ($input =~ /^(.*?):\s+(\d+)\-(\d+) or (\d+)\-(\d+)$/msg) {
      my ($type, $min1, $max1, $min2, $max2) = ($1, $2, $3, $4, $5);
      for my $i ($min1 .. $max1) {
        push @{ $self->{ rules }[$i] }, $type;
       }
      for my $i ($min2 .. $max2) {
        push @{ $self->{ rules }[$i] }, $type;
       }
     }

    return $self;
   }

  sub new {
    my ($class, $input_file) = @_;
    my $input = Path::Tiny::path( $input_file )->slurp_utf8( { chomp => 1 } );
    my $self = {
      nearby => [],
      rules => [],
      field => {},
      code => [],
      score => 0,
    };
    bless $self, $class;

    $self->rules( $input );
    $self->nearby( $input );
    $self->yours( $input );

    return $self;
   }
}

my $input_file = $ARGV[0] || 'input16.txt';
my $tickets = Tickets->new( $input_file );

print "The error scanning rate is ", $tickets->{ score }, "\n";

print "The departure score is ", $tickets->departure(), "\n";


exit;
