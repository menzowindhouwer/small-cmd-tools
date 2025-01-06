# CMD to RDF

This project provides support for a set of CMDI cues to enrich a profile with its ConceptLinks to allow serialization of a record to RDF..

### rdf-subject

Used on a Component to indicate how the RDF subject should be determined:

- ``xpath:...`` XPath 3.0 expression  on the component instance
- ``_`` will generate an blank node identifier
- any other will be interpreted as the name of the sibling to be used

## Run the XSLT

```sh
$xsl2.sh -s:record-1.xml -xsl:lcmd2rdf.xsl > record-1.trix
```

Output is in the [TriX format](https://web.archive.org/web/20061121203144/http://swdev.nokia.com/trix/trix.html)

## Caveats

1. The RDF semantics of ested components need tp be fleshed out better.
