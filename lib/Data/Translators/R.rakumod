use v6.d;

use JSON::Fast;
use Data::TypeSystem;
use Data::Translators::HTML;

class Data::Translators::R
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
        $converted-output ~= 'data.frame(';
        if @column-headers {
            my %colVals = @column-headers X=> [];
            for @list-input -> %entry {
                for @column-headers -> $cn {
                    %colVals{$cn}.push(self.convert-json-node(%entry{$cn}));
                }
            }
            $converted-output ~= @column-headers.map({ "`{$_}` = c({%colVals{$_}.join(', ')})" }).join(",\n");
            $converted-output ~= ')';
            return $converted-output;
        }

        $converted-output = "list({ @list-input.map({ self.convert-json-node($_) }).join(', ') })";
        return $converted-output;
    }

    method convert-object(%json-input) {
        return '' unless %json-input;
        my $converted-output = 'list(';
        my @res;
        my @pairs =
                do if self.field-names ~~ Positional {
                    self.field-names.map({ $_ => %json-input{$_} })
                } else {
                    %json-input.pairs
                };

        for @pairs -> $p {
            @res.push("{ self.convert-json-node($p.key) }={ self.convert-json-node($p.value) }");
        }
        $converted-output ~= @res.join(', ') ~ ')';
        return $converted-output;
    }
}
