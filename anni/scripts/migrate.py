from common.get_data import get_data
from common.write_data import write_data
from common.constants import SCRIPT_POSTFIXES
from common.cpic_data import get_phenotype_map

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

# Do not contract different phenotypes (#604)
def split_phenotypes(guidelines):
    # TODO: split up and copy guidelines per phenotype (combination)
    return guidelines

# Chain guideline migrations together
def migrate_guideline(guideline, phenotype_map):
    return split_phenotypes(
        add_phenotypes(
            enlist_external_data(rename_external_data(guideline)),
            phenotype_map))

# Migrate data
def migrate_data():
    data = get_data()
    phenotype_map = get_phenotype_map()

    # Iterate data for migration of content
    for table_name in data.keys():
        table_content = data[table_name]
        if table_name.startswith('AppData'):
            for row in table_content:
                drugs = row['drugs']
                for drug in drugs:
                    guidelines = drug['guidelines']
                    for guideline in guidelines:
                        guideline = migrate_guideline(guideline, phenotype_map)
                    guidelines = split_phenotypes(guidelines)
        if table_name.startswith('Guideline'):
            for guideline in table_content:
                guideline = migrate_guideline(guideline, phenotype_map)
            table_content = split_phenotypes(table_content)

    write_data(data, postfix=SCRIPT_POSTFIXES['migrate'])

if __name__ == '__main__':
    migrate_data()