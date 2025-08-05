use v6.d;

use Data::Translators::HTML;
use Data::Translators::R;
use Data::Translators::WL;
use Data::TypeSystem;
use Data::TypeSystem::Predicates;
use Hash::Merge;
use JSON::Fast;

unit module Data::Translators;

#===========================================================
# Data translation
#===========================================================

#| Translates data into different formats.
#| C<$data> -- Data to convert.
#| C<$target> -- Target to convert to, one of <HTML R>.
#| C<$field-names> -- Field names to use for Map objects.
#| C<$table-attributes> -- HTML table attributes to use.
#| C<$encode> -- Whether to encode or not.
#| C<$escape> -- Whether to escape or not.
proto sub data-translation($data, Str :$target = 'HTML', *%args) is export {*}

multi sub data-translation(Str $data where *.IO.f, Str :$target = 'HTML', *%args) {
    return data-translation(slurp($data), :$target, |%args);
}

multi sub data-translation(IO $data, Str :$target = 'HTML', *%args) {
    return data-translation(slurp($data), :$target, |%args);
}

multi sub data-translation($data, Str :$target = 'HTML', *%args) {

    my $trObj = do given $target {
        when $_.lc ∈ <html markdown> {
            Data::Translators::HTML.new(|%args);
        }

        when $_.lc ∈ <r rlang> {
            Data::Translators::R.new(|%args);
        }

        when $_.lc ∈ ['wl', 'wolfram language', 'mathematica'] {
            Data::Translators::WL.new(|%args);
        }

        when $_.lc eq 'json' {
            return to-json($data);
        }

        default {
            note "Do not know how to process the target argument: $_.";
            return Nil;
        }
    }

    return $trObj.convert($data);
}

#===========================================================
# JSON to HTML
#===========================================================
#| Convert JSON string or JSON-like structure into an HTML spec.
#| C<$data> -- Data to convert.
#| C<:$field-names> -- Field names to use for Map objects.
#| C<:$table-attributes> -- HTML table attributes to use.
#| C<:$encode> -- Whether to encode or not.
#| C<:$escape> -- Whether to escape or not.
#| C<:$columns> -- Number of columns for the C<:$multicolumn> adverb.
#| C<:$multicolumn> -- Should multi-column table be created or not?
proto sub to-html(|) is export {*}

multi sub to-html($data, *%args) {

    my $jtr = Data::Translators::HTML.new(|%args);

    return $jtr.convert($data);
}

#------------------------------------------------------------
sub transpose(@tbl) {
    my @tbl2;
    for ^@tbl.elems -> $i {
        for ^@tbl[0].elems -> $j {
            with @tbl[$i][$j] {
                @tbl2[$j][$i] = @tbl[$i][$j];
            } else {
                @tbl2[$j][$i] = Nil;
            }
        }
    }

    return @tbl2;
}

#------------------------------------------------------------
multi sub to-html(@data,
                  :multicolumn(:$multi-column)! is copy,
                  :cols(:ncol(:$columns)) is copy = Whatever,
                  *%args) {

    return to-html(@data, |%args) unless so $multi-column;

    if $multi-column.isa(Whatever) {$multi-column = True}
    if $columns.isa(Whatever) { $columns = 2 }

    my $ncol = $multi-column !~~ Bool:D && $multi-column ~~ Int:D ?? $multi-column !! $columns;

    my $nrow = round(@data.elems / $ncol);
    my @tbl = transpose(@data.rotor($nrow, :partial));

    my $nc = @tbl.head.elems;
    my @cns = ('X' X~ (1 .. $nc)>>.Str).Array;
    my $res = @tbl.map({ @cns Z=> $_.Array })>>.Hash.Array;

    my $res2 = to-html($res, field-names => @cns, |%args.grep({ $_.key ∉ <field-names multicolumn multi-column> }).Hash);

    return $res2.subst(/ '<thead>' .*? '</thead>' /);
}

#------------------------------------------------------------
#| Convert a list into an HTML table stencil.
#| To have table header a list of pairs have to be provided.
proto sub to-html-table($data, |) is export {*}

multi sub to-html-table(@tbls where @tbls.all ~~ Str:D, Str:D :$align = 'left') {

    my $pre = '<table border="1"><tr>';
    my $post = '</tr></table>';
    my $tdStart = '<td style="border: 3px solid black;">';
    my $res = $pre ~ @tbls.map({ "{$tdStart}{$_}</td>" }) ~ $post;

    return $res;
}

