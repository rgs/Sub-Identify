#!perl -T

use Test::More;
BEGIN {
    unless ($ENV{RELEASE_TESTING}) {
        plan(skip_all => 'these tests are for release candidate testing');
    }
}
use Test::Pod 1.14;
all_pod_files_ok();
