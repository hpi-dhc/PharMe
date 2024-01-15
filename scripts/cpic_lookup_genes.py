import json
import requests

cpicLookupUrl = "https://api.cpicpgx.org/v1/diplotype?select=genesymbol"
response = requests.get(cpicLookupUrl)
cpicLookups = response.json()
genes = set()
for lookup in cpicLookups:
    genes.add(lookup['genesymbol'])
for gene in genes:
    print(gene)
