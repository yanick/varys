# $ curl -u yanick:hush localhost:3001/diskusage | perl -MJSON -MData::Printer -0 -nE'say p decode_json $_'
package Dumuzi::Check;

use 5.10.0;

use strict;
use warnings;

use Method::Signatures;
use Data::Printer;

use Moose;

use Moose::Util::TypeConstraints;

extends 'MooseX::App::Cmd::Command';

# tweaking to allow double-life as cli command
# and web action
has '+usage' => ( required => 0, isa => 'Any' );
has '+app' => ( required => 0, isa => 'Any' );

has run_test => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
);


subtype 'AutoArray' => as 'ArrayRef[Str]';

coerce 'AutoArray' => from 'Str' => via { [ $_ ] };

# TODO add test/info branches
method execute {
    my $info = $self->test ? $self->test_info : $self->info;

    say p $info;
}

method info {
    my %data;

    for my $type ( qw/ Input Info / ) {
        $data{$type} = { 
          map   { my $m = $_->name; $m => $self->$m }
          grep  { $_->does( "Dumuzi::Trait::$type" ) } 
                $self->meta->get_all_attributes 
        };
    }

    return \%data;
}

method test_info {
    my $info = $self->info;
    $info->{test} = $self->test;
    return $info;
}


package Dumuzi::Trait::Input;

use Moose::Role;

package Dumuzi::Trait::Info;

use Moose::Role;


1;
