from analyze_functions.constants import CONSULT_TEXT

def has_consult(args):
    annotations = args['annotations']
    return CONSULT_TEXT in annotations['recommendation']