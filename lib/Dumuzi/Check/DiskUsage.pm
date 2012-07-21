package Dumuzi::Check::DiskUsage;

use 5.10.0;

use strict;
use warnings;

use Sys::Statistics::Linux::DiskUsage;
use Method::Signatures;

use Moose;

extends 'Dumuzi::Check';

has skip => (
    traits  => [ 'Dumuzi::Trait::Input', 'Array' ],
    is      => 'ro',
    isa     => 'AutoArray',
    coerce  => 1,
    lazy    => 1,
    default => sub { [] },
    handles => {
        'skip_all' => 'elements',
    },
);

has test_percent => (
    traits  => [ 'Dumuzi::Trait::Input' ],
    is      => 'ro',
    isa     => 'Int',
    default => 60,
);

has partitions => (
    traits  => [ 'Dumuzi::Trait::Info', 'Hash' ],
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        # TODO S::S::L::DU clobbers all 'none' together
        my $p = Sys::Statistics::Linux::DiskUsage->new->get;
        delete $p->{$_} for $_[0]->skip_all;
        return $p;
    },
    handles => {
        partitions_kv => 'kv',
    },
);


method test {
    my @full = map  { $_->[0] } 
               grep { $_->[1]{usageper} > $self->test_percent }
                    $self->partitions_kv;

    return { 
        success => @full ? 0 : 1,
        ( filled_partitions => \@full ) x !!@full
    };
}

1;
