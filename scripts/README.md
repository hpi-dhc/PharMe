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

As input, Anni backup data is assumed, either (1) in JSON format, or (2) as a
JSON response with Base64 text containing the zipped JSON (depending on the
script).

Tests can be executed by running `pytest`.

## Update external data

Run `python update.py <PATH_TO_OLD_BACKUP>.base64.json
<PATH_TO_RECENTLY_INITIALIZED_BACKUP>.base64.json` to receive
`<PATH_TO_OLD_BACKUP>_updated_<TIMESTAMP>.base64.json` and
`<PATH_TO_OLD_BACKUP>_updated_<TIMESTAMP>_log.md`.

The script will update external data of the old backup based on the recently
initialized external data and describe updates in the log.

## Reset data

Sometimes updates get too large to upload again, then it helps to reset the data
by deleting the history data and published data.

Run `python reset.py <PATH_TO_BACKUP>.base64.json` to receive
`<PATH_TO_BACKUP>_reset_<TIMESTAMP>.base64.json`.

## Unstage data

This is probably a use case only relevant once, we want to unstage all data and
do a second review.

Run `python unstage.py <PATH_TO_BACKUP>.base64.json` to receive
`<PATH_TO_BACKUP>_reset_<TIMESTAMP>.base64.json`.

## Migrate data

Run `python migrate.py <PATH_TO_BACKUP>[.json|.base64.json]` to receive
`<PATH_TO_BACKUP>_migrated_<TIMESTAMP>.base64.json`.

**⚠️ Migrating data will remove the data history, including
published versions!**

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

Run `python decode.py <PATH_TO_BACKUP>.base64.json` to receive
`<PATH_TO_BACKUP>_decoded_<TIMESTAMP>.json`.

## Encode Base64

Run `python encode.py <PATH_TO_BACKUP>.json` to receive
`<PATH_TO_BACKUP>_encoded_<TIMESTAMP>.base64.json`.

## Clean script outputs

Run `python clean.py` to remove the `scripts/temp` directory and all files in
`scripts/` containing a postfix defined in `SCRIPT_POSTFIXES` (see
`common.constants`).

## Analyze (and correct) annotations

Run `python analyze.py <PATH_TO_BACKUP> [--correct]` to analyze annotations and
optionally correct what can be corrected easily in
`<PATH_TO_BACKUP>_corrected_<TIMESTAMP>.base64.json`.

| Check | Description | `--correct`ed | Only for single-gene results* |
| ----- | ----------- | ------------- | ----------------------------- |
| `has_consult` | Is "consult your pharmacist..." included in recommendation? | ✅ | ❌ |
| `implication_severity` | Poor/ultrarapid phenotypes with "faster" or "slower" implication should have "much" keyword, intermediate/rapid not. | ❌ | ✅ |
| `red_warning` | Red warning level should always have recommendation "may not be the right medication" and vice versa. | ❌ | ❌ |
| `yellow_warning` | Recommendation containing "adjusted" or "higher" or "lower" but not "may not be the right" should have yellow warning level. | ❌ | ❌ |
| `green_warning` | Green warning level should have recommendation "at standard dose" but not "adjusted" and vise versa. | ❌ | ❌ |
| `brand_whitespace` | Drug brand names should not have leading or trailing white space. | ✅ | ❌ |

\* Skips guidelines with multiple genes unless all results but one are missing
or indeterminate.
