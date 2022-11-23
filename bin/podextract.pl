#!/usr/bin/env perl

use strict;
use warnings;

use lib qw{lib};

use Pod::Extract;

__PACKAGE__->main();

sub main {
  exit Pod::Extract->main;
}

1;

__END__

# see podextract -h for help
