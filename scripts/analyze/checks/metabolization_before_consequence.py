import analyze.constants as constants

def _get_first_substring_position(string, substrings):
    positions = list(filter(
        lambda position: position > 0,
        map(
            lambda substring: string.find(substring),
            substrings,
        ),
    ))
    if (len(positions) == 0): return None
    return min(positions)

def check_metabolization_before_consequence(_, annotations):
    implication = annotations['implication']
    metabolization_position = _get_first_substring_position(
        implication,
        constants.METABOLIZATION_FORMULATIONS,
    )
    consequence_position = _get_first_substring_position(
        implication,
        constants.CONSEQUENCE_FORMULATIONS,
    )
    if metabolization_position == None or consequence_position == None:
        return True
    return metabolization_position < consequence_position