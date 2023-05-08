from common.get_data import get_data
from common.get_data import get_guidelines_by_ids
from common.constants import DRUG_COLLECTION_NAME
from common.constants import GUIDELINE_COLLECTION_NAME
from common.constants import SCRIPT_POSTFIXES
from common.remove_history import remove_history
from common.write_data import write_data
from common.write_data import get_output_file_path

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
    log_content = ['# Update Log\n\n']

    # Add new drugs and update present drugs
    present_drugs = {}
    for drug in data[DRUG_COLLECTION_NAME]:
        present_drugs[drug['name']] = drug
    for drug in updated_external_data[DRUG_COLLECTION_NAME]:
        drug_name = drug['name']
        drug_guidelines = get_guidelines_by_ids(
            updated_external_data, drug['guidelines'])
        log_string = f'* {drug_name}: '
        if not drug_name in present_drugs:
            data[DRUG_COLLECTION_NAME].append(drug)
            data[GUIDELINE_COLLECTION_NAME] += drug_guidelines
            log_string += 'not present; added drug with ' \
                f'{len(drug_guidelines)} empty annotation(s)'
            log_content.append(f'{log_string}\n')
        else:
            update_log = []
            present_drug = present_drugs[drug_name]

            # Test if RxNorm changed
            present_rxNorm = present_drug['rxNorm']
            rxNorm = drug['rxNorm']
            if present_rxNorm != rxNorm:
                update_log.append(f'* Change RxNorm from {present_rxNorm} ' \
                                  f'to {rxNorm}\n')
                present_drug['rxNorm'] = drug['rxNorm']

            # TODO: Check guidelines for updates; key should be phenotype
            present_guidelines = get_guidelines_by_ids(
                data, present_drug['guidelines'])

            # Write update log
            if len(update_log) == 0:
                log_string += 'no updates'
            else:
                log_string += 'updated:'
            log_content.append(f'{log_string}\n')
            log_content += update_log

    # Check for deleted drugs
    updated_drug_name_list = list(map(
        lambda drug: drug['name'],
        updated_external_data[DRUG_COLLECTION_NAME]
    ))
    for index, drug in enumerate(data[DRUG_COLLECTION_NAME]):
        drug_name = drug['name']
        if not drug_name in updated_drug_name_list:
            del data[DRUG_COLLECTION_NAME][index]
            log_content.append(f'* {drug_name}: removing drug, as not ' \
                           'present in updated data\n')

    write_data(data, postfix=SCRIPT_POSTFIXES['update'])
    write_log(log_content)

if __name__ == '__main__':
    update_data()