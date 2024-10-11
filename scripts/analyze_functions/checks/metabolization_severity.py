import analyze_functions.constants as constants

def check_metabolization_severity(args):
    guideline = args['item']
    annotations = args['annotations']
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
    much_is_implied = any(
        map(
            lambda much_implying_formulation:
                much_implying_formulation in implication,
            constants.MUCH_IMPLYING_METABOLIZATION_FORMULATIONS,
        )
    )
    implication_has_much = any(
        map(
            lambda much_formulation: much_formulation in annotations['implication'],
            constants.MUCH_METABOLIZATION_FORMULATIONS,
        )
    )
    return much_is_implied == implication_has_much