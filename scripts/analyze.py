import sys

from analyze_functions.checks.fully_annotated_staged import check_if_fully_annotated_staged
from analyze_functions.checks.brand_name import check_brand_name_comma, check_brand_name_whitespace
from analyze_functions.checks.metabolization_before_consequence import check_metabolization_before_consequence
from analyze_functions.checks.fallback_guidelines import check_single_any_fallback_guideline, check_single_lookup_fallback_guideline
from analyze_functions.checks.non_metabolizer import check_non_metabolizer
from analyze_functions.checks.normal_side_effect_risk import check_normal_side_effect_risk
from analyze_functions.checks.warning_levels import check_green_warning_level, \
    check_none_warning_level, check_red_warning_level, \
        check_yellow_warning_level
from analyze_functions.checks.consult import has_consult
from analyze_functions.checks.metabolization_severity import check_metabolization_severity

from analyze_functions.corrections.consult import add_consult
from analyze_functions.corrections.brand_name_whitespace import correct_brand_name_whitespace

from analyze_functions.data_helpers import get_drug_annotations, get_guideline_annotations, has_annotations
from common.constants import DRUG_COLLECTION_NAME, SCRIPT_POSTFIXES
from common.get_data import get_data, get_guideline_by_id, get_phenotype_key
from common.write_data import write_data, write_log

DRUG_CHECKS = {
    'brand_whitespace': check_brand_name_whitespace,
    'brand_comma': check_brand_name_comma,
    'single_any_fallback': check_single_any_fallback_guideline,
    'fallback_single_lookup': check_single_lookup_fallback_guideline,
    'annotated_but_not_staged': check_if_fully_annotated_staged,
}

DRUG_CORRECTIONS = {
    'brand_whitespace': correct_brand_name_whitespace,
}

GUIDELINE_CHECKS = {
    'has_consult': has_consult,
    'check_metabolization_severity': check_metabolization_severity,
    'red_warning_level': check_red_warning_level,
    'yellow_warning_level': check_yellow_warning_level,
    'green_warning_level': check_green_warning_level,
    'none_warning_level': check_none_warning_level,
    'metabolization_before_consequence': check_metabolization_before_consequence,
    'annotated_but_not_staged': check_if_fully_annotated_staged,
    'should_not_have_normal_risk': check_normal_side_effect_risk,
    'non_metabolizer': check_non_metabolizer,
}

GUIDELINE_CORRECTIONS = {
    'has_consult': add_consult,
}

def analyze_annotations(checks, check_args):
    results = {}
    for check_name, check_function in checks.items():
        results[check_name] = check_function(check_args)
    return results

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
    return len(skipped_checks), len(failed_checks)

def run_analyses():
    correct_inconsistencies = '--correct' in sys.argv
    data = get_data()
    missing_drug_annotation_count = 0
    skipped_drug_annotation_count = 0
    failed_drug_annotation_count = 0
    missing_guideline_annotation_count = 0
    skipped_guideline_annotation_count = 0
    failed_guideline_annotation_count = 0
    log_content = []
    for drug in data[DRUG_COLLECTION_NAME]:
        drug_name = drug['name']
        log_content.append(f'* {drug_name}')
        drug_annotations = get_drug_annotations(data, drug)
        if not has_annotations(drug_annotations):
            missing_drug_annotation_count += 1
            log_not_annotated(log_content)
        else:
            drug_result = analyze_annotations(
                DRUG_CHECKS,
                {
                    'item': drug,
                    'annotations': drug_annotations,
                    'data': data,
                    'drug_name': drug_name,
                },
            )
            if not all(drug_result.values()):
                skipped, failed = handle_failed_checks(data, drug, drug_result,
                    DRUG_CORRECTIONS, correct_inconsistencies,
                    drug_annotations, log_content)
                skipped_drug_annotation_count += skipped
                failed_drug_annotation_count += failed
            else:
                log_all_passed(log_content)
        for guideline_id in drug['guidelines']:
            guideline = get_guideline_by_id(data, guideline_id)
            phenotype = get_phenotype_key(guideline)
            log_content.append(f'  * {phenotype}')
            guideline_annotations = get_guideline_annotations(data, guideline)
            if not has_annotations(guideline_annotations):
                missing_guideline_annotation_count += 1
                log_not_annotated(log_content)
                continue
            guideline_result = analyze_annotations(
                GUIDELINE_CHECKS,
                {
                    'item': guideline,
                    'annotations': guideline_annotations,
                    'drug_name': drug_name,
                },
            )
            if guideline_result == None: continue
            if not all(guideline_result.values()):
                skipped, failed = handle_failed_checks(
                    data, guideline, guideline_result,
                    GUIDELINE_CORRECTIONS, correct_inconsistencies,
                    guideline_annotations, log_content)
                skipped_guideline_annotation_count += skipped
                failed_guideline_annotation_count += failed
            else:
                log_all_passed(log_content)
    log_header = [
        '# Analyze annotation data\n\n',
        f'Correct if possible: {correct_inconsistencies}\n\n',
        'Failed annotation checks (search for `_some checks failed_`):\n\n',
        f'* Drugs: {failed_drug_annotation_count}\n',
        f'* Guidelines: {failed_guideline_annotation_count}\n\n',
        'Missing annotations (search for `_not annotated_`):\n\n',
        f'* Drugs: {missing_drug_annotation_count}\n',
        f'* Guidelines: {missing_guideline_annotation_count}\n\n',
        'Skipped annotation checks (search for `skipped checks`)\n\n',
        f'* Drugs: {skipped_drug_annotation_count}\n',
        f'* Guidelines: {skipped_guideline_annotation_count}\n\n',
    ]
    write_log([*log_header, *log_content], postfix=SCRIPT_POSTFIXES['correct'])
    if correct_inconsistencies:
        write_data(data, postfix=SCRIPT_POSTFIXES['correct'])

if __name__ == '__main__':
    run_analyses()