from common.get_data import get_guideline_by_id

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
                if is_any_fallback and len(guideline['lookupkey'][gene]) != 1:
                    print(gene)
                    print(guideline['lookupkey'])
                    print(
                        '[WARNING] Multiple lookupkeys with present "any '
                        'fallback", all other than * are ignored'    
                    )
                has_any_fallback = has_any_fallback or is_any_fallback                
    return not has_any_fallback or len(guidelines) == 1