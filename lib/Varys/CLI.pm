package Varys::CLI;

use strict;
use warnings;

use Moose;

extends 'MooseX::App::Cmd';

sub plugin_search_path { 'Varys::Check' }


1;




