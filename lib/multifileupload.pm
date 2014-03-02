package multifileupload;
use Dancer ':syntax';
#use Data::Dumper;

our $VERSION = '0.1';

my $upload_route = '/upload';
my $upload_dir = '/tmp';


hook before_template=> sub {
    my $tokens = shift;
    $tokens->{'upload_route'} = uri_for('/upload');
};

get '/' => sub {
    template 'upload';
};

post '/upload' => sub {
    my $file = request->upload('file');
    if ($file) {
    my @files;
        if ( ref $file eq 'ARRAY' ) {
            foreach my $fkey (keys (@$file)) {
                my $filename = process_request(@$file[$fkey]);
                push (@files,$filename);
            }
        }
        else {
            my $filename = process_request($file);
            push (@files,$filename);
        }
        template 'upload' => {
            msg => 'Doone',
            files => \@files,
        };
    } 
    else {
        template 'upload' => {
            msg => 'please select a file',
        };
    }
};

get '/download/:file' => sub {
    my $file = params->{file};
    debug "FILE = $file\n";
    my $path = $upload_dir . '/' . $file;
    return send_file($path, system_path => 1 ) if -e $path;
    return redirect '/';
};

sub process_request {
    my ($ref) = @_;
    my $fname = $ref->filename;
    my $tmpname = $ref->tempname;
    my $destination = $upload_dir .'/'. $fname;
    $ref->copy_to($destination);
    unlink $tmpname if -e $tmpname;
    return $fname;
}

true;
