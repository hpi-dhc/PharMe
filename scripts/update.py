import copy

from common.get_data import get_data
from common.get_data import get_guidelines_by_ids
from common.get_data import get_phenotype_key
from common.mongo import get_timestamp
from common.constants import DRUG_COLLECTION_NAME
from common.constants import DRUG_HISTORY_COLLECTION_NAME
from common.constants import GUIDELINE_COLLECTION_NAME
from common.constants import GUIDELINE_HISTORY_COLLECTION_NAME
from common.constants import get_history_collection_name
from common.constants import SCRIPT_POSTFIXES
from common.remove_history import remove_history
from common.write_data import write_data
from common.write_data import get_output_file_path

VERBOSE = False

def get_drug_names(data):
    return list(map(
        lambda drug: drug['name'],
        data[DRUG_COLLECTION_NAME]
    ))

def log_item(text, level = 0):
    prefix = '  ' * level
    text = f'{prefix}* {text}'
    if VERBOSE:
        print(text)
    return f'{text}\n'

def remove_from_collection(data, collection_name, item_ids):
    history_collection_name = get_history_collection_name(collection_name)
    data[history_collection_name] += list(filter(
        lambda item: item['_id'] in item_ids,
        data[collection_name]
    ))
    data[collection_name] = list(filter(
        lambda item: item['_id'] not in item_ids,
        data[collection_name]
    ))
    return data

def update_version(data, collection_name, item):
    data[get_history_collection_name(collection_name)].append(
        copy.deepcopy(item)
    )
    item['_v'] += 1
    item['_vDate'] = get_timestamp()

# As each recommendation returned by the CPIC API holds a drugId, we assume
# here that drugs and guidelines have a 1 to n relationship, i.e., one guideline
# is only referenced by one drug and can be removed when the drug is removed
def remove_outdated_drugs(data, updated_external_data):
    remove_log = []
    stale_drug_ids = []
    stale_guideline_ids = []
    updated_drug_name_list = get_drug_names(updated_external_data)
    for drug in data[DRUG_COLLECTION_NAME]:
        drug_name = drug['name']
        if not drug_name in updated_drug_name_list:
            stale_drug_ids.append(drug['_id'])
            drug_guidelines = drug['guidelines']
            stale_guideline_ids += drug_guidelines
            remove_log.append(log_item(
                f'{drug_name} ({len(drug_guidelines)} guidelines)'))
    data = remove_from_collection(data, DRUG_COLLECTION_NAME, stale_drug_ids)
    data = remove_from_collection(
        data, GUIDELINE_COLLECTION_NAME, stale_guideline_ids)
    return data, remove_log

def add_missing_drugs(data, updated_external_data):
    add_log = []
    present_drug_name_list = get_drug_names(data)
    for drug in updated_external_data[DRUG_COLLECTION_NAME]:
        drug_name = drug['name']
        if not drug_name in present_drug_name_list:
            drug_guidelines = get_guidelines_by_ids(
                updated_external_data, drug['guidelines'])
            data[DRUG_COLLECTION_NAME].append(drug)
            data[GUIDELINE_COLLECTION_NAME] += drug_guidelines
            add_log.append(log_item(drug_name))
    return data, add_log

def get_guideline_phenotypes(guidelines):
    guideline_phenotypes = []
    for guideline in guidelines:
        phenotype_key = get_phenotype_key(guideline)
        if phenotype_key in guideline_phenotypes:
            raise Exception('Phenotypes should be unique per drug guideline!')
        guideline_phenotypes.append(phenotype_key)
    return guideline_phenotypes

def remove_outdated_guidelines(data, drug, guidelines, updated_guidelines):
    remove_log = []
    updated_guideline_phenotypes = get_guideline_phenotypes(updated_guidelines)
    stale_guidelines = list(filter(
        lambda guideline: get_phenotype_key(guideline) not in \
            updated_guideline_phenotypes,
        guidelines
    ))
    stale_guideline_ids = list(map(
        lambda guideline: guideline['_id'],
        stale_guidelines
    ))
    if len(stale_guidelines) > 0:
        data = remove_from_collection(
            data, GUIDELINE_COLLECTION_NAME, stale_guideline_ids)
        update_version(data, DRUG_COLLECTION_NAME, drug)
        drug['guidelines'] = list(filter(
            lambda guideline_id: guideline_id not in stale_guideline_ids,
            drug['guidelines']
        ))
        remove_log += list(map(
            lambda guideline: log_item(
                f'Removed guideline for {get_phenotype_key(guideline)}',
                level=1),
            stale_guidelines
        ))
    return remove_log

