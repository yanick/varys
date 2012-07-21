package Dumuzi::CLI;

use strict;
use warnings;

use Moose;

extends 'MooseX::App::Cmd';

sub plugin_search_path { 'Dumuzi::Check' }


1;




