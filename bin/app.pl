#!/usr/bin/env perl
use Dancer;
use frontpage;
use upload;
use shared;
use subs;

#protect all routes by default but ^/getfile
hook 'before' => sub {
        if  ( ! session('logged_in_user') && ( request->path_info !~ m{^/getfile})) {
            # Pass the original path requested along to the handler:
            # var requested_path => request->path_info;
            request->path_info('/login');
        }
};

hook before_template => sub {
    my $tokens = shift;
    $tokens->{'login_url'}  = uri_for('/login');
    $tokens->{'logout_url'} = uri_for('/logout');
    $tokens->{'upload_url'} = uri_for('/upload');
    $tokens->{'shared_url'} = uri_for('/shared');
    $tokens->{'public_url'} = uri_for('/pub');
    $tokens->{'getfile'} = uri_for('/getfile');
};

any '/logout' => sub {
    session 'logged_in' => 0;
    session -> destroy;
    return redirect '/';
};

dance;
