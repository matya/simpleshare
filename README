NAME 
    simpleshare - simple application for data sharing

DESCRIPTION
    Upload and share files via randomly generated url.

    Some modules used in the code:
    - Dancer::Plugin::Auth::Extensible - Authentication backends
    - Dancer::Session::Cookie - Encrypted cookie-based session backend for Dancer
    - Sort::Naturally  - sort lexically, but sort numeral parts numerically
    - Encode  - handle UTF8 files
    - String::Random - generate random url
    - Template::Toolkit - Template Processing System

INSTALL
    on a Debian Jessie:
    apt-get install  libdancer-plugin-auth-extensible-perl libdancer-session-cookie-perl libsort-naturally-perl libstring-random-perl libtemplate-perl

    on other systems: install perl modules mentioned above with all dependencies

CONFIGURATION
    Create directories: upload and public/pub -  mkdir {upload,public/pub}
    Set the proper basedir path in config.yaml
    The default should work if the application is launched from the root directory

USAGE 
    cd to the root of application and start it ./bin/app.pl, open browser and open $servername:3000
    install Plack:
        apt-get install libplack-perl
    and run it using plackup:
        plackup bin/app.pl

LICENSE
    public/css/style.css:
    Copyright (c) 2012-2014 Thibaut Courouble

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    the rest: 
    Copyright: 2014 Alex Mestiashvili
    
    
    This program is free software; you can redistribute it and/or modify it
    under the terms of either: the GNU General Public License as published
    by the Free Software Foundation; or the Artistic License.

    See http://dev.perl.org/licenses/ for more information.
