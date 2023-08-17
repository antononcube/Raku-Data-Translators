use v6.d;

use JSON::Fast;
use Data::TypeSystem;

class JSON::Actions::HTML {
    has $.table-init-markup;
    has $.clubbing = True;
    has $.escape = True;

    method convert(
            $json = "",
            $table-attributes = 'border="1"',
            $clubbing = True,
            $encode = False,
            $escape = True
                   ) {
        $!table-init-markup = "<table $table-attributes>";
        $!clubbing = $clubbing;
        $!escape = $escape;

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

        return $encode ?? $converted.encode('ascii').trans(['<', '>', '&', '\'', '"'] => ['&lt;', '&gt;', '&amp;', '&#39;', '&quot;']) !! $converted;
    }

    method column-headers-from-list-of-maps($json-input) {
        if is-reshapable($json-input, iterable-type => Positional, record-type => Map) {
            my @column-headers = $json-input[0].keys;
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
        return "" unless @list-input;
        my $converted-output = "";
        my @column-headers = Empty;
        @column-headers = self.column-headers-from-list-of-maps(@list-input) if $!clubbing;
        if @column-headers {
            $converted-output ~= $!table-init-markup;
            if @column-headers {
                $converted-output ~= '<thead>';
                $converted-output ~= '<tr><th>' ~ @column-headers.join('</th><th>') ~ '</th></tr>';
                $converted-output ~= '</thead>';
            }
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
        return "" unless %json-input;
        my $converted-output = $!table-init-markup ~ '<tr>';
        for %json-input.kv -> $k, $v {
            $converted-output ~= "<th>{ self.convert-json-node($k) }</th><td>{ self.convert-json-node($v) }</td>";
        }
        $converted-output ~= "</tr></table>";
        return $converted-output;
    }
}
