package shared;
use Dancer ':syntax';
use String::Random;

our $upload_dir = setting('upload_basedir');

sub listfiles {
    my ($user)  = @_;
    my @nofile = '../upload';
    my $path = "$upload_dir".'/'."$user";
    exit if ($user =~ m/\.\./);
    opendir(my $u_fd,$path) or die "can't open $path, $!\n";
    my @list_of_files = grep { !/^\./ } readdir( $u_fd );
    close $u_fd;
    if (@list_of_files) {
        return \@list_of_files;
    }
    else {
        return \@nofile;
    }
}

sub createuser {
    my ($user) = @_;
    if  ($user =~ /[\w\d]*/) {
        my $path = "$upload_dir".'/'."$user";
        if ( ! -d $path ) {
            mkdir $path;
        }
    }
    else {
        debug "user contains wrong characters\n";
        return false;
    }
}

sub share {
    my ($fileref) = @_;
    my $rndstring = String::Random->new;
    my $rstr = $rndstring->randpattern("CCccccn");

    if ( ref $fileref eq 'ARRAY' ) {
        foreach my $fkey (keys (@$fileref)) {
            mklink("@$fileref[$fkey]","$rstr");
        }
    }
    else {
        mklink("$fileref","$rstr");
    }

}

sub mklink {
    my ($file,$rnd) = @_;
    my $user = session('logged_in_user');
    my $path = 'public/pub'.'/'."$user".'/'."$rnd";
    mkdir $path || debug "err $!\n";
    debug "PATH = $path\n";
    my $link = "$path".'/'."$file";
    my $dest = '../../../../upload'.'/'."$user".'/'."$file";
    debug "dest = $dest\n";
    my $returnvalue =  symlink ("$dest","$link");
    debug "symlink ret val = $returnvalue\n";
}
