#!/usr/bin/env perl6
use v6;
use lib "lib";
use HTTP::Client::Async;

my $client = HTTP::Client::Async.new;

my $p = $client.head("http://www.cpan.org/").then(-> $v {
    my $res = $v.result;
    say $res<status>;
    say $res<reason>;
    say $res<headers>;
});

await $p;
