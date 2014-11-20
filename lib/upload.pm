package upload;
use Dancer ':syntax';
use Data::Dumper;
use Sort::Naturally;


our $VERSION = '0.1';

post '/upload' => sub {
    my $user = session('logged_in_user');
    my $req = request->params();
    debug "REQUEST\n";
    debug Dumper($req) ;
    if ( (defined $req->{'submit'}) && ($req->{'submit'} eq 'upload')) {
        my $file = request->upload('file');                        
        my $user = session('logged_in_user');
        if ($file) {
        my @files;
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
                files => shared::listfiles("$user"),
            };
        } 
        else {
            template 'upload' => {
                msg => 'please select a file',
                files => shared::listfiles("$user"),
            };
        }
    }
    elsif ( $req->{'action'} ) {
        if ($req->{'action'} eq 'share') {
            if ($ req->{'filelist'} ) {
                my $file = $req->{'filelist'};
                debug "Share file = $file\n"; 
                print "file has to be linked\n";
                debug Dumper($file);
                shared::share("$file");
            }
            else {
                template 'upload' => {
                    msg => 'please select a file to share',
                    files => shared::listfiles("$user"),
                };
            }
        }
    }
    
};

get '/upload' => sub {
    my $user = session('logged_in_user');
    template 'upload' => {
        files => shared::listfiles("$user"),
    };
};

get '/download/:file' => sub {
    my $file = params->{file};
    my $user = session('logged_in_user');
    my $upload_dir = $shared::upload_dir .'/'. $user;
    my $path = $upload_dir . '/' . $file;
    return send_file($path, system_path => 1 ) if -e $path;
    return redirect '/';
};

sub process_request {
    my ($ref) = @_;
    my $user = session('logged_in_user');
    my $fname = $ref->filename;
    my $tmpname = $ref->tempname;
    my $upload_dir = "$shared::upload_dir".'/'."$user";
    my $destination = $upload_dir .'/'. $fname;
    $ref->copy_to($destination);
    unlink $tmpname if -e $tmpname;
    return $fname;
}


true;
