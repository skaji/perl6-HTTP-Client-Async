use v6;
unit class HTTP::Client::Async;
use URI;

my class HTTP::Request {
    has $.method;
    has $.host;
    has $.path;
    my $CRLF = Buf.new(13, 10).decode;
    method finalize() {
          "$.method $.path HTTP/1.1$CRLF"
        ~ "Host: $.host$CRLF"
        ~ "UserAgent: perl6$CRLF"
        ~ "$CRLF"
    }
}

method head($url) {
    self.request("HEAD", $url);
}

method request(Str $method, $url is copy) {
    $url = URI.new($url) if $url !~~ URI;
    my $host = $url.host;
    my $port = $url.port;
    my $path = $url.path_query;
    $path = "/" if $path eq "";

    # based on stomp by jnthn
    # https://github.com/jnthn/p6-stomp
    start {
        my $conn = await IO::Socket::Async.connect($host, $port);
        my $responsed = self.process-response($conn.Supply).share;
        my $req = HTTP::Request.new(:$method, :$host, :$path);
        await $conn.print($req.finalize);
        await $responsed;
    };
}

# based on p6-WebSocket by tokuhirom
# https://github.com/tokuhirom/p6-WebSocket
my grammar HTTPResponseGrammar {
    token TOP { ^
        'HTTP/1.1 ' <status> ' ' <reason> <.crlf>
        [ <header> <.crlf> ]*
        <.crlf>
    }

    token header {
        <feild> ':' ' '* <value>
    }
    token crlf { \x0d \x0a }
    token feild { <-[ \r \n \: ]>+ }
    token value { <-[ \r \n ]>+ }
    token status { \d+ }
    token reason { \N+ }
}
my class HTTPResponseActions {
    method TOP($/) {
        $/.make: {
            status  => $<status>.made,
            reason  => $<reason>.made,
            headers => %($<header>>>.made),
        };
    }
    method header($/) { $/.make: $<feild>.made => $<value>.made }
    method feild($/)  { $/.make: ~$/ }
    method value($/)  { $/.make: ~$/ }
    method status($/) { $/.make: +$/ }
    method reason($/) { $/.make: ~$/ }
}

method process-response($incomming) {
    supply {
        my $buf = '';
        whenever $incomming -> $data {
            $buf ~= $data;
            while HTTPResponseGrammar.subparse($buf, :actions(HTTPResponseActions)) -> $/ {
                emit $/.made;
                done;
            }
        };
    };
}

=begin pod

=head1 NAME

HTTP::Client::Async - learning perl6 asynchronous programming

=head1 SYNOPSIS

  my $client = HTTP::Client::Async.new;

  my $promise = $client.head("http://www.cpan.org/").then(-> $p {
    my $res = $p.result;
    say $res<status>;
    say $res<reason>;
    say $res<headers>;
  });
  await $promise;


=head1 DESCRIPTION

Let's learn perl6 asynchronous programming.

=head1 AUTHOR

Shoichi Kaji <skaji@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
