import sys
from common.constants import DRUG_COLLECTION_NAME
from common.get_data import get_data, get_guideline_by_id, get_phenotype_key

def get_unique_item(items, field_name, value):
    item = list(filter(lambda item: item[field_name] == value, items))
    if len(item) != 1:
        message = f'[ERROR] Items are not unique for {field_name} == ' \
            f'{value}: {item}'
        raise Exception(message)
    return item[0]

def get_brick_meaning(data, brick_id):
    bricks = data['TextBrick']
    brick = get_unique_item(bricks, '_id', brick_id)
    meaning = get_unique_item(brick['translations'], 'language', 'English')
    return meaning['text']

def get_bricks_meaning(data, brick_ids):
    return ' '.join(map(
        lambda brick_id: get_brick_meaning(data, brick_id),
        brick_ids))

def get_annotation(data, guideline, key, resolve=True):
    if not key in guideline['annotations']: return None
    annotation = guideline['annotations'][key]
    if resolve: annotation = get_bricks_meaning(data, annotation)
    return annotation.lower()

def get_annotations(data, guideline):
    return {
        'implication': get_annotation(data, guideline, 'implication'),
        'recommendation': get_annotation(data, guideline, 'recommendation'),
        'warning_level': get_annotation(data, guideline, 'warningLevel',
            resolve=False)
    }

def has_consult(annotations):
    return 'consult your pharmacist or doctor' in annotations['recommendation']

def analyze_guideline_annotations(annotations):
    checks = {
        'has_consult': has_consult,
    }
    results = {}
    for check_name, check_function in checks.items():
        results[check_name] = check_function(annotations)
    return results

def main():
    correct_inconsistencies = '--correct' in sys.argv
    data = get_data()
    results = {}
    for drug in data[DRUG_COLLECTION_NAME]:
        drug_name = drug['name']
        results[drug_name] = {}
        for guideline_id in drug['guidelines']:
            guideline = get_guideline_by_id(data, guideline_id)
            if not 'annotations' in guideline: continue
            annotations = get_annotations(data, guideline)
            if all(list(map(
                lambda value: value == None,
                annotations.values()))): continue
            result = analyze_guideline_annotations(annotations)
            if result == None: continue
            phenotype = get_phenotype_key(guideline)
            if not all(result.values()):
                for check_name, check_result in result.items():
                    message = f'[FAILED CHECK] for {drug_name} – {phenotype}' \
                        f': {check_name}'
                    print(message)      
            results[drug_name][phenotype] = result
    # TODO: correct and write data if correct_inconsistencies

if __name__ == '__main__':
    main()