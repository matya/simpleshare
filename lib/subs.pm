package subs;
use Dancer ':syntax';
use String::Random;
use Data::Dumper;
use Sort::Naturally;

our $upload_dir = setting('upload_basedir');
our $share_dir= setting('share_basedir');
our $public = 'public/';


sub listfiles {
    my ($user)  = @_;
    my @nofile = '../upload';
    my $path = $upload_dir.'/'.$user;
    exit if ($user =~ m/\.\./);
    return ls($path);
}

sub ls {
    my ($path) = @_;
    opendir(my $u_fd,$path) or die "can\'t open $path, $!\n";
    my @list_of_files = grep { !/^\./ } readdir( $u_fd );
    close $u_fd;
    if (@list_of_files) {
        @list_of_files = nsort(@list_of_files);
        return \@list_of_files;
    }
    else {
        return undef;
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
    clean_links($user);
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
    return ls($path);
}

sub list_shares {
    my ($user) = @_;
    my $path = $public.'/'.$share_dir;
    my @empty;
    my @usershares;
    opendir ( my $dh,$path) or die "shared::list_shares can\'t open dir $path, $!\n";
    my @shares  = grep { !/^(\.)+$/ } readdir ( $dh );
    close $dh;
    foreach my $share (@shares) {
        my $share_path = $path.'/'.$share;
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
            my $file_path = $share_path.'/'.$content[0];
            # link = '../../../upload/test/Doom2.wad'
            my $link =  readlink($file_path);
            # we need the dir name before the file
            my $linktouser = (File::Spec->splitdir( $link))[-2];
            push @usershares,$share  if ($linktouser eq $user);
            
       }
    }
         
    foreach my $share (@empty) {
        my $full_path=$path.'/'.$share;
        rmdir $full_path;
    }
    return \@usershares;

}

#unlink dangling links
sub clean_links {
    my ($user) = @_;
    my $shareref = list_shares($user);
    foreach my $share (@$shareref) {
        my $path = $public.'/'.$share_dir.'/'.$share;
        my $files = ls($path);
            foreach my $file (@$files) {
                my $link = $path.'/'.$file;
                my $linkdest = readlink($link);
                debug "subs::clean_shares::deadlink $link\n" if (! -e $linkdest);
                unlink $link if (! -e $linkdest);
            }
    }
}
                
    
