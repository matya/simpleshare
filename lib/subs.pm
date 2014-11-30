package subs;
use Dancer ':syntax';
use String::Random;
use Data::Dumper;

our $upload_dir = setting('upload_basedir');
our $share_dir= setting('share_basedir');
our $public = 'public/';


sub listfiles {
    my ($user)  = @_;
    my @nofile = '../upload';
    my $path = $upload_dir.'/'.$user;
    exit if ($user =~ m/\.\./);
    opendir(my $u_fd,$path) or die "can\'t open $path, $!\n";
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
        my $share_dir = $public.$share_dir;
        debug "susb::createuser::SHAREDIR = $share_dir\n";
        my $path = $upload_dir.'/'.$user;
        my $sharepath = $share_dir.'/'.$user;
        mkdir $path if  ! -d $path ;
    }
    else {
        debug "user contains wrong characters\n";
        return false;
    }
}

sub share {
    my ($fileref,$user) = @_;
    my $rndstring = String::Random->new;
    my $rstr = $rndstring->randpattern("CCccccn");
    my $url = 'pub'.'/'."$rstr";
    if ( ref $fileref eq 'ARRAY' ) {
        debug "subs::share ARRAY!!!\n";
        foreach my $fkey (keys (@$fileref)) {
            my $file = @$fileref[$fkey];
            next if $file =~ /\.\./g;
            debug "subs::share fkey = $fkey\n";
            mklink($file,$rstr,$user);
        }
    }
    else {
        return if $fileref =~ /\.\./g;
        mklink($fileref,$rstr,$user);
    }
}

sub mklink {
    my ($file,$rnd,$user) = @_;
#    my $path = 'public/'."$url";
    my $path = $public . $share_dir . '/' . $rnd;
    mkdir $path || debug "err $!\n";
    my $link = $path.'/'.$file;
    debug "subs::mklink::link = $link\n";
    my $dest = '../../../upload'.'/'.$user.'/'.$file;
    debug "subs:;mklink::dest = $dest\n";
    my $returnvalue =  symlink ($dest,$link) || return false;
    debug "subs::mklink::symlink ret val = $returnvalue\n";
    return true;
}

sub delete {
    my ($fileref,$user) = @_;
    my $path = $upload_dir.'/'.$user;
    debug "subs::delete::path $path\n";
    if ( ref $fileref eq 'ARRAY' ) {
        foreach my $fkey (keys (@$fileref)) {
            my $file = @$fileref[$fkey];
            next if $file =~ /\.\./g;
            my $fullpath = $path.'/'.$file;
            debug "subs::delete fullpath = $fullpath\n";
            unlink $fullpath or warn "Could not unlink $fullpath: $!";
        }
    }
    else {
        return if $fileref =~ /\.\./g;
        my $fullpath = $path.'/'.$fileref;
        unlink $fullpath or warn "Could not unlink $fullpath: $!";
    }
}

# delete and unshare subs look almost identical ...
sub unshare {
    my ($linkref,$share) = @_;
    my $path = $public.'/'.$share_dir.'/'.$share;
    if ( ref $linkref eq 'ARRAY' ) {
        foreach my $lkey (keys (@$linkref)) {
            my $link = @$linkref[$lkey];
            next if $link =~ /\.\./g;
            my $fullpath = $path.'/'.$link;
            debug "subs::unshare fullpath = $fullpath\n";
            unlink $fullpath or warn "Could not unlink $fullpath: $!";
        }
    }
    else {
        return if $linkref =~ /\.\./g;
        my $fullpath = $path.'/'.$linkref;
        unlink $fullpath or warn "Could not unlink $fullpath: $!";
    }
}

