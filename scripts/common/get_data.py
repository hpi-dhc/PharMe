import base64
import json
import os
import sys
import zipfile

from .constants import JSON_ENDING
from .constants import BASE64_ENDING
from .constants import TEMP_DIR_NAME
from .constants import VALID_INPUT_ENDINGS
from .constants import GUIDELINE_COLLECTION_NAME
from .make_temp_dir import make_temp_dir

def is_valid_file_type(path):
    return any(map(
        lambda valid_file_ending: path.endswith(valid_file_ending),
        VALID_INPUT_ENDINGS))

def get_input_file_path(argv_index=1):
    argument_missing_text = '[ERROR] Please provide an existing file path ' \
        f'as argument {argv_index}.'
    if len(sys.argv) < 2:
        raise Exception(argument_missing_text)
    input_file_path = sys.argv[argv_index]
    if not os.path.isfile(input_file_path):
        raise Exception(argument_missing_text)
    argument_wrong_format_text = '[ERROR] Please provide a file in one of ' \
        f'the following formats: {", ".join(VALID_INPUT_ENDINGS)}'
    if not is_valid_file_type(input_file_path):
        raise Exception(argument_wrong_format_text)
    return input_file_path

# Data is a Base64-encoded ZIP (#599)
def decode_and_unzip(base64_zip_path):
    make_temp_dir()
    zip_path = os.path.join(
        TEMP_DIR_NAME,
        os.path.basename(base64_zip_path).replace(BASE64_ENDING, '.zip'))
    with open(zip_path, 'wb') as zip_file:
        with open(base64_zip_path, 'rb') as input_file:
            base64.decode(input_file, zip_file)
    wrong_zip_content_text = '[ERROR] Please make sure that the zipped input ' \
        'archive holds exactly one file with "{}" extension'.format(JSON_ENDING)
    with zipfile.ZipFile(zip_path) as zip_file:
        zipped_files = zip_file.namelist()
        if len(zipped_files) != 1 or not zipped_files[0].endswith(JSON_ENDING):
            raise Exception(wrong_zip_content_text)
        zip_file.extractall(TEMP_DIR_NAME)
        json_path = os.path.join(TEMP_DIR_NAME, zipped_files[0])
        return json_path

def get_data(argv_index=1):
    input_file_path = get_input_file_path(argv_index)
    if input_file_path.endswith(BASE64_ENDING):
        input_file_path = decode_and_unzip(input_file_path)
    with open(input_file_path, 'r') as input_file:
        return json.load(input_file)

def get_guidelines_by_ids(data, ids):
    return list(map(lambda id: get_guideline_by_id(data, id), ids))

def get_guideline_by_id(data, id):
    guidelines = data[GUIDELINE_COLLECTION_NAME]
    return next(guideline for guideline in guidelines if guideline['_id'] == id)

def get_phenotype_value_lengths(guideline, expect_same_length = False):
    phenotype_values = list(guideline['lookupkey'].values()) + \
        list(guideline['phenotypes'].values())
    phenotype_values_lengths = list(set(map(len, phenotype_values)))
    if expect_same_length:
        if len(phenotype_values_lengths) != 1:
            raise Exception('[ERROR] Expecting lookupkey and phenotypes per ' \
                            'gene to have same lenghts but lengths differ ' \
                            'for guideline {}'.format(guideline['_id']))
        return phenotype_values_lengths[0]
    return phenotype_values_lengths

def get_phenotype_value(phenotype_values, index):
    phenotype_value = {}
    for gene in phenotype_values:
        phenotype_value[gene] = [phenotype_values[gene][index]]
    return phenotype_value

def dict_to_key(dictionary, format_value=lambda value: value):
    return ' '.join(map(
        lambda key: f'{key} {format_value(dictionary[key])}',
        dict(sorted(dictionary.items())).keys()))

def get_phenotype_key(guideline):
    return dict_to_key(
        guideline['phenotypes'],
        lambda phenotype_value: ''.join(phenotype_value))

def get_information_key(external_data):
    information_key = external_data['comments'] \
        if external_data['comments'] != None \
        else ''
    information_key += external_data['recommendation']
    information_key += dict_to_key(external_data['implications'])
    return information_key
    
