package frontpage;
use Dancer ':syntax';
use Data::Dumper;
#use Dancer::Session::Cookie;
use Dancer::Plugin::Auth::Extensible;

get '/' => sub {
    template 'front.tt';
};


get qr{/login} => sub {
    debug "getlogin\n";
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
    my $user = params->{username};
#    debug "USER = $user";
#    debug "successs=$success\n";
#    debug "Realm = $realm";
    if ($success) {
        session logged_in_user => params->{username};
        session logged_in_user_realm => $realm;
#        debug "REALM\n";
#        debug "REALM = $realm\n";
        my $users= session('logged_in_user');
        debug "$users\n";
#        my $redir = params->{return_url};
#        warning ($redir);
#        redirect params->{return_url} || "";
#        redirect params->{return_url} || "/upload";
        template 'upload.tt', {
            files => shared::listfiles("$user"),
        }
    }
    else {  
        return redirect "/";
    }
};


