package shared;
use Data::Dumper;
use Dancer ':syntax';
use File::Find::Wanted;


my $share_basedir = setting('share_basedir');

post '/shared' => sub {
    my $user = session('logged_in_user');
    my $sharedir = 'pub/'."$user";
    my $req = request->params();
    debug "REQUEST\n";
    debug Dumper($req) ;
    template 'shared' => {
        files => list_dirs($user),
        sharedir => $sharedir,
    };

};
 
get '/shared' => sub {
    my $user = session('logged_in_user');
    my $sharedir = 'pub/'."$user";
    my $req = request->params();
    debug "REQUEST\n";
    debug Dumper($req) if $req;
    template 'shared' => {
        files => list_dirs($user),
        sharedir => $sharedir,
    };
};

get qr{/shared/([\d\w]+$)} => sub {
    my $user = session('logged_in_user');
    my ($var) = splat;
    debug "VAR = $var\n";
    my $path = 'public'.'/'."$share_basedir".'/'."$user".'/'."$var";
    my $sharedir = '/pub/'."$user";
    debug "PATH = $path\n";
    if ( ! -d $path ) {
        template 'shared' => {
            msg => "no such share\n",
        };
    } 
    else {
        template 'share_x' => {
            files => list_dirs2($path),
            dir => $var,
            sharedir => $sharedir,
        };
    }

};


sub list_files {
    my ($user) = @_;
    my $path = 'public/pub'.'/'."$user";
    my @files=find_wanted( sub { -f && /.*/ }, $path);
    debug "Files = @files\n";
}

sub list_dirs2 {
    my ($path) = @_;
    opendir (my $dh, $path) or die "Can\'t open dir $path, $!\n";
        my @files= grep { !/^(\.)+$/ }  readdir( $dh );
    debug "FILES = @files\n";
    close $dh;
    return \@files if @files;
}

sub list_dirs {
    my ($user) = @_;
    my $flist;
    my $basedir = 'public/pub';
    my $path = "$basedir".'/'."$user";
    opendir (my $dh, $path) or die "Can\'t open dir $path, $!\n";
    my @shares = grep { !/^(\.)+$/ }  readdir( $dh );
    debug "shares = @shares\n";
    close $dh;
    foreach my $share (@shares) {
        opendir (my $dh,"$path".'/'."$share") or die "Can\'t open dir $path, $!\n";
        my @files = grep { !/^(\.)+$/} readdir($dh);
        debug Dumper(@files);
        close $dh;
        $flist->{$share} = \@files;
    }
    debug Dumper($flist);
    return $flist;
}
