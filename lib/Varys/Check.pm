# $ curl -u yanick:hush localhost:3001/diskusage | perl -MJSON -MData::Printer -0 -nE'say p decode_json $_'
package Varys::Check;

use 5.10.0;

use strict;
use warnings;

use Method::Signatures;
use Data::Printer;
use DateTime::Functions;

use Moose;

use Moose::Util::TypeConstraints;

extends 'MooseX::App::Cmd::Command';
with 'DBIx::NoSQL::Store::Model::Role';

# tweaking to allow double-life as cli command
# and web action
has '+usage' => ( required => 0, isa => 'Any' );
has '+app' => ( required => 0, isa => 'Any' );

has '+store_key' => (
    default => method {
        return join ' : ', $self->check_name, $self->timestamp;
    },
);

has check_name => (
    traits => [ 'Varys::Trait::Input' ],
    is => 'ro',
    isa => 'Str',
    default => method { ref $self },
);

has timestamp => (
    traits => [ 'Varys::Trait::Input', 'StoreIndex' ],
    is => 'ro',
    isa => 'Str',
    default => sub { now()->iso8601; },
);

has run_test => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
);

has test_result => (
    is => 'rw',
    lazy => 1,
    default => method {
        return unless $self->run_test;
        return $self->test;
    },
);


subtype 'AutoArray' => as 'ArrayRef[Str]';

coerce 'AutoArray' => from 'Str' => via { [ $_ ] };

# TODO add test/info branches
method execute(@args) {
    say p $self->info;
}

method info {
    my %data;

    # indexes are first class citizens
    for( grep { $_->does( 'DBIx::NoSQL::Store::Model::Role::StoreIndex' ) }
              $self->meta->get_all_attributes ) {
        my $m = $_->name;
        $data{$m} = $self->$m;
    }

    # split the rest between info and input
    for my $type ( qw/ Input Info / ) {
        $data{lc($type)} = { 
          map   { my $m = $_->name; $m => $self->$m }
          grep  { $_->does( "Varys::Trait::$type" ) } 
                $self->meta->get_all_attributes 
        };
    }

    # and the results, if any
    $data{test_result} = $self->test_result;

    return \%data;
}

# TO_JSON is for Dancer, 
# pack for DBIx::NoSQL::Store
*TO_JSON = *pack = *info;


package Varys::Trait::Input;

use Moose::Role;

Moose::Util::meta_attribute_alias('Input');


package Varys::Trait::Info;

use Moose::Role;

Moose::Util::meta_attribute_alias('Info');


1;
