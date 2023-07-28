import sys
from common.constants import DRUG_COLLECTION_NAME, SCRIPT_POSTFIXES, \
    BRICK_COLLECTION_NAME
from common.get_data import get_data, get_guideline_by_id, get_phenotype_key
from common.write_data import write_data

CONSULT_TEXT = 'consult your pharmacist or doctor'

def ensure_unique_item(item_filter, field_name, value):
    item = list(item_filter)
    if len(item) != 1:
        message = f'[ERROR] Items are not unique for {field_name} == ' \
            f'{value}: {item}'
        raise Exception(message)
    return item[0]

def get_unique_item(items, field_name, value):
    item_filter = filter(lambda item: item[field_name] == value, items)
    return ensure_unique_item(item_filter, field_name, value)

def get_english_text(brick):
    translation = get_unique_item(brick['translations'], 'language', 'English')
    return translation['text'].lower()

def get_brick_meaning(data, brick_id):
    bricks = data[BRICK_COLLECTION_NAME]
    brick = get_unique_item(bricks, '_id', brick_id)
    return get_english_text(brick)

def get_bricks_meaning(data, brick_ids):
    return ' '.join(map(
        lambda brick_id: get_brick_meaning(data, brick_id),
        brick_ids))

def get_annotation(data, guideline, key, resolve=True):
    if not key in guideline['annotations']: return None
    annotation = guideline['annotations'][key]
    if resolve: annotation = get_bricks_meaning(data, annotation)
    return annotation

def get_annotations(data, guideline):
    return {
        'implication': get_annotation(data, guideline, 'implication'),
        'recommendation': get_annotation(data, guideline, 'recommendation'),
        'warning_level': get_annotation(data, guideline, 'warningLevel',
            resolve=False)
    }

def has_consult(_, annotations):
    return CONSULT_TEXT in annotations['recommendation']

def check_implication_severity(guideline, annotations):
    phenotype = get_phenotype_key(guideline).lower()
    check_applies = True
    gene_number = len(guideline['phenotypes'].keys())
    missing_genes = phenotype.count('no result') + \
        phenotype.count('indeterminate')
    if gene_number - missing_genes != 1:
        return check_applies
    severity_rules = [
        { 'much': True, 'phenotype': 'ultrarapid', 'implication': 'faster' },
        { 'much': True, 'phenotype': 'poor', 'implication': 'slower' },
        { 'much': False, 'phenotype': 'rapid', 'implication': 'faster' },
        { 'much': False, 'phenotype': 'intermediate', 'implication': 'slower' },
    ]
    for severity_rule in severity_rules:
        rule_broken = severity_rule['phenotype'] in phenotype and \
            severity_rule['implication'] in annotations['implication'] and \
                severity_rule['much'] != 'much' in annotations['implication']
        if rule_broken:
            check_applies = False
            break
    return check_applies

def analyze_guideline_annotations(guideline, annotations):
    checks = {
        'has_consult': has_consult,
        'implication_severity': check_implication_severity,
    }
    results = {}
    for check_name, check_function in checks.items():
        results[check_name] = check_function(guideline, annotations)
    return results

def get_consult_brick(data):
    brick_filter = filter(
        lambda brick: get_english_text(brick).startswith(CONSULT_TEXT),
        data[BRICK_COLLECTION_NAME])
    return ensure_unique_item(brick_filter, 'brick meaning', CONSULT_TEXT)

def add_consult(data, guideline):
    guideline['annotations']['recommendation'].append(
        get_consult_brick(data)['_id'])

def correct_inconsistency(data, guideline, check_name):
    corrections = {
        'has_consult': add_consult,
    }
    if check_name in corrections:
        corrections[check_name](data, guideline)

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
            result = analyze_guideline_annotations(guideline, annotations)
            if result == None: continue
            phenotype = get_phenotype_key(guideline)
            if not all(result.values()):
                for check_name, check_result in result.items():
                    if check_result == False:
                        message = f'[FAILED CHECK] for {drug_name} – ' \
                            f'{phenotype}: {check_name}'
                        print(message)
                        if correct_inconsistencies:
                            correct_inconsistency(data, guideline, check_name)
            results[drug_name][phenotype] = result

    if correct_inconsistencies:
        write_data(data, postfix=SCRIPT_POSTFIXES['correct'])

if __name__ == '__main__':
    main()