# App Behavior When Lookups Are Unknown to CPIC

Lookups are fetched from CPIC and matched with users' diplotypes from the lab.
Sometimes, genes or diplotypes might be unknown.

This page collects the app's current and desired behavoir in such cases for
further discussion, as of August 28, 2023.

**Baseline: this should not happen, we will test the lab results before, but**
**need to define what happens especially if missing genotype.**

## App Behavior

**Biggest question: should we overwrite (known) lab phenotypes with**
**Indeterminate? We will not be able to map to CPIC guidelines currently**

**Also test: can we get different annotations for "Indeterminate" vs.**
**"No Result" in app?**

☑️ TODO: split up cases by examples

| Page | Case | Desired behavior | Current behavior | TODO |
| ---- | --- | ----------------- | ---------------- | ---- |
| Gene report | Gene in lab results not in lookups (e.g., APOE) | Not shown in gene results | ✅ | – |
| Gene report | Gene in lookups not in lab results | Not shown in gene results | ✅ | – |
| Gene report | Unknown diplotype | Shown in results with "Indeterminate" phenotype | Not shown in gene results | (1) Show known genes with unknown diplotype as Indeterminate; (2) Overwrite lab phenotype as "Indeterminate" if CPIC lookup not present |
| Gene detail | Unknown diplotype | As in report, diplotype shown; drugs with guidelines only for this gene should map to "Indeterminate" status | Not shown in gene results, so not getting here | Fix (1) in report and come back here; will probably need to overwrite lab phenotype with "Indeterminate", might be directly fixed by (2) |
| Drug search | Unknown gene (only guideline gene) | Not sure if it makes sense to publish such guidelines we cannot show; if there, should show "Indeterminate" status | Warning shown in script that maps FDA guidenlines to CPIC lookups; "Amifampridrine" currently staged and shown, showing as "Indeterminate" (but will probably be removed, as NAT2 not inclued in new test) | – |
| Drug search | Unknown or missing diplotype | Should show "Unknown" status | ✅ | – |
| Drug search | Unknown or missing diplotype (multiple guideline genes) | Should show status based on guideline for present gene (or "Unknown", if all are not known) | **Cannot test currently, as no such guidelines; test indeterminate and missing** | ? |
| Drug detail | Unknown or missing gene (only guideline gene) | Guideline should be shown as "Unknown"; if unknown, maybe instead of gene, "no guidelines present" should be shown; if missing, this should be shown | Guideline is "Indeterminate", phenotype is not; need to test for missing | See (2); maybe shown "no guidelines present" |
| Drug detail | Unknown diplotype | Guideline and phenotype should be shown as "Indeterminate" | Guideline is "Indeterminate", phenotype is not | See (2) |
| Drug detail | Unknown or missing gene or diplotype (multiple guideline genes) | See drug search; if unknown gene, hide in "your genome"; if missing, this should be shown | **Cannot test currently, as no such guidelines; test indeterminate and missing** | ?; probably will need to hide unknown gene and overwrite unknown diplotype phenotype |

## Data Examples

| Description | Screenshot |
| ----------- | ------------ |
| Diplotypes list  | <img width="564" alt="diplotypes_list" src="https://github.com/hpi-dhc/PharMe/assets/7488660/1e4bfb4e-a06c-46ec-a58b-240a36735406"> |
| Lookups list (matched) | <img width="564" alt="matched_lookups" src="https://github.com/hpi-dhc/PharMe/assets/7488660/5f9a2beb-7642-4d17-930c-c47d6fc45266"> |
| Single diplotype | <img width="458" alt="diplotype" src="https://github.com/hpi-dhc/PharMe/assets/7488660/27ae08c9-f9ee-405d-b838-7a4e3a9461dc"> |
| Single lookup | <img width="307" alt="lookup" src="https://github.com/hpi-dhc/PharMe/assets/7488660/ee8586c4-9c7c-4b1d-bada-17b721b374b6"> |

## Test Data for Cases Above

See the example below. User is `???`, password `1234`.

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
