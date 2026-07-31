#!/usr/bin/env perl
# Rewrite Chapter @sec-foo and bullet `+ @sec-foo:` patterns in preface and
# chapter 11 to use the explicit "Chapter N (Title)" hyperlink format.
use strict;
use warnings;

my %map = (
    'getting-started'           => ['01-getting-started.html',           '1',  'Getting Started with Data in R'],
    'viz'                       => ['02-visualization.html',             '2',  'Data Visualization'],
    'wrangling'                 => ['03-wrangling.html',                 '3',  'Data Wrangling'],
    'tidy'                      => ['04-tidy.html',                      '4',  'Data Importing and Tidy Data'],
    'regression'                => ['05-regression.html',                '5',  'Simple Linear Regression'],
    'multiple-regression'       => ['06-multiple-regression.html',       '6',  'Multiple Regression'],
    'sampling'                  => ['07-sampling.html',                  '7',  'Sampling'],
    'confidence-intervals'      => ['08-confidence-intervals.html',      '8',  'Estimation, Confidence Intervals, and Bootstrapping'],
    'hypothesis-testing'        => ['09-hypothesis-testing.html',        '9',  'Hypothesis Testing'],
    'inference-for-regression'  => ['10-inference-for-regression.html', '10',  'Inference for Regression'],
    'thinking-with-data'        => ['11-tell-your-story-with-data.html','11',  'Tell Your Story with Data'],
);

for my $file (@ARGV) {
    open(my $fh, '<', $file) or die "open $file: $!";
    local $/;
    my $text = <$fh>;
    close $fh;

    for my $key (keys %map) {
        my ($f, $num, $title) = @{$map{$key}};
        my $link = "[Chapter $num ($title)]($f#sec-$key)";

        # `Chapter @sec-foo` -> manual link
        $text =~ s/\bChapter\s+\@sec-\Q$key\E\b/$link/g;

        # bullet line `+ @sec-foo:` -> manual link (preserve trailing colon)
        $text =~ s/^(\s*\+\s*)\@sec-\Q$key\E(?=:)/$1$link/gm;

        # inline `in @sec-foo` (and `and @sec-foo`) -> manual link
        $text =~ s/\b(in|and)\s+\@sec-\Q$key\E\b/$1 $link/g;
    }

    open($fh, '>', $file) or die "write $file: $!";
    print $fh $text;
    close $fh;
    print STDERR "rewrote: $file\n";
}
