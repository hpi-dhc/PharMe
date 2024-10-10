import sys
from common.constants import DRUG_COLLECTION_NAME, SCRIPT_POSTFIXES, \
    BRICK_COLLECTION_NAME
from common.get_data import get_data, get_guideline_by_id, get_phenotype_key
from common.write_data import write_data, write_log

CONSULT_TEXT = 'consult your pharmacist or doctor'
RED_TEXT = 'not be the right medication'
NOT_RED_TEXTS = [
    'if more than this dose is needed',
    "if #drug-name isn't working for you",
]
ADJUST_TEXT = 'adjusted'
YELLOW_RECOMMENDATION_TEXTS = NOT_RED_TEXTS + [
    ADJUST_TEXT,
    'increased',
    'decreased',
    'lower dose',
    'higher dose',
    'up to a certain dose',
    'dose increases should be done cautiously and slowly',
    'further testing is recommended',
]
YELLOW_IMPLICATION_TEXTS = [
    'increased risk',
    'may not work',
]
GREEN_TEXTS = ['at standard dose', 'there is no reason to avoid']

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

def get_annotation(data, item, key, resolve=True):
    if not key in item['annotations']: return None
    annotation = item['annotations'][key]
    if resolve: annotation = get_bricks_meaning(data, annotation)
    return annotation

def get_guideline_annotations(data, guideline):
    return {
        'implication': get_annotation(data, guideline, 'implication'),
        'recommendation': get_annotation(data, guideline, 'recommendation'),
        'warning_level': get_annotation(data, guideline, 'warningLevel',
            resolve=False)
    }

def get_drug_annotations(data, drug):
    return {
        'drugclass': get_annotation(data, drug, 'drugclass'),
        'indication': get_annotation(data, drug, 'indication'),
        'brand_names': get_annotation(data, drug, 'brandNames', resolve=False)
    }

def has_annotations(annotations):
    return all(list(map(
        lambda value: value != None,
        annotations.values())))

def has_consult(_, annotations):
    return CONSULT_TEXT in annotations['recommendation']

def check_implication_severity(guideline, annotations):
    ignored_phenotypes = ['no result', 'indeterminate', 'normal metabolizer']
    multiple_relevant_phenotypes = False
    relevant_gene = None
    for current_gene, current_phenotypes in guideline['phenotypes'].items():
        if not current_phenotypes[0].lower() in ignored_phenotypes:
            if relevant_gene != None:
                multiple_relevant_phenotypes = True
                break
            relevant_gene = current_gene
    if multiple_relevant_phenotypes or relevant_gene == None:
        return None
    implication = \
        guideline['externalData'][0]['implications'][relevant_gene].lower()
    much_implying_formulations = [
        'greatly decreased',
        'greatly reduced',
        'significantly reduced',
        'extremely high concentrations',
        'when compared to cyp2c19 rapid and normal metabolizers',
        'as compared to non-poor metabolizers',
        'when compared to cyp2c19 normal and intermediate metabolizers',
        'as compared to normal and intermediate metabolizer',
        'complete dpd deficiency',
    ]
    much_formulations = [
        'much faster',
        'much slower'
    ]
    much_is_implied = any(
        map(
            lambda much_implying_formulation:
                much_implying_formulation in implication,
            much_implying_formulations,
        )
    )
    implication_has_much = any(
        map(
            lambda much_formulation: much_formulation in annotations['implication'],
            much_formulations,
        )
    )
    return much_is_implied == implication_has_much

def should_be_red(annotations):
    return RED_TEXT in annotations['recommendation'] and all(map(
        lambda not_red_text: not_red_text not in annotations['recommendation'],
        NOT_RED_TEXTS,
    ))

def should_be_yellow(annotations):
    return any(map(
        lambda yellow_text: yellow_text in annotations['recommendation'],
        YELLOW_RECOMMENDATION_TEXTS,
    )) or any(map(
        lambda yellow_text: yellow_text in annotations['implication'],
        YELLOW_IMPLICATION_TEXTS,
    )) or (
        # Special case: no other recommendation given
        annotations['recommendation'] == \
            'consult your pharmacist or doctor for more information.'
    )

def should_be_green(annotations):
    return any(map(
        lambda green_text: green_text in annotations['recommendation'],
        GREEN_TEXTS,
    ))

def check_red_warning_level(_, annotations):
    has_warning_level = annotations['warning_level'] == 'red'
    should_have_warning_level = should_be_red(annotations)
    return has_warning_level == should_have_warning_level

def check_yellow_warning_level(_, annotations):
    has_warning_level = annotations['warning_level'] == 'yellow'
    should_have_warning_level = not should_be_red(annotations) and \
        should_be_yellow(annotations)
    return has_warning_level if should_have_warning_level else True

def check_green_warning_level(_, annotations):
    has_warning_level = annotations['warning_level'] == 'green'
    should_have_warning_level = not should_be_red(annotations) and \
        not should_be_yellow(annotations) and \
        should_be_green(annotations)
    return has_warning_level == should_have_warning_level

