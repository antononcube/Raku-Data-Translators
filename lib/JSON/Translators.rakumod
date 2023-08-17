use v6.d;

use JSON::Translators::HTML;

unit module JSON::Translators;

proto sub json-to-html($spec, *%args) is export {*}

multi sub json-to-html($spec, *%args) {

    my $jtr = JSON::Translators::HTML.new;

    return $jtr.convert($spec, |%args);
}