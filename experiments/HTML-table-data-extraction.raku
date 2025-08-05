#!/usr/bin/env raku
use v6.d;

use Data::Reshapers;

sub html-table-data-extraction(Str:D $html) {
    # Initialize result array
    my @result;

    # Extract headers (from <th> tags)
    my @headers;
    if $html.match( /:i '<th>' $<header>=(.*?) '</th>' /):g {
        @headers = $/>>.<header>.map(*.Str);

        # Clean headers by removing extra whitespace
        @headers = @headers.map(*.trim);
    }

    return [] unless @headers; # Return empty array if no headers found

    # Extract rows (from <tr> within <tbody> or standalone)
    my @rows;
    if $html.match(/:i '<tr>' $<cont>=(.*?) '</tr>' /):g {
        @rows = $/>>.<cont>.map(*.Str);
    }

    # Process each row
    for @rows -> $row {
        # Extract cells (from <td> tags)
        my @cells = $row.match(/:i '<td>' $<cont>=(.*?) '</td>' /):g
                ?? $/>>.<cont>.map(*.Str)
                !! next;

        # Skip empty rows
        next unless @cells;

        # Create hash for row
        my %row-data;
        for @headers.kv -> $i, $header {
            %row-data{$header} = @cells[$i] // '';
        }
        @result.push(%row-data);
    }

    @result
}

my $html = q:to/TBLEND/;
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Country Popularity</title>
</head>
<body>
    <table border="1">
        <thead>
            <tr>
                <th>Country</th>
                <th>Popularity</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Cuba</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Bahamas</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Jamaica</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Haiti</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Dominican Republic</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Puerto Rico</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Trinidad and Tobago</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Barbados</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Saint Lucia</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Saint Vincent and the Grenadines</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Grenada</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Saint Kitts and Nevis</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Antigua and Barbuda</td>
                <td>100</td>
            </tr>
            <tr>
                <td>Dominica</td>
                <td>100</td>
            </tr>
        </tbody>
    </table>
</body>
</html>
```
TBLEND

my @res = html-table-data-extraction($html);

say to-pretty-table(@res);
