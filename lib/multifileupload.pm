package multifileupload;
use Dancer ':syntax';
our $VERSION = '0.1';

my $upload_route = '/upload';
my $upload_dir = '/tmp';

get '/' => sub {
    template 'upload' => {
        upload_file => $upload_route,
    };
};

post '/upload' => sub {
    my $file = request->upload('file');
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
    print "Done\n";
};

true;
