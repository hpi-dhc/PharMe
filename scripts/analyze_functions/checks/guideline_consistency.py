from analyze_functions.constants import IGNORED_GUIDELINE_INCONSISTENCIES
from analyze_functions.data_helpers import get_guideline_content, joint_implication_text
from common.get_data import get_phenotype

def _group_check_args_by_guideline(guideline_check_args_list):
    check_args_per_external_guideline = {}
    for check_args in guideline_check_args_list:
        guideline = check_args['item']
        guideline_url = get_guideline_content(guideline, 'guidelineUrl')
        guideline_key = guideline_url \
            .replace('https://cpicpgx.org/guidelines/', '') \
            .replace('https://www.fda.gov/medical-devices/precision-medicine/', 'fda-') \
            .replace('/', '')
        if guideline_key in check_args_per_external_guideline:
            check_args_per_external_guideline[guideline_key] = [
                *check_args_per_external_guideline[guideline_key],
                check_args,
            ]
        else:
            check_args_per_external_guideline[guideline_key] = [check_args]
    return check_args_per_external_guideline

def _group_annotations_by_guideline_content(check_args_list):
    same_guideline_annotations = {}
    for check_args in check_args_list:
        drug_name = check_args['drug_name']
        guideline = check_args['item']
        annotations = check_args['annotations']
        grouped_content = {
            f'Implication "{joint_implication_text(guideline)}"': annotations['implication'],
            f'Recommendation "{get_guideline_content(guideline, "recommendation")}"': annotations['recommendation'],
        }
        content_identifier = f'{drug_name} {get_phenotype(guideline)}'
        for key, content in grouped_content.items():
            normalized_key = key.replace(drug_name, '#drug-name').replace('phenytoin', '#drug-name')
            normalized_content = content.replace(' still', '')
            # TODO: add drug name to structure and log
            if normalized_key in same_guideline_annotations:
                if normalized_content in same_guideline_annotations[normalized_key]:
                    same_guideline_annotations[normalized_key][normalized_content].append(content_identifier)
                else:
                    same_guideline_annotations[normalized_key][normalized_content] = [content_identifier]
            else:
                same_guideline_annotations[normalized_key] = {normalized_content: [content_identifier]}
    return same_guideline_annotations

def check_guideline_consistencies(guideline_check_args_list):
    check_args_per_external_guideline = \
        _group_check_args_by_guideline(guideline_check_args_list)
    inconsistent_guidelines_count = 0
    log_content = []
    for guideline_key, check_args_list in check_args_per_external_guideline.items():
        if (guideline_key.startswith('fda-table-pharmacogenetic-associations')):
            continue
        if (len(check_args_list) < 2): continue
        same_guideline_annotations = _group_annotations_by_guideline_content(
            check_args_list,
        )
        inconsistency_log_content = []
        for same_guideline_key, guideline_content in same_guideline_annotations.items():
            skip_definitions = list(filter(
                lambda ignored_case: ignored_case['guideline'] == guideline_key \
                    and same_guideline_key.lower().startswith(ignored_case['type']) \
                    and same_guideline_key.endswith(f'"{ignored_case["text"]}"'),
                IGNORED_GUIDELINE_INCONSISTENCIES,
            ))
            if len(skip_definitions) > 1:
                print('WARNING: Got multiple applying consistency check skip '
                      'definitions, this should not happen'
                )
            if len(skip_definitions) > 0:
                continue
            unique_guideline_content = set(guideline_content.keys())
            if len(unique_guideline_content) != 1:
                inconsistency_log_content += f'  * {same_guideline_key} maps to:\n'
                for content in unique_guideline_content:
                    content_identifier = guideline_content[content]
                    inconsistency_log_content += f'    * {content} ({"; ".join(content_identifier)})\n'
        if (len(inconsistency_log_content) > 0):
            inconsistent_guidelines_count += 1
            log_content += f'* {guideline_key}\n'
            for inconsistency in inconsistency_log_content:
                log_content += inconsistency
    if inconsistent_guidelines_count > 0:
        log_content.append('\n')
    return inconsistent_guidelines_count, log_content