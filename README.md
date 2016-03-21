[![Build Status](https://travis-ci.org/skaji/perl6-HTTP-Client-Async.svg?branch=master)](https://travis-ci.org/skaji/perl6-HTTP-Client-Async)

NAME
====

HTTP::Client::Async - learning perl6 asynchronous programming

SYNOPSIS
========

    my $client = HTTP::Client::Async.new;

    my $promise = $client.head("http://www.cpan.org/").then(-> $p {
      my $res = $p.result;
      say $res<status>;
      say $res<reason>;
      say $res<headers>;
    });
    await $promise;

DESCRIPTION
===========

Let's learn perl6 asynchronous programming.

AUTHOR
======

Shoichi Kaji <skaji@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
