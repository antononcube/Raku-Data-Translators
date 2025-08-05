#!/usr/bin/env raku
use v6.d;

use Data::Reshapers;
use Data::Translators;

my $html-with-headers = q:to/END/;
<table>
    <tr>
        <th>Name</th>
        <th>Age</th>
        <th>City</th>
    </tr>
    <tr>
        <td>John</td>
        <td>25</td>
        <td>New York</td>
    </tr>
    <tr>
        <td>Alice</td>
        <td>30</td>
        <td>London</td>
    </tr>
</table>
END

my $html-no-headers = q:to/END/;
<table>
    <tr>
        <td>John</td>
        <td>25</td>
        <td>New York</td>
    </tr>
    <tr>
        <td>Alice</td>
        <td>30</td>
        <td>London</td>
    </tr>
</table>
END

my @res = html-table-data-extraction($html-with-headers);

say to-pretty-table(@res);

say '=' x 100;

my @res2 = html-table-data-extraction($html-no-headers);

say to-pretty-table(@res2);
