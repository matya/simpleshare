package upload;
use Dancer ':syntax';
use Data::Dumper;
use Sort::Naturally;
use Encode qw(decode encode);

post '/upload' => sub {
    my $user = session('logged_in_user');
    my $req = request->params();
    if ( (defined $req->{'submit'}) && ($req->{'submit'} eq 'upload')) {
        my $file = request->upload('file');                        
        if ($file) {
            if ( ref $file eq 'ARRAY' ) {
                foreach my $fkey (keys (@$file)) {
                    my $filename = subs::process_request(@$file[$fkey],$user);
                }
            }
            else {
                my $filename = subs::process_request($file,$user);
            }
            template 'upload' => {
                msg => 'Done',
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


true;
