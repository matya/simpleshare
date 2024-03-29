package frontpage;
use Dancer ':syntax';
use Data::Dumper;
use Dancer::Plugin::Auth::Extensible;

get '/' => sub {
    return redirect '/upload' if session('logged_in_user');
    template 'front.tt';
};

get qr{/login} => sub {
    template 'front.tt', {
    };
};

post qr{/login} => sub {
    if (authenticate_user( params->{username}, params->{password} )) {
        session logged_in_user => params->{username};
        my $user = session('logged_in_user');
        my $inituser= subs::createuser($user);
        redirect params->{return_url} || "/upload";
        #return redirect '/logout' if ! $inituser;
        redirect '/upload';
    }
    else {  
        return redirect "/logout";
    }
};
