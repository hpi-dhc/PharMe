# Anni Data Scripts

These scripts can be used to work on data backups.
The scripts require `python3` to be installed.

As input, Anni backup data is assumed, either in JSON format, or Base64 format
containing a zipped JSON.

## Migrate data

Run `pyhthon3 migrate.py <PATH_TO_BACKUP>[.json|.base64]` to receive
`<PATH_TO_BACKUP>_migrated_<TIMESTAMP>.base64`.

**⚠️ Migrating data will remove the data history!**

(Breaking) changes covered:

* [Add new medications (FDA)](https://github.com/hpi-dhc/PharMe/pull/582)
* [One annotation per phenotype](https://github.com/hpi-dhc/PharMe/pull/597)
* [Zipped Anni backup](https://github.com/hpi-dhc/PharMe/pull/599)
* [Use phenotypes from cpic](https://github.com/hpi-dhc/PharMe/pull/602)
* [Contract by phenotype first](https://github.com/hpi-dhc/PharMe/pull/604)

## Decode Base64

Run `python3 decode.py <PATH_TO_BACKUP>.base64` to receive
`<PATH_TO_BACKUP>_decoded_<TIMESTAMP>.json`.

## Clean script outputs

Run `python3 clean.py` to remove the `scripts/temp` directory and all files in
`scripts/` containing a postfix defined in `SCRIPT_POSTFIXES` (see
`common.constants`).