def check_none_warning_level(_, annotations):
    has_warning_level = annotations['warning_level'] == 'none'
    should_have_warning_level = not should_be_red(annotations) and \
        not should_be_yellow(annotations) and \
        not should_be_green(annotations)
    return has_warning_level == should_have_warning_level

def analyze_annotations(item, annotations, checks):
    results = {}
    for check_name, check_function in checks.items():
        results[check_name] = check_function(item, annotations)
    return results

def get_consult_brick(data):
    brick_filter = filter(
        lambda brick: get_english_text(brick).startswith(CONSULT_TEXT),
        data[BRICK_COLLECTION_NAME])
    return ensure_unique_item(brick_filter, 'brick meaning', CONSULT_TEXT)

def add_consult(data, guideline):
    guideline['annotations']['recommendation'].append(
        get_consult_brick(data)['_id'])
    
def check_brand_name_whitespace(_, annotations):
    check_applies = True
    for brand_name in annotations['brand_names']:
        trimmed_name = brand_name.strip()
        if trimmed_name != brand_name:
            check_applies = False
            break
    return check_applies

def correct_brand_name_whitespace(_, drug):
    drug['annotations']['brandNames'] = list(map(
        lambda brand_name: brand_name.strip(),
        drug['annotations']['brandNames']))

def correct_inconsistency(data, item, check_name, corrections):
    if check_name in corrections:
        corrections[check_name](data, item)
    return check_name in corrections

def log_not_annotated(log_content):
    log_content.append(' – _not annotated_\n')

def log_all_passed(log_content, postfix=''):
    log_content.append(f' – _all checks passed_{postfix}\n')

def log_annotations(log_content, annotations):
    for key, value in annotations.items():
        pretty_key = key.capitalize().replace('_', ' ')
        log_content.append(f'   {pretty_key}: {value}\n')

def handle_failed_checks(
    data, item, result, corrections, should_correct, annotations, log_content):
    failed_checks = []
    skipped_checks = []
    for check_name, check_result in result.items():
        if check_result == False:
            corrected = should_correct and \
                correct_inconsistency(data, item,
                    check_name, corrections)
            check_name = f'{check_name} (corrected)' if corrected \
                else check_name
            failed_checks.append(check_name)
        if check_result == None:
            skipped_checks.append(check_name)
    skipped_checks_string = ''
    if len(skipped_checks) > 0:
        skipped_checks_string = (' (skipped checks: ' \
        f'{", ".join(skipped_checks)})')
    if len(failed_checks) > 0:
        log_content.append(' - _some checks failed_: ' \
            f'{", ".join(failed_checks)}{skipped_checks_string}\n')
        log_annotations(log_content, annotations)
    else:
        log_all_passed(log_content, postfix=skipped_checks_string)

DRUG_CHECKS = {
    'brand_whitespace': check_brand_name_whitespace,
}

DRUG_CORRECTIONS = {
    'brand_whitespace': correct_brand_name_whitespace,
}

GUIDELINE_CHECKS = {
    'has_consult': has_consult,
    'implication_severity': check_implication_severity,
    'red_warning_level': check_red_warning_level,
    'yellow_warning_level': check_yellow_warning_level,
    'green_warning_level': check_green_warning_level,
    'none_warning_level': check_none_warning_level,
}

GUIDELINE_CORRECTIONS = {
    'has_consult': add_consult,
}

def main():
    correct_inconsistencies = '--correct' in sys.argv
    data = get_data()
    log_content = [
        '# Analyze annotation data\n\n',
        f'_Correct if possible: {correct_inconsistencies}_\n\n'
    ]
    for drug in data[DRUG_COLLECTION_NAME]:
        drug_name = drug['name']
        log_content.append(f'* {drug_name}')
        drug_annotations = get_drug_annotations(data, drug)
        if not has_annotations(drug_annotations): log_not_annotated(log_content)
        else:
            drug_result = analyze_annotations(
                drug, drug_annotations, DRUG_CHECKS)
            if not all(drug_result.values()):
                handle_failed_checks(data, drug, drug_result,
                    DRUG_CORRECTIONS, correct_inconsistencies,
                    drug_annotations, log_content)
            else:
                log_all_passed(log_content)
        for guideline_id in drug['guidelines']:
            guideline = get_guideline_by_id(data, guideline_id)
            phenotype = get_phenotype_key(guideline)
            log_content.append(f'  * {phenotype}')
            guideline_annotations = get_guideline_annotations(data, guideline)
            if not has_annotations(guideline_annotations):
                log_not_annotated(log_content)
                continue
            guideline_result = analyze_annotations(
                guideline, guideline_annotations, GUIDELINE_CHECKS)
            if guideline_result == None: continue
            if not all(guideline_result.values()):
                handle_failed_checks(data, guideline, guideline_result,
                    GUIDELINE_CORRECTIONS, correct_inconsistencies,
                    guideline_annotations, log_content)
            else:
                log_all_passed(log_content)

    write_log(log_content, postfix=SCRIPT_POSTFIXES['correct'])
    if correct_inconsistencies:
        write_data(data, postfix=SCRIPT_POSTFIXES['correct'])

if __name__ == '__main__':
    main()