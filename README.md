# JSON::Translators 

Raku package for translation of JSON specs or JSON-like data structures into other formats.
(HTML, R, WL.)


------

## Installation

Package installations from both sources use [zef installer](https://github.com/ugexe/zef)
(which should be bundled with the "standard" Rakudo installation file.)

To install the package from [Zef ecosystem](https://raku.land/) use the shell command:

```
zef install JSON::Translators
```

To install the package from the GitHub repository use the shell command:

```
zef install https://github.com/antononcube/Raku-JSON-Translators.git
```


------

## Basic usage

### Main use case

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
# ({id => 355, passengerAge => 20, passengerClass => 2nd, passengerSex => male, passengerSurvival => died} {id => 1258, passengerAge => 10, passengerClass => 3rd, passengerSex => female, passengerSurvival => survived} {id => 500, passengerAge => 30, passengerClass => 2nd, passengerSex => male, passengerSurvival => died})
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
<table border="1"><thead><tr><th>passengerSurvival</th><th>passengerAge</th><th>passengerSex</th><th>passengerClass</th><th>id</th></tr></thead><tbody><tr><td>died</td><td>20</td><td>male</td><td>2nd</td><td>355</td></tr><tr><td>survived</td><td>10</td><td>female</td><td>3rd</td><td>1258</td></tr><tr><td>died</td><td>30</td><td>male</td><td>2nd</td><td>500</td></tr></tbody></table>


We can specify field names and HTML table attributes:

```perl6, results=asis
$tbl ==> json-to-html(field-names => <id passengerSurvival>, table-attributes => 'id="info-table" class="table table-bordered table-hover" text-align="center"');
```
<table id="info-table" class="table table-bordered table-hover" text-align="center"><thead><tr><th>id</th><th>passengerSurvival</th></tr></thead><tbody><tr><td>355</td><td>died</td></tr><tr><td>1258</td><td>survived</td></tr><tr><td>500</td><td>died</td></tr></tbody></table>


Here is how the transposed dataset is tabulated:

```perl6, results=asis
$tbl ==> transpose() ==> json-to-html;
```
<table border="1"><tr><th>passengerClass</th><td><ul><li>2nd</li><li>3rd</li><li>2nd</li></ul></td></tr><tr><th>id</th><td><ul><li>355</li><li>1258</li><li>500</li></ul></td></tr><tr><th>passengerAge</th><td><ul><li>20</li><li>10</li><li>30</li></ul></td></tr><tr><th>passengerSurvival</th><td><ul><li>died</li><li>survived</li><li>died</li></ul></td></tr><tr><th>passengerSex</th><td><ul><li>male</li><li>female</li><li>male</li></ul></td></tr></table>


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
<table border="1"><tr><th>sample</th><td><table border="1"><thead><tr><th>name</th><th>lang</th><th>desc</th></tr></thead><tbody><tr><td>json2html</td><td>python</td><td>coverts json 2 html table format</td></tr><tr><td>testing</td><td>python</td><td>clubbing same keys of array of objects</td></tr></tbody></table></td></tr></table>


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

### Generation of R code


Here is the R code version of the Titanic data sample:

```perl6, output.lang=r, output.prompt=NONE
$tbl ==> json-to-r(field-names => <id passengerClass passengerSex passengerAge passengerSurvival>)
```
```r
data.frame(`id` = c("355", "1258", "500"),
`passengerClass` = c("2nd", "3rd", "2nd"),
`passengerSex` = c("male", "female", "male"),
`passengerAge` = c("20", "10", "30"),
`passengerSurvival` = c("died", "survived", "died"))
```


Here is the R code version of the contingency table:

```perl6, output.lang=r, output.prompt=NONE
json-to-r(cross-tabulate(get-titanic-dataset, 'passengerSex', 'passengerSurvival'))
```
```r
list("male"=list("survived"=161, "died"=682), "female"=list("died"=127, "survived"=339))
```


------

## Implementation notes

- The "need" for this package became evident while working on the notebooks/articles [AA1, AA2]. 
- Initially, I translated plain text tables into HTML.
  - Using LLMs or `md-interpret` provided by "Markdown::Grammar".
- I considered re-using the code behind `to-pretty-table` provided by "Data::Reshapers", [AAp1].
  - This is "too much work" and I wanted a lighter weight package.
- Having a solution for the more general problem ***translating JSON to HTML*** seemed a much better and easier option.  
  - For example, I hoped that someone has already solved that problem for Raku.
- Since I did not find Raku packages for the translation I wanted, I looked for solutions into the Python ecosystem.
  - ... And found ["json2html"](https://github.com/softvar/json2html).
- Using ChatGPT-4.0 I translated the only class of that package from Python in Raku.
- The obtained translation could be executed with relatively minor changes.
  - I further refactored and enhanced the HTML translator to fit my most frequent Raku workflows.

It is envisioned this package to have translators to multiple formats. For example:
- [X] DONE HTML
- [X] DONE R
- [ ] TODO Plain text
- [ ] TODO Python
- [ ] TODO Mermaid-JS
- [ ] TODO Julia
- [ ] TODO WL
- [ ] TODO SQL

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