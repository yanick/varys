package Varys;
use Dancer ':syntax';

use Dancer::Plugin::Auth::Basic;

use 5.12.0;

our $VERSION = '0.1';

use Module::Pluggable
    search_path => [ 'Varys::Check' ],
    require => 1;

use Varys::Store;

my $store = Varys::Store->connect( 'checks.sqlite' );
$store->register;

for my $check ( __PACKAGE__->plugins ) {
    ( my $name = $check ) =~ s/.*:://;

    get "/$name" => sub {
        return $store->new_model_object( $name,
            params
        );
    };

    post "/$name" => sub {
        my $o = $store->new_model_object( $name,
            params,
            run_test => 1,
        );

        Dancer::SharedData->response->status(500) unless $o->test_result->{success};

        return $o;
    };
}

hook 'before_serializer' => sub {
    $_[0]->content->store;
};

1;
