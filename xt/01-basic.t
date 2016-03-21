use v6;
use Test;
use HTTP::Client::Async;

plan 3;

my $client = HTTP::Client::Async.new;

my $p = $client.head("http://www.cpan.org/").then(-> $v {
    my $res = $v.result;
    is $res<status>, 200;
    is $res<reason>, "OK";
    is $res<headers><Content-Type>, "text/html";
});

await $p;