def update_guidelines(data, guidelines, updated_guidelines):
    update_log = []
    for guideline in guidelines:
        guideline_updates = []
        phenotype_key = get_phenotype_key(guideline)
        # To not be dependend on removal and addotion of guidelines
        updated_phenotypes = list(map(
            lambda guideline: get_phenotype_key(guideline),
            updated_guidelines))
        if not phenotype_key in updated_phenotypes:
            continue
        guideline_log_item = log_item(phenotype_key, level=1)
        updated_guideline = next(
            updated_guideline for updated_guideline in updated_guidelines \
                if get_phenotype_key(updated_guideline) == phenotype_key)
        # Test if lookupkey changed; only the list for each key can change,
        # everything else will be covered by removing or adding phenotype
        # guidelines
        lookupkey_key = get_phenotype_key(guideline, lookupkey=True)
        updated_lookupkey_key = get_phenotype_key(
            updated_guideline, lookupkey=True)
        if lookupkey_key != updated_lookupkey_key:
            update_version(data, GUIDELINE_COLLECTION_NAME, guideline)
            guideline['lookupkey'] = copy.deepcopy(
                updated_guideline['lookupkey'])
            update_log.append(log_item('Updated lookupkey', level=2))
        if len(guideline_updates) > 0:
            update_log.append(guideline_log_item)
            update_log += guideline_updates
        update_log.append(log_item('TODO: update exteral data', level=2))
    return update_log

def add_missing_guidelines(data, drug, guidelines, updated_guidelines):
    add_log = []
    present_guideline_phenotypes = get_guideline_phenotypes(guidelines)
    new_guidelines = list(filter(
        lambda guideline: get_phenotype_key(guideline) not in \
            present_guideline_phenotypes,
        updated_guidelines
    ))
    new_guideline_ids = list(map(
        lambda guideline: guideline['_id'],
        new_guidelines
    ))
    if len(new_guidelines) > 0:
        update_version(data, DRUG_COLLECTION_NAME, drug)
        drug['guidelines'] += new_guideline_ids
        data[GUIDELINE_COLLECTION_NAME] += new_guidelines
        add_log += list(map(
            lambda guideline: log_item(
                f'Added guideline for {get_phenotype_key(guideline)}',
                level=1),
            new_guidelines
        ))
    return add_log

def update_drugs(data, updated_external_data):
    update_log = []
    updated_drugs_map = {}
    for drug in updated_external_data[DRUG_COLLECTION_NAME]:
        updated_drugs_map[drug['name']] = drug
    for current_drug in data[DRUG_COLLECTION_NAME]:
        drug_name = current_drug['name']
        # To not be dependent on removal of outdated drugs before calling
        # update, check if drug present in updated drugs
        if not drug_name in updated_drugs_map:
            continue

        drug_log_item = log_item(drug_name)
        updated_drug = updated_drugs_map[drug_name]
        drug_updates = []

        # Test if RxNorm changed
        current_rxNorm = current_drug['rxNorm']
        updated_rxNorm = updated_drug['rxNorm']
        if current_rxNorm != updated_rxNorm:
            update_version(data, DRUG_COLLECTION_NAME, current_drug)
            current_drug['rxNorm'] = updated_drug['rxNorm']
            drug_updates.append(log_item(
                f'Changed RxNorm from {current_rxNorm} to {updated_rxNorm}',
                level=1
            ))

        # Update guidelines; changes are done in place
        current_guidelines = get_guidelines_by_ids(
            data, current_drug['guidelines'])
        updated_guidelines = get_guidelines_by_ids(
            updated_external_data, updated_drug['guidelines'])
        drug_updates += remove_outdated_guidelines(
            data, current_drug, current_guidelines, updated_guidelines)
        drug_updates += \
            update_guidelines(data, current_guidelines, updated_guidelines)
        drug_updates += add_missing_guidelines(
            data, current_drug, current_guidelines, updated_guidelines)

        if len(drug_updates) != 0:
            update_log.append(drug_log_item)
            update_log += drug_updates

    return data, update_log

def add_log_content(log_content, new_content):
    if len(new_content) == 0:
        log_content.append('_None_\n')
    else:
        log_content += new_content
    return log_content

def write_log(log_content):
    log_file_postfix = SCRIPT_POSTFIXES['update']+ '_log'
    log_file_ending = '.md'
    log_file_path = get_output_file_path(
        postfix=log_file_postfix,
        file_ending=log_file_ending)
    with open(log_file_path, 'w') as log_file:
        log_file.writelines(log_content)

def update_data():
    data = get_data()
    updated_external_data = get_data(argv_index = 2)
    log_content = ['# Update Log\n']

    data, remove_log = remove_outdated_drugs(data, updated_external_data)
    data, update_log = update_drugs(data, updated_external_data)
    data, add_log = add_missing_drugs(data, updated_external_data)

    log_content.append('\n## Added drugs\n\n')
    log_content = add_log_content(log_content, add_log)
    log_content.append('\n## Updated drugs\n\n')
    log_content = add_log_content(log_content, update_log)
    log_content.append('\n## Removed drugs\n\n')
    log_content = add_log_content(log_content, remove_log)

    write_data(data, postfix=SCRIPT_POSTFIXES['update'])
    write_log(log_content)

if __name__ == '__main__':
    update_data()