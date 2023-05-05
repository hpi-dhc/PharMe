import json
import urllib.request
import urllib.parse


def get_cpic_data(endpoint, params):
    base_url = 'https://api.cpicpgx.org/v1/'
    url = base_url + endpoint + '?' + urllib.parse.urlencode(params)
    with urllib.request.urlopen(url) as response:
        return json.loads(response.read())

def get_phenotype_map():
    # Would get gene but list of activity scores is not complete
    lookup_data = get_cpic_data('recommendation', params={
        'select': 'lookupkey,phenotypes',
    })
    phenotype_map = {}
    for result in lookup_data:
        for gene in result['lookupkey']:
            gene_result = result['lookupkey'][gene]
            phenotype = result['phenotypes'][gene] \
                if gene in result['phenotypes'] \
                else gene_result
            if not gene in phenotype_map:
                phenotype_map[gene] = {}
            if not gene_result in phenotype_map[gene]:
                phenotype_map[gene][gene_result] = phenotype
    return phenotype_map

