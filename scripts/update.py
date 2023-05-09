from common.get_data import get_data
from common.get_data import get_guidelines_by_ids
from common.get_data import get_phenotype_key
from common.constants import DRUG_COLLECTION_NAME
from common.constants import GUIDELINE_COLLECTION_NAME
from common.constants import SCRIPT_POSTFIXES
from common.remove_history import remove_history
from common.write_data import write_data
from common.write_data import get_output_file_path

def get_drug_names(data):
    return list(map(
        lambda drug: drug['name'],
        data[DRUG_COLLECTION_NAME]
    ))

def log_item(text, level = 0):
    prefix = '  ' * level
    return f'{prefix}* {text}\n'

def remove_by_id(data, collection_name, item_ids):
    data[collection_name] = list(filter(
        lambda item: item['_id'] not in item_ids,
        data[collection_name]
    ))
    return data

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
    data = remove_by_id(data, DRUG_COLLECTION_NAME, stale_drug_ids)
    data = remove_by_id(data, GUIDELINE_COLLECTION_NAME, stale_guideline_ids)
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

def remove_outdated_guidelines(guidelines, updated_guidelines):
    remove_log = []
    # updated_guideline_map = {}
    # for updated_guideline in updated_guidelines:
    #     phenotype_key = get_phenotype_key(updated_guideline)
    #     if not phenotype_key in updated_guideline_map:
    #         updated_guideline_map[phenotype_key] = []
    #     for externalData in updated_guideline['externalData']:
    #         recommendation_id = externalData['recommendationId']
    #         updated_guideline_map[phenotype_key].append(recommendation_id)
    print('TODO: remove guidelines')
    # TODO: remove phenotype or exteral data
    return guidelines, remove_log

def update_guidelines(guidelines, updated_guidelines):
    update_log = []
    print('TODO: update guidelines')
    return guidelines, update_log

def add_missing_guidelines(guidelines, updated_guidelines):
    add_log = []
    print('TODO: add guidelines')
    return guidelines, add_log

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
        updated_drug = updated_drugs_map[drug_name]
        drug_updates = []

        # Test if RxNorm changed
        current_rxNorm = current_drug['rxNorm']
        updated_rxNorm = updated_drug['rxNorm']
        if current_rxNorm != updated_rxNorm:
            current_drug['rxNorm'] = updated_drug['rxNorm']
            drug_updates.append(log_item(
                f'Change RxNorm from {current_rxNorm} to {updated_rxNorm}',
                level=1
            ))

        # Test if guidelines changed
        current_guidelines = get_guidelines_by_ids(
            data, current_drug['guidelines'])
        updated_guidelines = get_guidelines_by_ids(
            data, current_drug['guidelines'])
        drug_updates += \
            remove_outdated_guidelines(current_guidelines, updated_guidelines)
        drug_updates += \
            update_guidelines(current_guidelines, updated_guidelines)
        drug_updates += \
            add_missing_guidelines(current_guidelines, updated_guidelines)

        if len(drug_updates) != 0:
            update_log.append(log_item(drug_name))
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
    data = remove_history(get_data())
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