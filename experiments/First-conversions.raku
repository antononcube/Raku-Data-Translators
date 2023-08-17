#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use JSON::Translators;
use JSON::Actions::HTML;

use JSON::Fast;

use Data::Reshapers;
use Data::TypeSystem;

my $spec = q:to/END/;
jsonObject = {
    "sampleData": [
        {"a":1, "b":2, "c":3},
        {"a":5, "b":6, "c":7}
    ]
}
END

my $jtr = JSON::Actions::HTML.new;

say $jtr.convert($spec);

say "=" x 120;

my %json1 =
    "name" => "Json2Html",
    "desription" => "converts json 2 html table format"
;

say $jtr.convert(%json1);

say "=" x 120;

my @tbl = get-titanic-dataset.pick(2);

say deduce-type(@tbl);
say deduce-type(@tbl).raku;

say deduce-type(@tbl) ~~ Data::TypeSystem::Vector;
say deduce-type(@tbl).type ~~ Data::TypeSystem::Assoc;

say &is-reshapable.WHY;
say &is-reshapable.signature;
say is-reshapable(@tbl, iterable-type => Positional, record-type => Map);

say to-json(@tbl);

say json-to-html(@tbl);

spurt $*CWD ~ "/tbl.html", json-to-html(get-titanic-dataset);

say "=" x 120;

say to-json(get-titanic-dataset(headers=>'none').pick(5));

spurt $*CWD ~ "/tbl2.html", json-to-html(get-titanic-dataset(headers=>'none'));


say "=" x 120;

my $json2 = q:to/END/;
{
        "glossary": {
                "title": "example glossary",
                "GlossDiv": {
                        "title": "S",
                        "GlossList": {
                                "GlossEntry": {
                                        "ID": "SGML",
                                        "SortAs": "SGML",
                                        "GlossTerm": "Standard Generalized Markup Language",
                                        "Acronym": "SGML",
                                        "Abbrev": "ISO 8879:1986",
                                        "GlossDef": {
                                                "para": "A meta-markup language, used to create markup languages such as DocBook.",
                                                "GlossSeeAlso": ["GML", "XML"]
                                        },
                                        "GlossSee": "markup"
                                }
                        }
                }
        }
}
END

say json-to-html($json2);
