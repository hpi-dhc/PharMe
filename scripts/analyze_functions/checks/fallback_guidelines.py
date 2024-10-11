from common.get_data import get_guideline_by_id

def check_single_lookup_fallback_guideline(args):
    drug = args['item']
    data = args['data']
    guidelines = list(map(
        lambda guideline_id: get_guideline_by_id(data, guideline_id),
        drug['guidelines'],
    ))
    check_applies = True
    for guideline in guidelines:
        for gene in guideline['lookupkey'].keys():
            for lookupValue in guideline['lookupkey'][gene]:
                is_special = lookupValue == '*' or lookupValue == '~'
                check_applies = check_applies and \
                    (not is_special or len( guideline['lookupkey'][gene]) == 1)
    return check_applies

def check_single_any_fallback_guideline(args):
    drug = args['item']
    data = args['data']
    guidelines = list(map(
        lambda guideline_id: get_guideline_by_id(data, guideline_id),
        drug['guidelines'],
    ))
    has_any_fallback = False
    for guideline in guidelines:
        for gene in guideline['lookupkey'].keys():
            for lookupValue in guideline['lookupkey'][gene]:
                is_any_fallback = lookupValue == '*'

                has_any_fallback = has_any_fallback or is_any_fallback                
    return not has_any_fallback or len(guidelines) == 1