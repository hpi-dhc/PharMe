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
    present_drugs = list(map(
        lambda drug: drug['name'], data[DRUG_COLLECTION_NAME]))
    for drug in updated_external_data[DRUG_COLLECTION_NAME]:
        drug_name = drug['name']
        log_string = f'* {drug_name}: '
        if not drug_name in present_drugs:
            data[DRUG_COLLECTION_NAME].append(drug)
            drug_guidelines = get_guidelines_by_ids(
                updated_external_data, drug['guidelines'])
            data[GUIDELINE_COLLECTION_NAME] += drug_guidelines
            log_string += 'not present; added drug with ' \
                f'{len(drug_guidelines)} empty annotation(s)'
        else:
            log_string += 'present; NOT IMPLEMENTED: check for updates'
        log_content.append(f'{log_string}\n')
    write_data(data, postfix=SCRIPT_POSTFIXES['update'])
    write_log(log_content)

if __name__ == '__main__':
    update_data()