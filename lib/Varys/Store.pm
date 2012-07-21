package Varys::Store;
 
use Moose;
 
use Method::Signatures;
 
extends 'DBIx::NoSQL::Store::Manager';

has '+model_path' => (
    default => 'Varys::Check',
);
 
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
 
1;
