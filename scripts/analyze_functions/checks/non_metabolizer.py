import analyze_functions.constants as constants

def check_non_metabolizer(args):
    guideline = args['item']
    annotations = args['annotations']
    is_non_metabolizer_guideline = any(map(
        lambda gene: gene in constants.NON_METABOLIZERS,
        guideline['phenotypes'].keys(),
    )) and all(map(
        lambda gene: gene in constants.NON_METABOLIZERS or \
            guideline['phenotypes'][gene][0].lower() in constants.MISSING_PHENOTYPES,
        guideline['phenotypes'].keys(),
    ))
    has_metabolizer_text = any(map(
        lambda metabolizer_text: metabolizer_text in annotations['implication'],
        constants.METABOLIZER_TEXTS,
    ))
    return not is_non_metabolizer_guideline or not has_metabolizer_text