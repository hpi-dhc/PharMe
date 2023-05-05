from common.get_data import get_data, get_information_key, get_guideline_by_id, \
    get_phenotype_value_lengths, get_phenotype_value, get_phenotype_key
from common.write_data import write_data
from common.constants import SCRIPT_POSTFIXES
from common.cpic_data import get_phenotype_map
from common.remove_history import remove_history
from common.mongo import get_object_id

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

# Chain single guideline migrations together
def migrate_guideline(guideline, phenotype_map):
    return add_phenotypes(
        enlist_external_data(rename_external_data(guideline)),
        phenotype_map)

# Migrate single guidelines; then split up by lookupkeys and re-contract by
# phenotype and external information (according to #597 and #604)
def migrate_drug_guidelines(guidelines, phenotype_map):
    phenotype_guideline_map = {}
    for guideline in guidelines:
        guideline = migrate_guideline(guideline, phenotype_map)
        contracted_guideline_number = get_phenotype_value_lengths(
            guideline, expect_same_length=True)
        for phenotype_index in range(0, contracted_guideline_number):
            decontracted_guideline = guideline.copy()
            del decontracted_guideline['_id']
            decontracted_guideline['lookupkey'] = get_phenotype_value(
                guideline['lookupkey'], phenotype_index)
            decontracted_guideline['phenotypes'] = get_phenotype_value(
                guideline['phenotypes'], phenotype_index)
            # Contraction is implemented analogous to Anni
            # (see cpic-constructors.ts)
            phenotype_key = get_phenotype_key(decontracted_guideline)
            information_key = get_information_key(decontracted_guideline)
            if not phenotype_key in phenotype_guideline_map:
                phenotype_guideline_map[phenotype_key] = {}
            phenotype_guidelines = phenotype_guideline_map[phenotype_key]
            if not information_key in phenotype_guidelines:
                phenotype_guidelines[information_key] = []
            phenotype_guidelines[information_key].append(decontracted_guideline)
    # Re-contracted guidelines and assign new IDs
    recontracted_guidelines = []
    for phenotype_guidelines in phenotype_guideline_map.values():
        # TODO: Contract lookupkeys per phenotype
        # TODO: Contract unique external data per phenotype
        print(phenotype_guidelines.values())
        print('')

    return recontracted_guidelines

# Migrate data
def migrate_data():
    data = remove_history(get_data())
    phenotype_map = get_phenotype_map()

    # If phenotypes are not present initially (data was created before #602),
    # assume that guidelines also need to be contracted by phenotypes (#604)
    contract_by_phenotypes = not 'phenotypes' in data['Guideline'][0]

    # Iterate data for migration of single guidelines and contract guidelines
    # per drug afterwards (needs phenotypes)

    if contract_by_phenotypes:
        migrated_guidelines = []
        for drug in data['Drug']:
            drug_guidelines = list(map(
                lambda id: get_guideline_by_id(data, id),
                drug['guidelines']))
            migrated_drug_guidelines = migrate_drug_guidelines(
                drug_guidelines, phenotype_map)
            migrated_guidelines += migrated_drug_guidelines
            drug['guidelines'] = list(map(
                lambda guideline: guideline['_id'],
                migrated_drug_guidelines
            ))
        data['Guideline'] = migrated_guidelines

    write_data(data, postfix=SCRIPT_POSTFIXES['migrate'])

if __name__ == '__main__':
    migrate_data()