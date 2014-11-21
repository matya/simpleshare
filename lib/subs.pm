package subs;
use Dancer ':syntax';
use String::Random;

our $upload_dir = setting('upload_basedir');
our $share_dir= setting('share_basedir');

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
        my $sharepath = "$share_dir".'/'."$user";
        mkdir $path if  ! -d $path ;
        mkdir $sharepath if ! -d $sharepath;
    }
    else {
        debug "user contains wrong characters\n";
        return false;
    }
}

sub share {
    my ($fileref) = @_;
    my $rval;
    my $rndstring = String::Random->new;
    my $rstr = $rndstring->randpattern("CCccccn");
    my $user = session('logged_in_user');
    my $url = 'pub'.'/'."$user".'/'."$rstr";

    if ( ref $fileref eq 'ARRAY' ) {
        foreach my $fkey (keys (@$fileref)) {
            next if $fkey =~ /\.\./g;
            debug "fkey = $fkey\n";
            my $rval = mklink("@$fileref[$fkey]","$rstr");
        }
        if ($rval) {
            return  $url;
        }
        else {
            return false;
        }
    }
    else {
        return if $fileref =~ /\.\./g;
        mklink("$fileref","$rstr");
    }

}

sub mklink {
    my ($file,$rnd) = @_;
    my $user = session('logged_in_user');
#    my $path = 'public/'."$url";
    my $path = $share_dir.'/'."$user".'/'."$rnd";
    mkdir $path || debug "err $!\n";
    debug "PATH = $path\n";
    my $link = "$path".'/'."$file";
    my $dest = '../../../../upload'.'/'."$user".'/'."$file";
    debug "dest = $dest\n";
    my $returnvalue =  symlink ("$dest","$link") || return false;
    debug "symlink ret val = $returnvalue\n";
    return true;
}

sub findshared {
    return;
}
