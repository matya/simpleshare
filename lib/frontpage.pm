package frontpage;
use Dancer ':syntax';
use Data::Dumper;
use Dancer::Plugin::Auth::Extensible;

get '/' => sub {
    return redirect '/upload' if session('logged_in_user');
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
        #implement a check and print a message if failed
        my $result = subs::createuser($user);
        return redirect '/logout' if ! $result;
        redirect params->{return_url} || '/upload'; 
    }
    else {  
        return redirect "/";
    }
};
