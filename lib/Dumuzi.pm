package Dumuzi;
use Dancer ':syntax';

use Dancer::Plugin::Auth::Basic;

use 5.12.0;

our $VERSION = '0.1';

use Module::Pluggable
    search_path => [ 'Dumuzi::Check' ],
    require => 1;

for my $check ( __PACKAGE__->plugins ) {
    ( my $name = $check ) =~ s/.*:://;
    $name = lc $name;

    get "/$name" => sub {
        return to_json $check->new( params )->info;
    };

    post "/$name" => sub {
        my $info = $check->new( params )->test_info;

        Dancer::SharedData->response->status(500) unless $info->{test}{success};

        return to_json $info;
    };
}

1;
