use v6.d;

use JSON::Fast;
use Data::TypeSystem;

class Data::Translators::HTML {
    has $!table-init-markup;
    has Str $.table-attributes = 'border="1"';
    has Bool $.clubbing = True;
    has Bool $.escape is rw = True;
    has Bool $.encode is rw = False;
    has $.field-names = Whatever;

    submethod TWEAK {
        $!table-init-markup = "<table $!table-attributes>";
        if $!field-names ~~ Str:D {
            $!field-names = [$!field-names,];
        }
        if $!field-names ~~ Positional && !$!field-names {
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

        return $!encode ?? $converted.encode('ascii').trans(['<', '>', '&', '\'', '"'] => ['&lt;', '&gt;', '&amp;', '&#39;', '&quot;']) !! $converted;
    }

    method column-headers-from-list-of-maps($json-input) {
        if is-reshapable($json-input, iterable-type => Positional, record-type => Map) {
            my @column-headers = $json-input[0].keys;
            if $!field-names ~~ Positional && $!field-names.all ~~ Str:D {
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
        if $json-input ~~ Str:D {
            return $!escape ?? $json-input.trans(['<', '>', '&', '\'', '"'] => ['&lt;', '&gt;', '&amp;', '&#39;', '&quot;']) !! $json-input;
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
}
