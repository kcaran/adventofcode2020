#!/usr/bin/env perl
#
use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Program;

 my $default_mask = '111111111111111111111111111111111111';

 sub calc {
   my ($self) = @_;

   my $sum = 0;
   for my $reg (keys %{ $self->{ register } }) {
     $sum += $self->{ register }{ $reg };
    }

   return $sum;
  }

 sub store {
   my ($self, $mask_0, $mask_1, $reg, $val) = @_;

   $reg = $reg & $mask_0 | $mask_1;
   $self->{ register }{ $reg } = $val;
  }

 sub run {
   my ($self) = @_;

   my @masks;
   for my $cmd (@{ $self->{ program } }) {
     if ($cmd =~ /^mask\s+=\s+(.*?)$/) {
       my $input_m = $1;
       @masks = ( ['', ''] );
       for my $i (0 .. length( $input_m ) - 1) {
         my $bit = substr( $input_m, $i, 1 );
         my @new_masks = ();
         for my $m (@masks) {
           push @new_masks, [ $m->[0] . '1', $m->[1] . '0' ] if ($bit eq '0');
           push @new_masks, [ $m->[0] . '0', $m->[1] . '0' ] if ($bit eq 'X');
           push @new_masks, [ $m->[0] . '1', $m->[1] . '1' ] if ($bit eq '1' || $bit eq 'X');
          }
         @masks = @new_masks;
        }
      }
     elsif ($cmd =~ /^mem\[(\d+)\]\s+=\s+(\d+)$/) {
       my $reg = $1;
       my $val = $2;
       for my $m (@masks) {
         $self->store( oct( "0b$m->[0]" ), oct( "0b$m->[1]" ), $reg, $val );
        }
      }
     else {
       die "Illegal command $cmd\n";
      }
    }
   return $self;
  }

 sub new {
    my ($class, $input_file) = @_;
    my $self = {
     program => [ Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } ) ],
     register => {},
    };

    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input14.txt';

my $program = Program->new( $input_file );

$program->run();

print "The sum is ", $program->calc(), "\n";

exit;
