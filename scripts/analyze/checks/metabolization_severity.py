def check_metabolization_severity(guideline, annotations):
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