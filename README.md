# JSON::Translators 

Raku package for translation of JSON specs or JSON-like data structures into other formats.

## Basic usage

## Main use case

Here is a "main use case" example:
1. Get a dataset that is an array of hashes
2. Filter or sample the records
3. Make an HTML table with those records

The HTML table outputs can be used to present datasets nicely in:
- Markdown documents 
- Jupyter notebooks

Here we get the Titanic dataset and sample it:

```perl6
use Data::Reshapers;
use Data::TypeSystem;
use JSON::Translators;

my $tbl = get-titanic-dataset.pick(3);
```
```
# ({id => 517, passengerAge => 40, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 1293, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 1299, passengerAge => 40, passengerClass => 3rd, passengerSex => male, passengerSurvival => died})
```

Here is the corresponding dataset type:

```perl6
deduce-type($tbl);
```
```
# Vector(Assoc(Atom((Str)), Atom((Str)), 5), 3)
```

Here is the corresponding HTML table:

```perl6, results=asis
$tbl ==> json-to-html;
```
<table border="1"><thead><tr><th>passengerSurvival</th><th>passengerAge</th><th>passengerSex</th><th>passengerClass</th><th>id</th></tr></thead><tbody><tr><td>died</td><td>40</td><td>male</td><td>2nd</td><td>517</td></tr><tr><td>died</td><td>-1</td><td>male</td><td>3rd</td><td>1293</td></tr><tr><td>died</td><td>40</td><td>male</td><td>3rd</td><td>1299</td></tr></tbody></table>


Here is how the transposed dataset is tabulated:

```perl6, results=asis
$tbl ==> transpose() ==> json-to-html;
```
<table border="1"><tr><th>passengerSurvival</th><td><ul><li>died</li><li>died</li><li>died</li></ul></td><th>passengerSex</th><td><ul><li>male</li><li>male</li><li>male</li></ul></td><th>passengerClass</th><td><ul><li>2nd</li><li>3rd</li><li>3rd</li></ul></td><th>id</th><td><ul><li>517</li><li>1293</li><li>1299</li></ul></td><th>passengerAge</th><td><ul><li>40</li><li>-1</li><li>40</li></ul></td></tr></table>


### From JSON strings

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
<table border="1"><tr><th>sample</th><td><table border="1"><thead><tr><th>desc</th><th>name</th><th>lang</th></tr></thead><tbody><tr><td>coverts json 2 html table format</td><td>json2html</td><td>python</td></tr><tr><td>clubbing same keys of array of objects</td><td>testing</td><td>python</td></tr></tbody></table></td></tr></table>


### Cross-tabulated data

Here is a more involved data example:

```perl6, results=asis
json-to-html(cross-tabulate(get-titanic-dataset, 'passengerSex', 'passengerSurvival'))
```
<table border="1"><tr><th>male</th><td><table border="1"><tr><th>died</th><td>682</td><th>survived</th><td>161</td></tr></table></td><th>female</th><td><table border="1"><tr><th>died</th><td>127</td><th>survived</th><td>339</td></tr></table></td></tr></table>


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