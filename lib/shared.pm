package shared;
use Dancer ':syntax';

our $upload_dir = setting('upload_basedir');

sub listfiles {
    my ($user)  = @_;
    my @nofile = 'empty';
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
    my $path = "$upload_dir".'/'."$user";
    if ( ($user =~ /[\w\d]*/) && ( ! -d $path ) ) {
        mkdir $path;
    }
    else {
        debug "user contains wrong characters\n";
        exit;
    }
}
