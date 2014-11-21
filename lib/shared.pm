package shared;
use Data::Dumper;
use Dancer ':syntax';


post '/shared' => sub {
    my $user = session('logged_in_user');
    my $req = request->params();
    debug "REQUEST\n";
    debug Dumper($req) ;
};
 
get '/shared' => sub {
    my $user = session('logged_in_user');
    my $req = request->params();
    debug "REQUEST\n";
    debug Dumper($req) if $req;
};
