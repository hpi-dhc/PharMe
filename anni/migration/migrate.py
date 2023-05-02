import json
import os
import sys

def get_input_file_path():
    argument_error_text = 'Please provide an existing file path as argument.'
    if len(sys.argv) != 2:
        raise Exception(argument_error_text)
    input_file_path = sys.argv[1]
    if not os.path.isfile(input_file_path):
        raise Exception(argument_error_text)
    return input_file_path

with open(get_input_file_path(), 'r') as input_file:
    # Data is a Base64-encoded ZIP (#599)
    # TODO: if base64, decode and unzip; test that the result is json
    data = json.load(input_file)

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
def add_phenotypes(guideline):
    # TODO: get phenotypes from CPIC API based on lookupkey
    return guideline

def migrate_guideline(guideline):
    return add_phenotypes(
        enlist_external_data(
            rename_external_data(guideline)))

for table_name in data.keys():
    table_content = data[table_name]
    if table_name.startswith('AppData'):
        for row in table_content:
            drugs = row['drugs']
            for drug in drugs:
                guidelines = drug['guidelines']
                for guideline in guidelines:
                    guideline = migrate_guideline(guideline)
    if table_name.startswith('Guideline'):
        for guideline in table_content:
            guideline = migrate_guideline(guideline)

# TODO: save as json in zip in base64
