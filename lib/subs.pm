package subs;
use Dancer ':syntax';
use String::Random;
use Data::Dumper;
use Sort::Naturally;
use File::Spec;
use POSIX 'strftime';
use Encode qw(decode encode);
use utf8;

my  $VERSION  = '1.40'; 

our $upload_dir = setting('basedir') .'/'.setting('upload_basedir');
our $share_dir = setting('basedir') .'/public/'.setting('share_basedir');

sub listfiles {
    my ($user)  = @_;
    my $path = $upload_dir.'/'.$user;
    exit if ($user =~ m/\.\./);
    return ls($path);
}

sub ls {
    my ($path) = @_;
    #my @utf8files;
    my %filehash;
    opendir(my $u_fd,$path) or die "can\'t open $path, $!\n";
    my @list_of_files = grep { !/^\./ } readdir( $u_fd );
    close $u_fd;
    if (scalar (@list_of_files)) {
        foreach my $file (@list_of_files) {
            my $modtime_f = (stat("${path}/${file}"))[9] if $file;
            my $utf8file = Encode::decode('UTF-8',$file);
            #push @utf8files,$utf8file;
            $filehash{"${modtime_f}_${utf8file}"} = $utf8file;
        }
        #@utf8files = nsort(@utf8files);
        #return \@utf8files;
        return \%filehash;
    }
    else {
        return undef;
    }
}

sub createuser {
    my ($user) = @_;
    if  ($user =~ /[\w\d]*/) {
        my $path = $upload_dir.'/'.$user;
        my $sharepath = $share_dir.'/'.$user;
        mkdir $path if  ! -d $path ;
    }
    else {
        #this will actually never happen as we create users ourselves
        debug "user contains wrong characters\n";
        return false;
    }
    return true;
}

sub share {
    my ($fileref,$user) = @_;
    my $rndstring = String::Random->new;
    my $rstr = $rndstring->randpattern(setting('random_pattern'));
    if ( ref $fileref eq 'ARRAY' ) {
        foreach my $fkey (keys (@$fileref)) {
            my $file = @$fileref[$fkey];
            next if $file =~ /\.\./g;
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
    my $upload = setting('upload_basedir');
    my $path = $share_dir . '/' . $rnd;
    mkdir $path || debug "err $!\n";
    my $link = $path.'/'.$file;
    my $dest = '../../../'.$upload.'/'.$user.'/'.$file;
    my $returnvalue =  symlink ($dest,$link) || return false;
    return true;
}

sub delete {
    my ($fileref,$user) = @_;
    my $path = $upload_dir.'/'.$user;
    if ( ref $fileref eq 'ARRAY' ) {
        foreach my $fkey (keys (@$fileref)) {
            my $file = @$fileref[$fkey];
            next if $file =~ /\.\./g;
            my $fullpath = $path.'/'.$file;
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
    my $path = $share_dir.'/'.$share;
    if ( ref $linkref eq 'ARRAY' ) {
        foreach my $lkey (keys (@$linkref)) {
            my $link = @$linkref[$lkey];
            next if $link =~ /\.\./g;
            my $fullpath = $path.'/'.$link;
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
    my $path = $share_dir;
    my @empty;
    #my @usershares = ();
    my %sharehash;
    opendir ( my $dh,$path ) or die "shared::list_shares can\'t open dir $path, $!\n";
    my @shares  = grep { !/^(\.)+$/ } readdir ( $dh );
    close $dh;
    foreach my $share (@shares) {
        my $share_path = $path.'/'.$share;
        opendir (my $dh,$share_path) or die "shared::list_shares can\'t open die $share_path, $!\n";
        my @content = grep { !/^(\.)+$/ } readdir ( $dh );
        my $modtime_s = (stat($dh))[9];
        #my $modtime = strftime "%Y/%m/%d %H:%M:%S", localtime((stat($dh))[9]);
        #my $modtime = strftime "%Y/%m/%d %H:%M:%S", localtime($modtime_s);
        close $dh;
        if (! $content[0] ) {
            push @empty,$share;
            next;
        }
        else {
            # the path to the first file, we need it to findout the username
            # from the symlink destination
            my $first_file = Encode::decode('UTF-8',$content[0]);
            my $file_path = $share_path.'/'.$first_file;
            # link = '../../../upload/test/Doom2.wad'
            my $link =  readlink($file_path);
            # we need the dir name before the file
            my $linktouser = (File::Spec->splitdir($link))[-2];
#            $sharehash{$share} = "$modtime_s" if ( $linktouser eq $user );
            # a timestamp will be uniq for upload of multiple files, making the key uniq, which is crap
            $sharehash{"${modtime_s}_${share}"} = "$share" if ( $linktouser eq $user );
#            push @usershares,$share  if ($linktouser eq $user);

        }
    }

    foreach my $share (@empty) {
        my $full_path=$path.'/'.$share;
        rmdir $full_path;
    }
    return \%sharehash;
#    return \@usershares;

}

#unlink dangling links
sub clean_links {
    my ($user) = @_;
    my $shareref = list_shares($user);
    foreach my $share (values (%$shareref)) {
        my $path = $share_dir.'/'.$share;
        debug "CLEANING the LINK $path";
        my $files = ls($path);
        foreach my $file (values (%$files)) {
            my $link = $path.'/'.$file;
            my $linkdest = readlink($link);
#                debug "subs::clean_shares::deadlink $link\n" if (! -e $linkdest);
            unlink $link if (! -e $linkdest);
        }
    }
}


#upload files
sub process_request {
    my ($ref,$user) = @_;
    my $fname = $ref->filename;
    my $tmpname = $ref->tempname;
    my $upload_dir = $upload_dir.'/'.$user;
    my $destination = $upload_dir .'/'. $fname;
    $ref->copy_to($destination);
    unlink $tmpname if -e $tmpname;
    return $fname;
}
