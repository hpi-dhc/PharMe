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

Run `python analyze.py <PATH_TO_BACKUP> [--correct]` to analyze annotations
and optionally correct what can be corrected easily in
`<PATH_TO_BACKUP>_corrected_<TIMESTAMP>.base64.json`.

Also checks which bricks are not used in guidelines.

### Drug annotation checks

| Check | Description | `--correct`ed | Only for single-gene results* |
| ----- | ----------- | ------------- | ----------------------------- |
| `brand_whitespace` | Drug brand names should not have leading or trailing white space. | ✅ | ❌ |
| `brand_comma` | Drug brand names should not include commas (spit these, could do automatically). | ❌ | ❌ |
| `single_any_fallback` | If any fallback guidelines `*` are present, only one guideline should be present (otherwise other guidelines are ignored) | ❌ | ❌ |
| `fallback_single_lookup` | If fallback guidelines `*` or `~` are present, only one lookup value per gene should be present (otherwise other lookup values are ignored) | ❌ | ❌ |
| `annotated_but_not_staged` | Warns if a drug is annotated but not staged (ignored drugs in `IGNORE_STAGED_CHECK`) | ❌ | ❌ |

### Guideline annotation checks

| Check | Description | `--correct`ed | Only for single-gene results* |
| ----- | ----------- | ------------- | ----------------------------- |
| `has_consult` | Is "consult your pharmacist..." included in recommendation? | ✅ | ❌ |
| `check_metabolization_severity` | "Much" keyword, should only be used if reflected by guideline implication. | ❌ | ✅ |
| `red_warning` | Red warning level should be present with recommendation containing "may not be the right medication". | ❌ | ❌ |
| `yellow_warning` | Yellow warning level should be present when the red warning level does not apply but the implication contains "may not work" or "side effects" or the recommendation contains non-standard dose. | ❌ | ❌ |
| `green_warning` | Green warning level should be applied in all non-red and non-yellow cases and when the recommendation states "at standard dose" or similar formulations. | ❌ | ❌ |
| `none_warning` | None warning level should be applied in all not handled warning level cases. | ❌ | ❌ |
| `metabolization_before_consequence` | Metabolization implications should come before consequences. | ❌ | ❌ |
| `annotated_but_not_staged` | Warns if a guideline is annotated but not staged (ignored drugs in `IGNORE_STAGED_CHECK`) | ❌ | ❌ |
| `should_not_have_normal_risk` | Warns if an annotation uses "normal risk" if not mentioned in external data. | ❌ | ❌ |
| `non_metabolizer` | Warns if an annotation uses "break down" or "activate" but is for `NON_METABOLIZERS`. | ❌ | ❌ |
| `slow_titration` | If otherwise standard dose, "slow titration" and "cautiously and slowly" should be used together. | ❌ | ❌ |

\* Skips guidelines with multiple genes unless all results but one are missing
or indeterminate.
