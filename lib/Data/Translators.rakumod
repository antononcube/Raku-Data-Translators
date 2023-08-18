use v6.d;

use Data::Translators::HTML;
use Data::Translators::R;
use Data::TypeSystem;
use Data::TypeSystem::Predicates;
use Hash::Merge;

unit module Data::Translators;

#===========================================================
# JSON to HTML
#===========================================================
#| Convert JSON string or JSON-like structure into an HTML spec.
#| C<$data> -- Data to convert.
#| C<$field-names> -- Field names to use for Map objects.
#| C<$table-attributes> -- HTML table attributes to use.
#| C<$encode> -- Whether to encode or not.
#| C<$escape> -- Whether to escape or not.
proto sub json-to-html($data, *%args) is export {*}

multi sub json-to-html($data, *%args) {

    my $jtr = Data::Translators::HTML.new(|%args);

    return $jtr.convert($data);
}

#===========================================================
# JSON to R
#===========================================================
#| Convert JSON string or JSON-like structure into an R spec.
#| C<$data> -- Data to convert.
#| C<$field-names> -- Field names to use for Map objects.
proto sub json-to-r($data, *%args) is export {*}

multi sub json-to-r($data, *%args) {

    my $jtr = Data::Translators::R.new(|%args);

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
        when (is-reshapable(Iterable, Map, $_) || is-reshapable(Positional, Iterable, $_)) && has-homogeneous-shape($_) {
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

        when $_ ~~ Hash && ($_.values.all ~~ Str || $_.values.all ~~ Numeric || $_.values.all ~~ DateTime) {
            return $_.map({ Hash.new( <Key Value> Z=> $_.kv ) }).Array;
        }

        when $_ ~~ Iterable && $_.all ~~ Pair {
            return $_.map({ Hash.new( <Key Value> Z=> $_.kv ) }).Array;
        }

        default {
            note 'Do not know how to process the data argument.';
            return $_;
        }
    }
}