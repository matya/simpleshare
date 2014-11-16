package shared;
use Dancer ':syntax';

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
