# Lab Server

PharMe's lab server is intended to mock an implementation of a real-world lab
or medical institution that is able to sequence, process, and store users' DNA.
In particular, this lab server implementation only supports the minimum
functionality required to interoperate with the rest of the system. The
processing and sequencing of arbitrary genomic data is therefore entirely
replaced by a pre-computed database of processed files which must be manually
supplied if running this service locally.

Alternatively, you can use a readily deployed version of the [lab
server](https://lab-server-pharme.dhc-lab.hpi.de/api). This is **strongly
recommended** for app-centric development as running the lab server's
authorization server locally can be problematic with emulators (especially on
Android).

The deployed lab server offers mock-data for several test users which can be
consumed by PharMe. Contact a project maintainer if you require these
credentials.

## Swagger Endpoint Documentation (OpenAPI)

You can find all available API endpoints of the currently deployed lab server
[here](https://lab-server-pharme.dhc-lab.hpi.de/api).

> Please note that this endpoint is only available in the HPI network.
> That means you either need to be connected directly or through a VPN.

## Getting Started

See our [Contribution Guide](CONTRIBUTING.md) to get started.
