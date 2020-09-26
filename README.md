# small-cmd-tools
 A small collection of small tools  to process CMD


## cr2html

Creates an HTML view of a component or profile.

Using [Saxon 10.1](https://www.saxonica.com/): 

```sh
$ java -jar SaxonHE10-1J/saxon-he-10.1.jar -xsl:cr2html/cr2html.xsl -it:main id='clarin.eu:cr1:p_1505397653795'
```

And the Github raw version:

```sh
$ java -jar SaxonHE10-1J/saxon-he-10.1.jar -xsl:https://raw.githubusercontent.com/menzowindhouwer/small-cmd-tools/master/cr2html/cr2html.xsl -it:main id='clarin.eu:cr1:c_1271859438110' 'max-items=25'
```

The `max-items` parameter determines how many vocabulary items are maximally shown (default: 100).

Its also possible to create a HTML view of a local spec:

```sh
$ java -jar SaxonHE10-1J/saxon-he-10.1.jar -xsl:cr2html/cr2html.xsl -s:YOUR-LOCAL-SPEC.XML
```