multi sub to-html-table(@data where @data.all ~~ Pair:D, Str:D :$align = 'left') {
    my $html = '<table style="border-collapse: collapse; border: 3px solid black;">';
    $html ~= '<thead><tr>';
    for @data -> $pair {
        $html ~= "<th style=\"border: 3px solid black; text-align: {$align};\">{$pair.key}</th>";
    }
    $html ~= '</tr></thead><tbody><tr>';
    for @data -> $pair {
        $html ~= "<td style=\"border: 3px solid black; text-align: {$align};\">{$pair.value}</td>";
    }
    $html ~= '</tr></tbody></table>';
    return $html;
}

#===========================================================
# JSON to R
#===========================================================
#| Highlight substrings in a given string that is an HTML table spec.
proto sub html-table-highlight(Str:D $s, |) is export {*}
multi sub html-table-highlight(Str:D $s, @highlight, Str:D :$color = 'Orange', :$font-size = Whatever, :$font-weight = 'normal') {
    return html-table-highlight($s, :@highlight, :$color, :$font-size);
}

multi sub html-table-highlight(Str:D $s, :h(:@highlight)!, Str:D :c(:$color) = 'Orange', :s(:$font-size) = Whatever, :w(:$font-weight) = 'normal') {
    my $head = $font-size ~~ Numeric:D ?? "<span style=\"color: $color; font-size:{$font-size}pt; font-weight:$font-weight\">" !! "<span style=\"color: $color; font-weight:$font-weight\">";
    reduce(
            { $^a.subst( / <?after '<td>'> $^b <?before '</td>'> /, $head ~ $^b ~ '</span>', :g) },
            $s, |@highlight) 
}

#===========================================================
# JSON to R
#===========================================================
#| Convert JSON string or JSON-like structure into an R spec.
#| C<$data> -- Data to convert.
#| C<$field-names> -- Field names to use for Map objects.
proto sub to-r($data, *%args) is export {*}

multi sub to-r($data, *%args) {

    my $jtr = Data::Translators::R.new(|%args);

    return $jtr.convert($data);
}

#===========================================================
# JSON to WL
#===========================================================
#| Convert JSON string or JSON-like structure into a WL spec.
#| C<$data> -- Data to convert.
#| C<$field-names> -- Field names to use for Map objects.
proto sub to-wl($data, *%args) is export {*}

multi sub to-wl($data, *%args) {

    my $jtr = Data::Translators::WL.new(|%args);

    return $jtr.convert($data);
}

#===========================================================
# To dataset
#===========================================================
#| Convert a data structures to dataset (a Positional of Positionals or Maps.)
#| C<$data> -- Data to convert.
#| C<$missing-value> -- The value for missing values in the result dataset.
proto sub to-dataset($data, :$missing-value = '') is export {*}

multi sub to-dataset($data where $data ~~ Numeric || $data ~~ Str || $data ~~ DateTime) {
    return [[$data,],];
}

multi sub to-dataset($data, :$missing-value = '') {
    given $data {
        when (is-reshapable(Iterable, Map, $_) || is-reshapable(Positional, Iterable,
                $_)) && has-homogeneous-shape($_) {
            return $data;
        }

        when is-array-of-hashes($_) {
            my @allColnames = $_>>.keys.flat.unique.Array;
            my %emptyRow = @allColnames X=> $missing-value;
            return $_.map({ merge-hash(%emptyRow, $_) }).Array;
        }

        when is-hash-of-hashes($_) {
            my @allColnames = $_.values>>.keys.flat.unique.Array;
            my %emptyRow = @allColnames X=> $missing-value;
            return $_.map({ $_.key => merge-hash(%emptyRow, $_.value) }).Hash;
        }

        when $_ ~~ Seq {
            return to-dataset($data.Array, :$missing-value);
        }

        when $_ ~~ Hash && ($_.values.all ~~ Str || $_.values.all ~~ Numeric || $_.values.all ~~ DateTime) {
            return $_.map({ Hash.new(<Key Value> Z=> $_.kv) }).Array;
        }

        when $_ ~~ Iterable && $_.all ~~ Pair {
            return $_.map({ Hash.new(<Key Value> Z=> $_.kv) }).Array;
        }

        default {
            note 'Do not know how to process the data argument.';
            return $_;
        }
    }
}

#===========================================================
# HTML
#===========================================================
sub html-table-data-extraction(Str:D $html, Str:D :icp(:$index-column-prefix) = '') is export {
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