# Annotation Interface

The Annotation Interface is the curator's interface to our [Annotation
Server](../annotation-server). It is one way of administering the Annotation
Server's data without the need of technical expertise by providing a
comprehensible interface to fetch external data and curate
[annotations](../docs/GLOSSARY.md). Additional instructions are given within the
interface.

> Please note that the Annotation Interface is not currently deployed, meaning
> its only available by setting it up locally. See the [Contribution
> Guide](CONTRIBUTING.md) for information on how to set it up.

## Getting Started

See our [Contribution Guide](CONTRIBUTING.md) to get started.

## Updating

To update data from external sources, execute the following steps (API
request can be executed with Postman):

* Get current backup using the `GET /api/backup` route and save the response to
  `./backup.base64.json`
* Init external sources using the `POST /api/init-external` route (overwrites
  present data, make sure it was backed up properly)
* Get overwritten backup using the `/api/backup` route again and save the
  response to `./initiated.base64.json`
* Run update script
  `python update.py ./backup.base64.json ./initiated.base64.json`
* Upload the updated backup `./backup_updated_[timestamp].base64.json` with
  `POST /api/backup`
