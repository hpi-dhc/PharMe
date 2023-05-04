from common.get_data import get_data
from common.write_data import write_data
from common.constants import SCRIPT_POSTFIXES
from common.cpic_data import get_phenotype_map
from common.remove_history import remove_history
from common.get_data import get_guideline_by_id

# Rename `cpicData` in guidelines to `externalData` (#582)
# Add `source` field to `externalData` with value 'CPIC' (#582)
def rename_external_data(guideline):
    old_key = 'cpicData'
    new_key = 'externalData'
    if old_key in guideline:
        guideline[new_key] = guideline.pop(old_key)
        guideline[new_key]['source'] = 'CPIC'
    return guideline

# Change `externalData` to array (#597)
def enlist_external_data(guideline):
    if type(guideline['externalData']) is not list:
        guideline['externalData'] = [guideline['externalData']]
    return guideline

# Add phenotypes for guideline (#602)
def add_phenotypes(guideline, phenotype_map):
    if not 'phenotypes' in guideline:
        phenotypes = {}
        for gene_symbol, gene_results in guideline['lookupkey'].items():
            phenotypes[gene_symbol] = []
            for gene_result in gene_results:
                phenotype = phenotype_map[gene_symbol][gene_result]
                phenotypes[gene_symbol].append(phenotype)
        guideline['phenotypes'] = phenotypes
    return guideline

# Chain guideline migrations together
def migrate_guideline(guideline, phenotype_map):
    return add_phenotypes(
        enlist_external_data(rename_external_data(guideline)),
        phenotype_map)

# Contract external data by phenotypes (#597)
# Split up previously contracted phenotypes (#604)
def contract_phenotypes_per_drug(guidelines, phenotype_map):
    for guideline in guidelines:
        # Test if all phenotype and lookupkey values have the same length
        phenotype_values = list(guideline['lookupkey'].values()) + \
            list(guideline['phenotypes'].values())
        phenotype_values_lengths = set(map(len, phenotype_values))
        if len(phenotype_values_lengths) != 1:
            raise Exception('[ERROR] Expecting lookupkey and phenotypes per ' \
                            'gene to have same lenghts but lengths differ ' \
                            'for guideline {}'.format(guideline['_id']))
        # TODO: Split up by phenotypes
        # TODO: Contract by phenotypes
    return list(guidelines)

# Migrate data
def migrate_data():
    data = remove_history(get_data())
    phenotype_map = get_phenotype_map()

    # Iterate data for migration of single guidelines and contract guidelines
    # per drug afterwards (needs phenotypes)
    for guideline in data['Guideline']:
        guideline = migrate_guideline(guideline, phenotype_map)
    migrated_guidelines = []
    for drug in data['Drug']:
        migrated_guidelines.append(contract_phenotypes_per_drug(
            map(
                lambda id: get_guideline_by_id(data, id),
                drug['guidelines']),
            phenotype_map))
    data['Guideline'] = migrated_guidelines

    if 'AppData' in data:
        for row in data['AppData']:
            for drug in row['drugs']:
                guidelines = drug['guidelines']
                for guideline in guidelines:
                    guideline = migrate_guideline(guideline, phenotype_map)
                guidelines = contract_phenotypes_per_drug(
                    guidelines, phenotype_map)

    write_data(data, postfix=SCRIPT_POSTFIXES['migrate'])

if __name__ == '__main__':
    migrate_data()