import copy

from common.get_data import get_data
from common.get_data import get_information_key
from common.get_data import get_guidelines_by_ids
from common.get_data import get_phenotype_value_lengths
from common.get_data import get_phenotype_value
from common.get_data import get_phenotype_key
from common.write_data import write_data
from common.constants import DRUG_COLLECTION_NAME
from common.constants import GUIDELINE_COLLECTION_NAME
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
# phenotype and external information (according to #597 and #604). The
# contraction is implemented analogous to Anni (see cpic-constructors.ts)
def migrate_drug_guidelines(guidelines, phenotype_map):
    phenotype_guideline_map = {}
    for guideline in guidelines:
        guideline = migrate_guideline(guideline, phenotype_map)
        contracted_guideline_number = get_phenotype_value_lengths(
            guideline, expect_same_length=True)
        for phenotype_index in range(0, contracted_guideline_number):
            # Split guideline by lookupkeys (with regarding phenotypes)
            decontracted_guideline = copy.deepcopy(guideline)
            del decontracted_guideline['_id']
            decontracted_guideline['lookupkey'] = get_phenotype_value(
                guideline['lookupkey'], phenotype_index)
            decontracted_guideline['phenotypes'] = get_phenotype_value(
                guideline['phenotypes'], phenotype_index)
            # Contract guidelines by phenotype
            phenotype_key = get_phenotype_key(decontracted_guideline)
            if not phenotype_key in phenotype_guideline_map:
                phenotype_guideline_map[phenotype_key] = decontracted_guideline
            else:
                existing_guideline = phenotype_guideline_map[phenotype_key]
                # Lenth of exteral data and each gene field in lookupkey should
                # always be 1 as we just migrated it but just to be sure
                if len(decontracted_guideline['externalData']) != 1:
                    print(decontracted_guideline['externalData'])
                    raise Exception('[ERROR] Expecting externalData to be ' \
                                    'list with one element')
                for gene in decontracted_guideline['lookupkey']:
                    phenotype_value = decontracted_guideline['lookupkey'][gene]
                    if len(phenotype_value) != 1:
                        raise Exception('[ERROR] Expecting lookupkey values ' \
                                        'to be list with one element')
                existing_guideline['externalData'].append(
                    decontracted_guideline['externalData'][0])
                for gene in existing_guideline['lookupkey']:
                    existing_guideline['lookupkey'][gene].append(
                        decontracted_guideline['lookupkey'][gene][0])
    # Contract phenotype guidelines by information
    recontracted_guidelines = []
    for phenotype_guideline in phenotype_guideline_map.values():
        phenotype_guideline['_id'] = get_object_id()
        information_map = {}
        for external_data in phenotype_guideline['externalData']:
            information_key = get_information_key(external_data)
            if not information_key in information_map:
                information_map[information_key] = external_data
        phenotype_guideline['externalData'] = list(information_map.values())
        recontracted_guidelines.append(phenotype_guideline)
    return recontracted_guidelines

# Migrate data
def migrate_data():
    data = remove_history(get_data())
    phenotype_map = get_phenotype_map()

    # If phenotypes are not present initially (data was created before #602),
    # assume that guidelines also need to be contracted by phenotypes (#604)
    contract_by_phenotypes = not 'phenotypes' in \
        data[GUIDELINE_COLLECTION_NAME][0]

    # Iterate data for migration of single guidelines and contract guidelines
    # per drug afterwards (needs phenotypes)

    if contract_by_phenotypes:
        migrated_guidelines = []
        for drug in data[DRUG_COLLECTION_NAME]:
            drug_guidelines = get_guidelines_by_ids(data, drug['guidelines'])
            migrated_drug_guidelines = migrate_drug_guidelines(
                drug_guidelines, phenotype_map)
            migrated_guidelines += migrated_drug_guidelines
            drug['guidelines'] = list(map(
                lambda guideline: guideline['_id'],
                migrated_drug_guidelines
            ))
        data[GUIDELINE_COLLECTION_NAME] = migrated_guidelines

    write_data(data, postfix=SCRIPT_POSTFIXES['migrate'])

if __name__ == '__main__':
    migrate_data()