# Anni Migration Scripts

This script can be used to manually migrate Anni data backups after breaking
changes.

## Run script

1. Have `python3` installed
2. Run `pyhthon3 migrate.py <PATH_TO_BACKUP>.json[.base64]`
3. The script will test what needs to be migrated and write a migrated backup
to `<PATH_TO_BACKUP>_migrated.base64`

## Breaking changes covered

* [Add new medications (FDA)](https://github.com/hpi-dhc/PharMe/pull/582)
* [One annotation per phenotype](https://github.com/hpi-dhc/PharMe/pull/597)
* [Zipped Anni backup](https://github.com/hpi-dhc/PharMe/pull/599)
* [Use phenotypes from cpic](https://github.com/hpi-dhc/PharMe/pull/602)
