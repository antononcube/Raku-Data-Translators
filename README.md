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
# ({id => 683, passengerAge => -1, passengerClass => 3rd, passengerSex => female, passengerSurvival => died} {id => 556, passengerAge => 20, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 158, passengerAge => -1, passengerClass => 1st, passengerSex => male, passengerSurvival => died})
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
$tbl ==> json-to-html
```
<table border="1"><thead><tr><th>passengerSurvival</th><th>passengerClass</th><th>passengerSex</th><th>passengerAge</th><th>id</th></tr></thead><tbody><tr><td>died</td><td>3rd</td><td>female</td><td>-1</td><td>683</td></tr><tr><td>died</td><td>2nd</td><td>male</td><td>20</td><td>556</td></tr><tr><td>died</td><td>1st</td><td>male</td><td>-1</td><td>158</td></tr></tbody></table>


We can specify field names and HTML table attributes:

```perl6, results=asis
$tbl ==> json-to-html(field-names => <id passengerSurvival>, table-attributes => 'id="info-table" class="table table-bordered table-hover" text-align="center"');
```
<table id="info-table" class="table table-bordered table-hover" text-align="center"><thead><tr><th>id</th><th>passengerSurvival</th></tr></thead><tbody><tr><td>683</td><td>died</td></tr><tr><td>556</td><td>died</td></tr><tr><td>158</td><td>died</td></tr></tbody></table>


Here is how the transposed dataset is tabulated:

```perl6, results=asis
$tbl ==> transpose() ==> json-to-html;
```
<table border="1"><tr><th>id</th><td><ul><li>683</li><li>556</li><li>158</li></ul></td></tr><tr><th>passengerAge</th><td><ul><li>-1</li><li>20</li><li>-1</li></ul></td></tr><tr><th>passengerSurvival</th><td><ul><li>died</li><li>died</li><li>died</li></ul></td></tr><tr><th>passengerClass</th><td><ul><li>3rd</li><li>2nd</li><li>1st</li></ul></td></tr><tr><th>passengerSex</th><td><ul><li>female</li><li>male</li><li>male</li></ul></td></tr></table>


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
<table border="1"><tr><th>sample</th><td><table border="1"><thead><tr><th>desc</th><th>lang</th><th>name</th></tr></thead><tbody><tr><td>coverts json 2 html table format</td><td>python</td><td>json2html</td></tr><tr><td>clubbing same keys of array of objects</td><td>python</td><td>testing</td></tr></tbody></table></td></tr></table>


### Cross-tabulated data

Here is a more involved data example:

```perl6, results=asis
json-to-html(cross-tabulate(get-titanic-dataset, 'passengerSex', 'passengerSurvival'))
```
<table border="1"><tr><th>female</th><td><table border="1"><tr><th>survived</th><td>339</td></tr><tr><th>died</th><td>127</td></tr></table></td></tr><tr><th>male</th><td><table border="1"><tr><th>survived</th><td>161</td></tr><tr><th>died</th><td>682</td></tr></table></td></tr></table>


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

------

## Implementation notes

- The "need" for this package become evident while working on the notebooks/articles [AA1, AA2]. 
- Initially, I translated plain text tables into HTML.
- I considered re-using the code behind `to-pretty-table` provided by "Data::Reshapers", [AAp1].
  - This was "too much work" and wanted a lighter weight package.
- Having a solution for the more general problem ***translating JSON to HTML*** seemed a much better and easier option.  
  - For example, I hoped that someone has already solved that problem for Raku.
- Since I did not find Raku packages for the translation I wanted I looked for solutions into the Python ecosystem.
  - ... And found ["json2html"](https://github.com/softvar/json2html).
- Using ChatGPT-4.0 I translated the only class of that package from Python in Raku.
- The translation executed with relative minor changes.
  - I further refactored and enhanced it to fit Raku workflows.

It is envisioned this package to have translators to other formats. For example:
- [ ] Plain text
- [ ] Python
- [ ] Mermaid-JS
- [ ] R
- [ ] Julia
- [ ] WL
- [ ] SQL

------

## References

### Articles 

[AA1] Anton Antonov, 
["Workflows with LLM functions"](https://rakuforprediction.wordpress.com/2023/08/01/workflows-with-llm-functions/), 
(2023), 
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov,
["TLDR LLM solutions for software manuals"](https://rakuforprediction.wordpress.com/2023/08/15/tldr-llm-solutions-for-software-manuals/),
(2023),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).


### Packages

[AAp1] Anton Antonov,
[Data::Reshapers Raku package](https://github.com/antononcube/Raku-Data-Reshapers),
(2021-2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[Data::TypeSystem Raku package](https://github.com/antononcube/Raku-Data-TypeSystem),
(2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov, 
[LLM::Functions Raku package](https://github.com/antononcube/Raku-LLM-Functions), 
(2023), 
[GitHub/antononcube](https://github.com/antononcube).


[VMp1] Varun Malhotra,
[json2html Python package](https://github.com/softvar/json2html),
(2013-2021),
[GitHub/softvar](https://github.com/softvar).