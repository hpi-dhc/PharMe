# App Behavior When Lookups Are Unknown to CPIC

Lookups are fetched from CPIC and matched with users' diplotypes from the lab.
Sometimes, genes or diplotypes might be unknown.

This page collects the app's current and desired behavoir in such cases for
further discussion, as of August 28, 2023.

## App Behavior

| Page | Case | Desired behavior | Current behavior |
| ----- | ----- | ----------------- | ----------------- |
| Gene report | Unknown gene | Not shown in gene results |  |
| Gene report | Unknown diplotype | | |
| Gene detail | Unknown diplotype | | |
| Drug search | _TODO_ | | |
| Drug detail | _TODO_ | | |

_TODO for drug pages: how are guidelines matched? What happens for multiple
genes, especially if one is missing?_

## Data examples

| Description | Screenshot |
| ----------- | ------------ |
| Diplotypes list  | <img width="564" alt="diplotypes_list" src="https://github.com/hpi-dhc/PharMe/assets/7488660/1e4bfb4e-a06c-46ec-a58b-240a36735406"> |
| Lookups list (matched) | <img width="564" alt="matched_lookups" src="https://github.com/hpi-dhc/PharMe/assets/7488660/5f9a2beb-7642-4d17-930c-c47d6fc45266"> |
| Single diplotype | <img width="458" alt="diplotype" src="https://github.com/hpi-dhc/PharMe/assets/7488660/27ae08c9-f9ee-405d-b838-7a4e3a9461dc"> |
| Single lookup | <img width="307" alt="lookup" src="https://github.com/hpi-dhc/PharMe/assets/7488660/ee8586c4-9c7c-4b1d-bada-17b721b374b6"> |
