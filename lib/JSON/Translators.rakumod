use v6.d;

use JSON::Actions::HTML;

unit module JSON::Translators;

proto sub json-to-html($spec, *%args) is export {*}

multi sub json-to-html($spec, *%args) {

    my $jtr = JSON::Actions::HTML.new;

    return $jtr.convert($spec, |%args);
}