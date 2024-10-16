from analyze_functions.constants import ACTIVATE_TEXT, BREAK_DOWN_TEXT
from analyze_functions.data_helpers import get_guideline_annotations

def check_same_metabolization_type(args):
    data = args['data']
    guidelines = args['drug_guidelines']
    has_activate = False
    has_break_down = False
    for guideline in guidelines:
        if has_activate and has_break_down: break
        annotations = get_guideline_annotations(data, guideline)
        implication = annotations['implication']
        if implication == None: continue
        if ACTIVATE_TEXT in implication: has_activate = True
        if BREAK_DOWN_TEXT in implication: has_break_down = True
    return not (has_activate and has_break_down)