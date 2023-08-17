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
$tbl ==> json-to-html
```

We can specify field names and HTML table attributes:

```perl6, results=asis
$tbl ==> json-to-html(field-names => <id passengerSurvival>, table-attributes => 'id="info-table" class="table table-bordered table-hover" text-align="center"');
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