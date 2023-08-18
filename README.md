# JSON::Translators 

Raku package for translation of JSON specs or JSON-like data structures into other formats.

It is envisioned this package to have translators to multiple formats. For example:
- [X] DONE HTML
- [X] DONE R
- [ ] TODO Plain text
- [ ] TODO Python
- [ ] TODO Mermaid-JS
- [ ] TODO Julia
- [ ] TODO WL
- [ ] TODO SQL

The main motivation for making the package is to have convenient way of making tables 
while doing Literate programming with Raku using:

- Computational Markdown documents, [AAp4]
- Jupyter notebooks, [BDp1]
- Mathematica notebooks, [AAp4]

The use of JSON came to focus, since when working Large Language Model (LLM) functions, [AAp3],
very often it is requested from LLMs to produce output in JSON format, [AA1, AA2].

The package "Data::Reshapers", [AAp1], would complement nicely "JSON::Translators" and vice versa.
The package "Data::TypeSystem", [AAp2], is used for "translation decisions" and for conversions into more regular datasets. 

The package "Mathematica::Serializer", [AAp5], has very similar mission --
it is for translating Raku data structures into Mathematica (aka Wolfram Language or WL) code.

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
# ({id => 614, passengerAge => 30, passengerClass => 3rd, passengerSex => male, passengerSurvival => survived} {id => 922, passengerAge => -1, passengerClass => 3rd, passengerSex => male, passengerSurvival => died} {id => 510, passengerAge => 40, passengerClass => 2nd, passengerSex => male, passengerSurvival => died})
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
<table border="1"><thead><tr><th>passengerSex</th><th>passengerClass</th><th>id</th><th>passengerSurvival</th><th>passengerAge</th></tr></thead><tbody><tr><td>male</td><td>3rd</td><td>614</td><td>survived</td><td>30</td></tr><tr><td>male</td><td>3rd</td><td>922</td><td>died</td><td>-1</td></tr><tr><td>male</td><td>2nd</td><td>510</td><td>died</td><td>40</td></tr></tbody></table>


We can specify field names and HTML table attributes:

```perl6, results=asis
$tbl ==> json-to-html(field-names => <id passengerSurvival>, table-attributes => 'id="info-table" class="table table-bordered table-hover" text-align="center"');
```
<table id="info-table" class="table table-bordered table-hover" text-align="center"><thead><tr><th>id</th><th>passengerSurvival</th></tr></thead><tbody><tr><td>614</td><td>survived</td></tr><tr><td>922</td><td>died</td></tr><tr><td>510</td><td>died</td></tr></tbody></table>


Here is how the transposed dataset is tabulated:

```perl6, results=asis
$tbl ==> transpose() ==> json-to-html;
```
<table border="1"><tr><th>id</th><td><ul><li>614</li><li>922</li><li>510</li></ul></td></tr><tr><th>passengerAge</th><td><ul><li>30</li><li>-1</li><li>40</li></ul></td></tr><tr><th>passengerClass</th><td><ul><li>3rd</li><li>3rd</li><li>2nd</li></ul></td></tr><tr><th>passengerSex</th><td><ul><li>male</li><li>male</li><li>male</li></ul></td></tr><tr><th>passengerSurvival</th><td><ul><li>survived</li><li>died</li><li>died</li></ul></td></tr></table>


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
<table border="1"><tr><th>female</th><td><table border="1"><tr><th>died</th><td>127</td></tr><tr><th>survived</th><td>339</td></tr></table></td></tr><tr><th>male</th><td><table border="1"><tr><th>died</th><td>682</td></tr><tr><th>survived</th><td>161</td></tr></table></td></tr></table>


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
data.frame(`id` = c("614", "922", "510"),
`passengerClass` = c("3rd", "3rd", "2nd"),
`passengerSex` = c("male", "male", "male"),
`passengerAge` = c("30", "-1", "40"),
`passengerSurvival` = c("survived", "died", "died"))
```

Here is the R code version of the contingency table:

```perl6, output.lang=r, output.prompt=NONE
json-to-r(cross-tabulate(get-titanic-dataset, 'passengerSex', 'passengerSurvival'))
```
```r
list("male"=list("survived"=161, "died"=682), "female"=list("survived"=339, "died"=127))
```

### Nicer datasets

In order to obtain datasets or more regular datasets the function `to-dataset` can be used.
Here a rugged dataset is made regular and converted to an HTML table:

```perl6, results=asis
my @tbl2 = get-titanic-dataset.pick(6);
@tbl2 = @tbl2.map({ $_.pick((1..5).pick).Hash });
@tbl2 ==> to-dataset(missing-value=>'・') ==> json-to-html
```
<table border="1"><thead><tr><th>id</th><th>passengerSurvival</th><th>passengerSex</th><th>passengerAge</th><th>passengerClass</th></tr></thead><tbody><tr><td>794</td><td>died</td><td>male</td><td>・</td><td>3rd</td></tr><tr><td>173</td><td>died</td><td>male</td><td>50</td><td>1st</td></tr><tr><td>・</td><td>・</td><td>male</td><td>20</td><td>2nd</td></tr><tr><td>・</td><td>died</td><td>・</td><td>30</td><td>・</td></tr><tr><td>・</td><td>・</td><td>・</td><td>・</td><td>2nd</td></tr><tr><td>956</td><td>・</td><td>female</td><td>・</td><td>・</td></tr></tbody></table>


Here a hash is transformed into dataset with columns `<Key Value>` and then converted into an HTML table:

```perl6, results=asis
{ 4 => 'a', 5 => 'b', 8 => 'c'} ==> to-dataset() ==> json-to-html
```
<table border="1"><thead><tr><th>Value</th><th>Key</th></tr></thead><tbody><tr><td>a</td><td>4</td></tr><tr><td>c</td><td>8</td></tr><tr><td>b</td><td>5</td></tr></tbody></table>


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
- Using ChatGPT-4.0 I translated the only class of that package from Python into Raku.
- The obtained translation could be executed with relatively minor changes.
  - I further refactored and enhanced the HTML translator to fit my most frequent Raku workflows.

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

[AAp4] Anton Antonov,
[Text::CodeProcessing Raku package](https://github.com/antononcube/Raku-Text-CodeProcessing),
(2021-2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[Mathematica::Serializer Raku package](https://github.com/antononcube/Raku-Mathematica-Serializer),
(2021-2022),
[GitHub/antononcube](https://github.com/antononcube).

[BDp1] Brian Duggan,
[Jupyter:Kernel Raku package](https://github.com/bduggan/raku-jupyter-kernel),
(2017-2023),
[GitHub/bduggan](https://github.com/bduggan).

[VMp1] Varun Malhotra,
[json2html Python package](https://github.com/softvar/json2html),
(2013-2021),
[GitHub/softvar](https://github.com/softvar).