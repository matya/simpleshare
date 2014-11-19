#!/usr/bin/env perl
use Dancer;
use frontpage;
use upload;
use shared;

#protect all routes by default
hook 'before' => sub {
        if  ( ! session('logged_in_user')) {
            # Pass the original path requested along to the handler:
            # var requested_path => request->path_info;
            request->path_info('/login');
        }
};

hook before_template => sub {
    my $tokens = shift;
    $tokens->{'login_url'}  = uri_for('/login');
    $tokens->{'logout_url'} = uri_for('/logout');
    $tokens->{'action_url'} = uri_for('/upload');
};

any '/logout' => sub {
    session 'logged_in' => 0;
    session -> destroy;
    return redirect '/login';
};

dance;
