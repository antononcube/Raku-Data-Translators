use v6.d;

use JSON::Fast;
use Data::TypeSystem;
use Data::Translators::HTML;

class Data::Translators::WL
        is Data::Translators::HTML {

    submethod TWEAK {
        self.escape = False;
        self.encode = False;
    }

    method convert-json-node($json-input) {
        if $json-input ~~ Str:D {
            return "\"$json-input\"";
        } elsif $json-input ~~ Associative:D {
            return self.convert-object($json-input);
        } elsif $json-input ~~ Iterable:D {
            return self.convert-list($json-input);
        }
        return $json-input.Str;
    }

    method convert-list(@list-input) {
        return '' unless @list-input;
        my $converted-output = '';
        my @column-headers = Empty;
        @column-headers = self.column-headers-from-list-of-maps(@list-input) if self.clubbing;
        if @column-headers {
            $converted-output ~= 'List[';
            my @res;
            for @list-input -> %entry {
                @res.push( '<|' ~ @column-headers.map({ "\"$_\" -> {self.convert-json-node(%entry{$_})}" }).join(', ') ~ '|>' );
            }
            $converted-output ~= @res.join(', ') ~ ']';
            return $converted-output;
        }

        $converted-output = "List[{ @list-input.map({ self.convert-json-node($_) }).join(', ') }]";
        return $converted-output;
    }

    method convert-object(%json-input) {
        return '' unless %json-input;
        my $converted-output = 'Association[';
        my @res;
        my @pairs =
                do if self.field-names ~~ Positional {
                    self.field-names.map({ %json-input{$_}:exists ?? ($_ => %json-input{$_}) !! Empty })
                } else {
                    %json-input.pairs
                };

        for @pairs -> $p {
            @res.push("{ self.convert-json-node($p.key) }->{ self.convert-json-node($p.value) }");
        }
        $converted-output ~= @res.join(', ') ~ ']';
        return $converted-output;
    }
}
