package shared;
use Data::Dumper;
use Dancer ':syntax';
use File::Find::Wanted;
use Cwd qw(abs_path realpath);
use File::Spec qw(splitdir);


our $share_basedir = setting('share_basedir');

post '/shared' => sub {
    my $user = session('logged_in_user');
    my $sharedir = $share_basedir.'/'.$user;
    my $req = request->params();
    debug "shared::/shared REQUEST\n";
    debug Dumper($req) ;
    template 'shared' => {
        shares => list_shares($user),
        sharedir => $sharedir,
    };

};
 
get '/shared' => sub {
    my $user = session('logged_in_user');
    my $sharedir = $share_basedir.'/'.$user;
    my $req = request->params();
    template 'shared' => {
        shares => list_shares($user),
        sharedir => $sharedir,
    };
};

any qr{/shared/([\d\w]+$)} => sub {
    my $user = session('logged_in_user');
    my ($var) = splat;
    my $req = request->params();
    debug "VAR = $var\n";
    my $sharedir = $share_basedir;
    my $path = 'public/'.$sharedir.'/'.$var;
    debug "shared:get_shared::PATH = $path\n";
    debug "shared::REQUEST\n";
    debug Dumper($req) ;
    if ( (defined $req->{'action'}) && ($req->{'action'} eq 'unshare')) {
       if ($req->{'filelist'} ) {
           my $links = $req->{'filelist'};
           subs::unshare($links,$var);
           return redirect "/shared/$var";
       }
       else {
           template 'share_x' => {
               dir => $var,
               files => list_files($path),
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
            files => list_files($path),
            dir => $var,
            sharedir => $sharedir,
        };
    }

};

sub list_files {
    my ($path) = @_;
    debug "shared:list_dirs2::path = $path\n";
    opendir (my $dh, $path) or die "Can\'t open dir $path, $!\n";
        my @files= grep { !/^(\.)+$/ }  readdir( $dh );
    close $dh;
    return \@files if @files;
}


sub list_shares {
    my ($user) = @_;
    my $path = 'public/'.$share_basedir;
    my @empty;
    my @usershares;
    opendir ( my $dh,$path) or die "shared::list_shares can\'t open dir $path, $!\n";
    my @shares  = grep { !/^(\.)+$/ } readdir ( $dh );
    close $dh;
    foreach my $share (@shares) {
        my $share_path = $path.'/'.$share;
        debug ("shared::list_shares::share_path $share_path\n");
        opendir (my $dh,$share_path) or die "shared::list_shares2 can\'t open die $share_path, $!\n";
        my @content = grep { !/^(\.)+$/ } readdir ( $dh );
        close $dh;
        if (! $content[0] ) {
            push @empty,$share;
            next;
        }
        else {
            # the path to the first file, we need it to findout the username
            # from the symlink destination
            my $file_path = "$share_path".'/'."$content[0]";
            # link = '../../../upload/test/Doom2.wad'
            my $link =  readlink($file_path);
            # we need the dir name before the file
            my $linktouser = (File::Spec->splitdir( $link))[-2];
            push @usershares,$share  if ($linktouser eq $user);
            
       }
    }
         
    foreach my $share (@empty) {
        my $full_path=$path.'/'.$share;
        debug ("shared::list_shares::delete $full_path\n");
        rmdir $full_path;
    }
    debug ("shared::list_shares::usershares @usershares\n");
    return \@usershares;
}

#return hash with all data
#not used for now
#sub list_dirs {
#    my ($user) = @_;
#    my $flist;
#    my $basedir = 'public/pub';
#    my $path = "$basedir".'/'."$user";
#    opendir (my $dh, $path) or die "Can\'t open dir $path, $!\n";
#    my @shares = grep { !/^(\.)+$/ }  readdir( $dh );
#    debug "shares = @shares\n";
#    close $dh;
#    foreach my $share (@shares) {
#        opendir (my $dh,"$path".'/'."$share") or die "Can\'t open dir $path, $!\n";
#        my @files = grep { !/^(\.)+$/} readdir($dh);
#        debug Dumper(@files);
#        close $dh;
#        $flist->{$share} = \@files;
#    }
#    debug Dumper($flist);
#    return $flist;
#}


