# JSON::Translators 

Raku package for translation of JSON specs or JSON-like data structures into other formats.

### Basic usage

Here is a "main use case" example:

```perl6, results=asis
use Data::Reshapers;
use JSON::Translators;

json-to-html(get-titanic-dataset.pick(5));
```
<table border="1"><thead><tr><th>passengerClass</th><th>id</th><th>passengerSex</th><th>passengerAge</th><th>passengerSurvival</th></tr></thead><tbody><tr><td>3rd</td><td>1015</td><td>female</td><td>-1</td><td>died</td></tr><tr><td>3rd</td><td>707</td><td>female</td><td>-1</td><td>died</td></tr><tr><td>3rd</td><td>973</td><td>male</td><td>30</td><td>died</td></tr><tr><td>3rd</td><td>623</td><td>male</td><td>0</td><td>died</td></tr><tr><td>3rd</td><td>668</td><td>female</td><td>30</td><td>died</td></tr></tbody></table>


Here is a JSON string translation to HTML:

```perl6, results=asis
my $json1 = q:to/END/;
{
    "sample": [
        {"name": "json2html", "desc": "coverts json 2 html table format", "lang": "python"},
        {"name": "testing", "desc": "clubbing same keys of array of objects", "lang": "python"}
    ]
}
END

json-to-html($json1);
```
<table border="1"><tr><th>sample</th><td><table border="1"><thead><tr><th>lang</th><th>desc</th><th>name</th></tr></thead><tbody><tr><td>python</td><td>coverts json 2 html table format</td><td>json2html</td></tr><tr><td>python</td><td>clubbing same keys of array of objects</td><td>testing</td></tr></tbody></table></td></tr></table>


Here is a more involved data example:

```perl6, results=asis
json-to-html(cross-tabulate(get-titanic-dataset, 'passengerSex', 'passengerSurvival'))
```
<table border="1"><tr><th>male</th><td><table border="1"><tr><th>died</th><td>682</td><th>survived</th><td>161</td></tr></table></td><th>female</th><td><table border="1"><tr><th>survived</th><td>339</td><th>died</th><td>127</td></tr></table></td></tr></table>


Compare the HTML table above with the following plain text table:

```perl6
to-pretty-table(cross-tabulate(get-titanic-dataset, 'passengerSex', 'passengerSurvival'))
```
```
# +--------+----------+------+
# |        | survived | died |
# +--------+----------+------+
# | female |   339    | 127  |
# | male   |   161    | 682  |
# +--------+----------+------+
```