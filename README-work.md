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

Here is the corresponding dataset type:

```perl6
deduce-type($tbl);
```

Here is the corresponding HTML table:

```perl6, results=asis
$tbl ==> json-to-html;
```

Here is how the transposed dataset is tabulated:

```perl6, results=asis
$tbl ==> transpose() ==> json-to-html;
```

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

### Cross-tabulated data

Here is a more involved data example:

```perl6, results=asis
json-to-html(cross-tabulate(get-titanic-dataset, 'passengerSex', 'passengerSurvival'))
```

Compare the HTML table above with the following plain text table:

```perl6
to-pretty-table(cross-tabulate(get-titanic-dataset, 'passengerSex', 'passengerSurvival'))
```