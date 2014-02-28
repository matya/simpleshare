package multifileupload;
use Dancer ':syntax';
use Data::Dumper;

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
    debug "FILE:";
    debug Dumper($file);
    if ($file) {
        if ( ref $file eq 'ARRAY' ) {
            foreach my $fkey (keys (@$file)) {
                my $fname = @$file[$fkey]->filename;
                my $tmpname = @$file[$fkey]->tempname;
                my $destination = $upload_dir .'/'. $fname;
                @$file[$fkey]->copy_to($destination);
                unlink $tmpname if -e $tmpname;
            }
        }
        else {
            my $fname = $file->filename;
            my $tmpname = $file->tempname;
            my $destination = $upload_dir . '/' . $fname;
            $file->copy_to($destination);
            unlink $tmpname if -e $tmpname;
        }
        template 'upload' => {
            msg => 'Done',
        };
    } 
    else {
        template 'upload' => {
            msg => 'please select a file',
        };
    }
};

true;
