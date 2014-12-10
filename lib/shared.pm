package shared;
use Data::Dumper;
use Dancer ':syntax';


our $share_basedir = setting('share_basedir');

post '/shared' => sub {
    my $user = session('logged_in_user');
    my $sharedir = $share_basedir.'/'.$user;
    my $req = request->params();
    template 'shared' => {
        shares => subs::list_shares($user),
        sharedir => $sharedir,
    };

};
 
get '/shared' => sub {
    my $user = session('logged_in_user');
    # pub/$user
    my $sharedir = $share_basedir.'/'.$user;
    my $req = request->params();
    # do not cache the result
    header('Cache-Control' =>  'no-store, no-cache, must-revalidate');
    template 'shared' => {
        shares => subs::list_shares($user),
        sharedir => $sharedir,
    };
};

any qr{/shared/([\d\w]+$)} => sub {
    my $user = session('logged_in_user');
    my ($var) = splat;
    my $req = request->params();
    my $sharedir = $share_basedir;
    my $path = $subs::share_dir.'/'.$var;
    if ( (defined $req->{'action'}) && ($req->{'action'} eq 'unshare')) {
        if ($req->{'filelist'} ) {
            my $links = $req->{'filelist'};
            my $left = subs::unshare($links,$var);
            
            if ( ref $left eq 'ARRAY' ) {
                return redirect "/shared/$var";
            } 
            # redirect to /shared if no files
            else {
                return redirect '/shared';
            }
        }
    else {
           template 'share_x' => {
               dir => $var,
               files => subs::ls($path),
               sharedir => $sharedir,
           };
       }
    }

    if ( ! -d $path ) {
        template 'shared' => {
            msg => "no such share\n",
        };
    } 
    else {
        template 'share_x' => {
            files => subs::ls($path),
            dir => $var,
            sharedir => $sharedir,
        };
    }

};

get qr{/getfile/([\d\w]+$)} => sub {
    my ($share) = splat;
    my $path = $subs::share_dir.'/'.$share;
    if ( -d $path ) {
        my $files = subs::ls($path);
            template 'index' => {
                files => $files,
                share => $share,
            },
            { layout => 0 };
    }

};


