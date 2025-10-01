use v6.d;

use JSON::Fast;
use Data::TypeSystem;

class Data::Translators::HTML {
    has $!table-init-markup;
    has Str $.table-attributes = 'border="1"';
    has $.align = Whatever;
    has Bool $.clubbing = True;
    has Bool $.escape is rw = True;
    has Bool $.encode is rw = False;
    has $.field-names = Whatever;

    submethod TWEAK {
        $!table-init-markup = "<table $!table-attributes>";
        if $!field-names ~~ Str:D {
            $!field-names = [$!field-names,];
        }
        if $!field-names ~~ (Array:D | List:D | Seq:D) && !$!field-names {
            $!field-names = Whatever
        }
    }

    method convert($json = "") {

        return Empty unless $json;

        my $json-input;
        if $json ~~ Str:D {
            try {
                $json-input = from-json($json);
                CATCH {
                    when X::AdHoc {
                        if .message.contains("Expecting property name") {
                            die $_;
                        }
                        $json-input = $json;
                    }
                }
            }
        } else {
            $json-input = $json;
        }

        my $converted = self.convert-json-node($json-input);

        if self.align ~~ Str:D {
            $converted .= subst('<td>', "<td align={self.align}>", :g);
        }

        return $!encode ?? $converted.encode('ascii').trans(['<', '>', '&', '\'', '"'] => ['&lt;', '&gt;', '&amp;', '&#39;', '&quot;']) !! $converted;
    }

    method column-headers-from-list-of-maps($json-input) {
        if is-reshapable($json-input, iterable-type => Positional, record-type => Map) {
            my @column-headers = $json-input[0].keys;
            if $!field-names ~~ (Array:D | List:D | Seq:D) && $!field-names.all ~~ (Str:D | Numeric:D) {
                @column-headers = $!field-names.grep({ $_ ∈ @column-headers }).Array;
                if !@column-headers {
                    note "An empty set of field names is obtained after filtering.";
                }
            }
            return @column-headers;
        } else {
            return [];
        }
    }

    method convert-json-node($json-input) {
        return do given $json-input {
            when $_.isa(Whatever) {
                '(Whatever)'
            }
            when $_.isa(WhateverCode) {
                '(WhateverCode)'
            }
            when ! $_.defined {
                '(Any)'
            }
            when $_ ~~ Str:D {
                $!escape ?? $json-input.trans(['<', '>', '&', '\'', '"'] => ['&lt;', '&gt;', '&amp;', '&#39;', '&quot;']) !! $json-input;
            }
            when $_ ~~ Associative:D {
                self.convert-object($json-input);
            }
            when $_ ~~ Iterable:D {
                self.convert-list($json-input);
            }
            default {
                $_.Str;
            }
        }
    }

    method convert-list(@list-input) {
        return '' unless @list-input;
        my $converted-output = '';
        my @column-headers = Empty;
        @column-headers = self.column-headers-from-list-of-maps(@list-input) if $!clubbing;
        if @column-headers {
            $converted-output ~= $!table-init-markup;
            $converted-output ~= '<thead>';
            $converted-output ~= '<tr><th>' ~ @column-headers.join('</th><th>') ~ '</th></tr>';
            $converted-output ~= '</thead>';
            $converted-output ~= '<tbody>';

            for @list-input -> %entry {
                $converted-output ~= "<tr><td>{ @column-headers.map({ self.convert-json-node(%entry{$_}) }).join('</td><td>') }</td></tr>";
            }
            $converted-output ~= '</tbody></table>';
            return $converted-output;
        }

        $converted-output = "<ul><li>{ @list-input.map({ self.convert-json-node($_) }).join('</li><li>') }</li></ul>";
        return $converted-output;
    }

    method convert-object(%json-input) {
        return '' unless %json-input;
        my $converted-output = $!table-init-markup ~ '<tr>';
        my @res;
        my @pairs =
                do if $!field-names ~~ Positional {
                    $!field-names.map({ %json-input{$_}:exists ?? ($_ => %json-input{$_}) !! Empty })
                } else {
                    %json-input.pairs
                };

        for @pairs -> $p {
            @res.push("<th>{ self.convert-json-node($p.key) }</th><td>{ self.convert-json-node($p.value) }</td>");
        }
        $converted-output ~= @res.join('</tr><tr>') ~ '</tr></table>';
        return $converted-output;
    }

    method is-html-table($input) {
        return False unless $input ~~ Str:D;
        # Check for <table> tag and at least one <tr> with <td> or <th>
        return $input ~~ /:i
        '<table' \s* '>'
        .*?
        # No need for elaborated check.
        # '<tr' \s* '>' .*? ( '<td' \s* '>' | '<th' \s* '>' ) .*? '</tr>'
        # .*?
        '</table>'
        /;
    }

    method table-data-extraction(Str:D $html, Str:D :icp(:$index-column-prefix) = '') is export {
        # Initialize result array
        my @result;

        # Extract headers (from <th> tags)
        my @headers;
        if $html.match( /:i '<th>' $<header>=(.*?) '</th>' /):g {
            @headers = $/>>.<header>.map(*.Str);

            # Clean headers by removing extra whitespace
            @headers = @headers.map(*.trim);
        }

        # If no headers found, use column indexes (Column1, Column2, etc.)
        unless @headers {
            # Find the first row to determine the number of columns
            if $html.match(/:i '<tr>' $<cont>=(.*?) '</tr>' /) {
                my $first-row = $/<cont>.Str;
                my @cells = $first-row.match(/:i '<td>' $<cont>=(.*?) '</td>' /):g
                        ?? $/.map(*.Str).map(*.trim).list
                        !! [];
                @headers = (1..@cells.elems).map($index-column-prefix ~ *).list;
            }
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

        return @result;
    }
}
