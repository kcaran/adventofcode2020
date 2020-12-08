#!/usr/bin/env perl
#
use strict;
use warnings;
use utf8;

use Storable 'dclone';
use Path::Tiny;

{ package Assembler;

  my $inst = {
     'acc' => sub {
       my ($self, $value) = @_;
       $self->{ accumulator } += $value;
       $self->{ line }++;
       return $self;
       },
     'jmp' => sub {
       my ($self, $value) = @_;
       $self->{ line } += $value;
       return $self;
       },
     'nop' => sub {
       my ($self, $value) = @_;
       $self->{ line }++;
       return $self;
       },
	};

  sub next {
    my ($self) = @_;
    my ($code, $value) = split( /\s+/, $self->{ code }[ $self->{ line } ] );
    die "Illegal instruction $self->{ code }[ $self->{ line } ] at line $self->{ line }" unless ($inst->{ $code });
    &{ $inst->{ $code } }( $self, $value );
    return; 
   }

  sub run {
    my ($self) = @_;
    while ($self->{ line } < @{ $self->{ code } } && !$self->{ visited }{ $self->{ line } }) {
      $self->{ visited }{ $self->{ line } } = 1;
      $self->next();
     }
    return ($self->{ line } < @{ $self->{ code } });
   }

  sub switch {
    my ($self, $line) = @_;

    while ($line < @{ $self->{ code }}) {
      if ($self->{ code }[$line] =~ s/nop/jmp/) {
        return $line + 1;
       }
      if ($self->{ code }[$line] =~ s/jmp/nop/) {
        return $line + 1;
       }
      $line++;
     }

    return $line;
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
      accumulator => 0,
      line => 0,
      visited => {},
    };
    $self->{ code } = [ Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } ) ];
    
    bless $self, $class;
    return $self;
   }
}

my $input_file = $ARGV[0] || 'input08.txt';
my $ass = Assembler->new( $input_file );
my $try = dclone( $ass );
my $value = $try->run();
print "The value of the accumulator is $try->{ accumulator }\n";

my $line = 7;
do {
  $try = dclone( $ass );
  $line = $try->switch( $line );
  $value = $try->run();
} until ($value == 0);

print "The value of the accumulator in the working program is $try->{ accumulator }\n";
