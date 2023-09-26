# App Behavior in Case of Missing Data

Missing in PharMe can occur when there is a mismatch between genes or
diplotypes in the lab report, in the annotations, or in CPIC lookups.

Lookups are fetched from CPIC and matched with users' diplotypes from the lab.
They are used to map from lab report to annotations (see [data examples](#data-examples).

## Cases

Specific cases that can occur are:

| # | Case | Example (see [test data](#test-data-for-cases-above)) | Handling |
| - | ---- | ----------------------------------------------------- | -------- |
| 1 | A gene in the lab report is not included in CPIC lookups | APOE | Gene is ignored |
| 2 | A gene in the lab report is included in CPIC lookups, but the diplotype is not | CYP2C19 \*1/\*101 | This will be handled manually when pre-processing the data |
| 3 | A gene in the annotations is not included in CPIC lookups | NAT2 | This should also not happen, should adapt FDA crawler to skip such occurrences for now and remove from Anni; such cases will not be included in the lab report (as far as we know) |
| 4 | A gene in the annotations is included in CPIC lookups, but lookup value (phenotype or activity score) is not | Not really present | See case 3 |
| 5 | A gene in annotations (with known lookups) is not included in lab report | CYP2C9 | Currently, the gene is not shown; however, it should be shown with "not tested" |

The following table collects which screens are affected by which cases (that
can actually happen).

| Case | Gene report | Gene detail | Drug search | Drug detail |
| ---- | ----------- | ----------- | ----------- | ----------- |
| 1 | ✅ (not shown) | – | – | – |
| 5 | ⚠️ (need to implement showing as "not tested") | ❓ (need to test whether gene detail shows not tested and drug list correctly) | ❓ (need to test whether warning level is set correctly ["no recommendation", if only gene]) | ❓ (see drug search and need to test whether phenotype shows "no result" or "not tested") |

What happens if cases 2 to 4 are not caught in beforehand: the user will see
the phenotype assigned by the lab and the "no recommendation can be made"
message because internally the phenotype is "indeterminate"; this can be a bit
unfortunate if guidelines exists for the phenotype but the lookup is missing.

## TODOs

* Show all genes present in annotations in gene report and potentially adapt
  gene detail page accordingly
  ([#665](https://github.com/hpi-dhc/PharMe/issues/665))
* Test whether "no result" shows correctly on drug search and drug detail pages
  ➡️ *TODO: test and describe, maybe create ticket, if not working as expected*
* Handle lookup mismatches in lab data in pre-processing
  ([#657](https://github.com/hpi-dhc/PharMe/issues/657))
* Handle lookup mismatches in annotation data in crawler script
  ([#8](https://github.com/hpi-dhc/PharMe-Annotations/issues/8))
* Make tag in annotations repository for version with unknown lookups; then
  update with version from adapted script
  ([Monday](https://hpims-ddp.monday.com/boards/3758456899/pulses/5224289413))
* Catch in app if lookup could not be found and send error log to backend
  ([Monday](https://hpims-ddp.monday.com/boards/3758456899/pulses/5224304039))

## Data Examples

| Description | Screenshot |
| ----------- | ------------ |
| Diplotypes list  | <img width="564" alt="diplotypes_list" src="https://github.com/hpi-dhc/PharMe/assets/7488660/1e4bfb4e-a06c-46ec-a58b-240a36735406"> |
| Lookups list (matched) | <img width="564" alt="matched_lookups" src="https://github.com/hpi-dhc/PharMe/assets/7488660/5f9a2beb-7642-4d17-930c-c47d6fc45266"> |
| Single diplotype | <img width="458" alt="diplotype" src="https://github.com/hpi-dhc/PharMe/assets/7488660/27ae08c9-f9ee-405d-b838-7a4e3a9461dc"> |
| Single lookup | <img width="307" alt="lookup" src="https://github.com/hpi-dhc/PharMe/assets/7488660/ee8586c4-9c7c-4b1d-bada-17b721b374b6"> |

## Test Data for Cases Above

See the example below. User is `test-missing` (Sinai backend) or `unknown-genes` (HPI backend), password `1234`.

* `CYP2D6`: all good, gene known, diplotype known
* `CYP2C19`: gene known, diplotype unknown (second star allele made up)
* `APOE`: gene not known (also, no guideline in Anni)
* `NAT2`: gene not known (but guideline in Anni; should be no difference to
  no guideline in Anni, but for testing)

```json
{
    "diplotypes": [
        {
            "gene": "CYP2D6",
            "resultType": "Diplotype",
            "genotype": "*1/*17",
            "phenotype": "Normal Metabolizer",
            "allelesTested": "*xN.*3.*4.*5.*6.*8.*9.*10.*14A.*14B.*17.*41"
        },
        {
            "gene": "CYP2C19",
            "resultType": "Diplotype",
            "genotype": "*1/*101",
            "phenotype": "Intermediate Metabolizer",
            "allelesTested": "*2.*3.*4A.*4B.*5.*6.*8.*9.*10.*17.*101"
        },
        {
            "gene": "APOE",
            "resultType": "Diplotype",
            "genotype": "ε3/ε3",
            "phenotype": "Normal APOE function",
            "allelesTested": "ε4"
        },
        {
            "gene": "NAT2",
            "resultType": "Diplotype",
            "genotype": "*6/*6",
            "phenotype": "Poor Metabolizer",
            "allelesTested": "*6"
        },
    ]
}
```
