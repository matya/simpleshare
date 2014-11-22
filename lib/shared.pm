package shared;
use Data::Dumper;
use Dancer ':syntax';
use File::Find::Wanted;


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


sub list_files {
    my ($user) = @_;
    my $path = 'public/pub'.'/'."$user";
    my @files=find_wanted( sub { -f && /.*/ }, $path);
    debug "Files = @files\n";
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
