import analyze_functions.constants as constants

def _get_severity_overwrite(drug_name, guideline):
    severity_overwrite = None
    guideline_lookup = guideline['lookupkey']
    present_overwrites = list(filter(
        lambda overwrite: overwrite['drug'] == drug_name and \
            overwrite['lookup'] == guideline_lookup,
        constants.METABOLIZATION_SEVERITY_OVERWRITES,
    ))
    if len(present_overwrites) > 1:
        print(
            'WARNING: found multiple applying lookup overwrites for '
            f'{drug_name}, {guideline_lookup}; only using first one'
        )
    if len(present_overwrites) > 0:
        severity_overwrite = present_overwrites[0]['overwrite']
    return severity_overwrite

def check_metabolization_severity(args):
    guideline = args['item']
    annotations = args['annotations']
    drug_name = args['drug_name']
    multiple_relevant_phenotypes = False
    relevant_gene = None
    for current_gene, current_phenotypes in guideline['phenotypes'].items():
        if not current_phenotypes[0].lower() in constants.IGNORED_PHENOTYPES:
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
    severity_overwrite = _get_severity_overwrite(drug_name, guideline)
    should_have_much = severity_overwrite \
        if severity_overwrite != None \
        else much_is_implied
    implication_has_much = any(
        map(
            lambda much_formulation: much_formulation in annotations['implication'],
            constants.MUCH_METABOLIZATION_FORMULATIONS,
        )
    )
    return should_have_much == implication_has_much