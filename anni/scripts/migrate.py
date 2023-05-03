from common.get_data import get_data
from common.write_data import write_data
from common.constants import SCRIPT_POSTFIXES

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

# Chain guideline migrations together
def migrate_guideline(guideline):
    return add_phenotypes(
        enlist_external_data(
            rename_external_data(guideline)))

data = get_data()

# Iterate data for migration of content
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

write_data(data, postfix=SCRIPT_POSTFIXES['migrate'])
