use v6.d;

use JSON::Translators::HTML;

unit module JSON::Translators;

#| Convert JSON string or JSON-like structure into an HTML spec.
#| C<$data> -- Data to convert.
#| C<$field-names> -- Field names to use for Map objects.
#| C<$table-attributes> -- HTML table attributes to use.
#| C<$encode> -- Whether to encode or not.
#| C<$escape> -- Whether to escape or not.
proto sub json-to-html($data, *%args) is export {*}

multi sub json-to-html($data, *%args) {

    my $jtr = JSON::Translators::HTML.new(|%args);

    return $jtr.convert($data);
}