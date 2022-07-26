# Annotation Server

The Annotation Server is PharMe's data providing backend. It collects data
targeted at medical professionals on [medications][gl] and [guidelines][gl] from
[DrugBank](https://go.drugbank.com)'s academic license (given as a zipped XML
file) and [CPIC](https://cpicpgx.org)'s API respectively.

Additionally, it allows *[annotating][gl]* this data with information targeted
at patients, i.e. people without professional medical education. This process of
annotating can be conducted through the [Annotation
Interface](../annotation-interface) or with data given in a Google Sheet.

The data the Annotation Server provides is used by the [app](../app) to be
presented to users.

## Swagger Endpoint Documentation (OpenAPI)

You can find all available API endpoints defined as Swagger Documentation
[here](https://annotation-server-pharme.dhc-lab.hpi.de/api).

> Please note that this endpoint is only available in the HPI network.
> That means you either need to be connected directly or through a VPN.

## Getting Started

See our [Contribution Guide](CONTRIBUTING.md) to get started.

[gl]: ../docs/GLOSSARY.md
