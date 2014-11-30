package frontpage;
use Dancer ':syntax';
use Data::Dumper;
use Dancer::Plugin::Auth::Extensible;

get '/' => sub {
    template 'front.tt';
};


get qr{/login} => sub {
    status 401;
    my $return_url = params->{return_url} || "/www";
    template 'front.tt', {
        'return_url' =>  $return_url,
    };
};

post qr{/login} => sub {

my ($success, $realm) = authenticate_user(
        params->{username}, params->{password}
    );
    if ($success) {
        session logged_in_user => params->{username};
        session logged_in_user_realm => $realm;
        my $user = session('logged_in_user');
        debug "USER = $user\n";
        subs::createuser($user);
        redirect params->{return_url} || "/upload";
    }
    else {  
        return redirect "/";
    }
};


#get qr{/share} => sub {
#    gt
