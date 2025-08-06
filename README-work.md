# Data::Translators 

Raku package for translation of JSON specs or JSON-like data structures into other formats.

It is envisioned this package to have translators to multiple formats. For example:
- [X] DONE HTML
- [X] DONE JSON
- [X] DONE R
- [X] DONE WL
- [ ] TODO Plain text
- [ ] TODO Python
- [ ] TODO Mermaid-JS
- [ ] TODO Julia
- [ ] TODO SQL

The main motivation for making the package is to have convenient way of making tables while doing 
[Literate programming](https://en.wikipedia.org/wiki/Literate_programming) 
with Raku using:

- Computational Markdown documents, [AAp4]
- Jupyter notebooks, [BDp1]
- Mathematica notebooks, [AAp4]

The use of JSON came to focus, since when working with Large Language Model (LLM) functions, [AAp3],
very often it is requested from LLMs to produce output in JSON format, [AA1, AA2].

The package "Data::Reshapers", [AAp1], would complement nicely "Data::Translators" and vice versa.
The package "Data::TypeSystem", [AAp2], is used for "translation decisions" and for conversions into more regular datasets. 

The package "Mathematica::Serializer", [AAp5], has a very similar mission --
it is for translating Raku data structures into Mathematica (aka Wolfram Language or WL) code.

In order to utilize "Data::Translators" while doing Literate programming with:
- Computational Markdown files, then use the code chunk argument `results=asis`.
- Jupyter notebooks, then use the code cell magic spec `%%html` or `%% > html`.

One can find concrete examples for:
- Computational Markdown files, in the [raw source code of this README](https://raw.githubusercontent.com/antononcube/Raku-Data-Translators/main/README.md)
- Jupyter notebooks, in the [magics examples notebook](https://github.com/bduggan/raku-jupyter-kernel/blob/master/eg/magics.ipynb) at [BDp1]

**Remark:** The provided converters are made for communication purposes, so they might not be
very performant. I have used or tested them with datasets that have less than 5000 rows.

------

## Installation

Package installations from both sources use [zef installer](https://github.com/ugexe/zef)
(which should be bundled with the "standard" Rakudo installation file.)

To install the package from [Zef ecosystem](https://raku.land/) use the shell command:

```
zef install Data::Translators
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
use Data::Translators;

my $tbl = get-titanic-dataset.pick(3);
```

Here is the corresponding dataset type:

```perl6
deduce-type($tbl);
```

Here is the corresponding HTML table:

```perl6, results=asis
$tbl ==> data-translation
```

We can specify field names and HTML table attributes:

```perl6, results=asis
$tbl ==> data-translation(field-names => <id passengerSurvival>, table-attributes => 'id="info-table" class="table table-bordered table-hover" text-align="center"');
```

Here is how the transposed dataset is tabulated:

```perl6, results=asis
$tbl ==> transpose() ==> data-translation;
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

data-translation($json1);
```

### From HTML strings

Get the data of an HTML table as a Raku dataset (array of hashmaps). Here is an HTML table string:

```raku
sink my $html = q:to/END/;
<table>
    <tr>
        <th>Name</th>
        <th>Age</th>
        <th>City</th>
    </tr>
    <tr>
        <td>John</td>
        <td>25</td>
        <td>New York</td>
    </tr>
    <tr>
        <td>Alice</td>
        <td>30</td>
        <td>London</td>
    </tr>
</table>
END
```

Here is the Raku dataset:

```raku
data-translation($html, target => 'dataset')
```

### Cross-tabulated data

Here is a more involved data example:

```perl6, results=asis
data-translation(cross-tabulate(get-titanic-dataset, 'passengerSex', 'passengerSurvival'))
```

Compare the HTML table above with the following plain text table:

```perl6
to-pretty-table(cross-tabulate(get-titanic-dataset, 'passengerSex', 'passengerSurvival'))
```

### Generation of R and WL code

Here is the R code version of the Titanic data sample:

```perl6, output.lang=r, output.prompt=NONE
$tbl ==> data-translation(target => 'R', field-names => <id passengerClass passengerSex passengerAge passengerSurvival>)
```

Here is the R code version of the contingency table:

```perl6, output.lang=r, output.prompt=NONE
data-translation(cross-tabulate(get-titanic-dataset, 'passengerSex', 'passengerSurvival'), target => 'R')
```

Here is the WL code version of the contingency table:

```perl6, output.lang=r, output.prompt=NONE
data-translation(cross-tabulate(get-titanic-dataset, 'passengerSex', 'passengerSurvival'), target => 'WL')
```

### Nicer datasets

In order to obtain datasets or more regular datasets the function `to-dataset` can be used.
Here a rugged dataset is made regular and converted to an HTML table:

```perl6, results=asis
my @tbl2 = get-titanic-dataset.pick(6);
@tbl2 = @tbl2.map({ $_.pick((1..5).pick).Hash });
@tbl2 ==> to-dataset(missing-value=>'・') ==> data-translation
```

Here a hash is transformed into dataset with columns `<Key Value>` and then converted into an HTML table:

```perl6, results=asis
{ 4 => 'a', 5 => 'b', 8 => 'c'} ==> to-dataset() ==> data-translation
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
- Using ChatGPT-4.0 I translated the only class of that package from Python into Raku.
- The obtained translation could be executed with relatively minor changes.
  - I further refactored and enhanced the HTML translator to fit my most frequent Raku workflows.
- The ingestion of JSON strings is done with the package ["JSON::Fast"](https://raku.land/cpan:TIMOTIMO/JSON::Fast).
  - Hence the conversion *to* JSON "comes for free" using `to-json` from that package.
- The initial versions of the package did not have the "umbrella" function `data-translation`.
  - Only the "lower level" functions `json-to-html` and `json-to-r` were provided. 
- The "lower level" functions, or shortcuts, can be used: `to-html`, `to-r`, `to-wl`.

------

## CLI

The package provides a Command Line Interface (CLI) script. Here is its usage message:


```shell
data-translation --help
```

Here is an example application (to [this file](./resources/professionals.json)):

```shell, results=asis
data-translation ./resources/professionals.json --field-names='data;id;name;age;profession'
```


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