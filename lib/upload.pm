package upload;
use Dancer ':syntax';
use Data::Dumper;
use Sort::Naturally;


our $VERSION = '0.1';

post '/upload' => sub {
    my $user = session('logged_in_user');
    my $req = request->params();
    if ( (defined $req->{'submit'}) && ($req->{'submit'} eq 'upload')) {
        my $file = request->upload('file');                        
        if ($file) {
            if ( ref $file eq 'ARRAY' ) {
                foreach my $fkey (keys (@$file)) {
                    my $filename = process_request(@$file[$fkey]);
                }
            }
            else {
                my $filename = process_request($file);
            }
            template 'upload' => {
                msg => 'Doone',
                files => subs::listfiles($user),
            };
        } 
        else {
            template 'upload' => {
                msg => 'please select a file',
                files => subs::listfiles($user),
            };
        }
    }
    elsif ( $req->{'action'} ) {
        if ($req->{'action'} eq 'share') {
            if ($req->{'filelist'} ) {
                my $file = $req->{'filelist'};
                # don't use \" for $file, or 
                subs::share($file,$user);
                return redirect '/shared';
            }
            else {
                template 'upload' => {
                    msg => 'please select a file to share',
                    files => subs::listfiles($user),
                };
            }
        }
        elsif ($req->{'action'} eq 'delete') {
            if ($req->{'filelist'} ) {
                my $files = $req->{'filelist'};
                subs::delete($files,$user);
                return redirect '/upload';
            }
            else {
                template 'upload' => {
                    msg => 'please select a file to share',
                    files => subs::listfiles($user),
                };
            }
        }
    }
    
};

get '/upload' => sub {
    my $user = session('logged_in_user');
    template 'upload' => {
        files => subs::listfiles($user),
    };
};

get '/download/:file' => sub {
    my $file = params->{file};
    my $user = session('logged_in_user');
    my $upload_dir = $subs::upload_dir .'/'. $user;
    my $path = $upload_dir . '/' . $file;
    return send_file($path, system_path => 1 ) if -e $path;
    return redirect '/';
};

sub process_request {
    my ($ref) = @_;
    my $user = session('logged_in_user');
    my $fname = $ref->filename;
    my $tmpname = $ref->tempname;
    my $upload_dir = "$subs::upload_dir".'/'."$user";
    my $destination = $upload_dir .'/'. $fname;
    $ref->copy_to($destination);
    unlink $tmpname if -e $tmpname;
    return $fname;
}


true;
