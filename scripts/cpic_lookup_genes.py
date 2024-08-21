import json
import requests

cpicLookupUrl = "https://api.cpicpgx.org/v1/diplotype"

print('CPIC genes:')
response = requests.get(f'{cpicLookupUrl}?select=genesymbol')
cpicLookups = response.json()
genes = set()
for lookup in cpicLookups:
    genes.add(lookup['genesymbol'])
for gene in genes:
    print(gene)

print('')
print('Covered alleles per gene:')
for gene in genes:
    alleles = set()
    response = requests.get(f'{cpicLookupUrl}?select=diplotype&genesymbol=eq.{gene}')
    results = response.json()
    for result in results:
        diplotype = result['diplotype']
        for allele in diplotype.split('/'):
            alleles.add(allele.strip())
    print(f'{gene}: {";".join(alleles)}')
