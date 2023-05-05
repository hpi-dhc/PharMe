# Anni Data Scripts

These scripts can be used to work on data backups.
The scripts require `python` (3.X) and the packages defined in
`requirements.txt` to be installed.

Setup with `venv` (recommended):

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

🗒️ _Note: for VS Code, you might need to set the Python interpreter for_
📜 _Scripts to the created `.venv`._

As input, Anni backup data is assumed, either in JSON format, or Base64 format
containing a zipped JSON.

## Migrate data

Run `pyhthon migrate.py <PATH_TO_BACKUP>[.json|.base64]` to receive
`<PATH_TO_BACKUP>_migrated_<TIMESTAMP>.base64`.

**⚠️ Migrating data will remove the data history, including published versions!**

(Breaking) changes covered:

* [Add new medications (FDA)](https://github.com/hpi-dhc/PharMe/pull/582)
* [One annotation per phenotype](https://github.com/hpi-dhc/PharMe/pull/597)
* [Zipped Anni backup](https://github.com/hpi-dhc/PharMe/pull/599)
* [Use phenotypes from cpic](https://github.com/hpi-dhc/PharMe/pull/602)
* [Contract by phenotype first](https://github.com/hpi-dhc/PharMe/pull/604)

🗒️ _Note: contraction by phenotype will not work for data initialized between
[Use phenotypes from cpic](https://github.com/hpi-dhc/PharMe/pull/602) and
[Contract by phenotype first](https://github.com/hpi-dhc/PharMe/pull/604)._

## Decode Base64

Run `python decode.py <PATH_TO_BACKUP>.base64` to receive
`<PATH_TO_BACKUP>_decoded_<TIMESTAMP>.json`.

## Clean script outputs

Run `python clean.py` to remove the `scripts/temp` directory and all files in
`scripts/` containing a postfix defined in `SCRIPT_POSTFIXES` (see
`common.constants`).
