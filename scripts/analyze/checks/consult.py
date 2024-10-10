from analyze.checks.constants import CONSULT_TEXT

def has_consult(_, annotations):
    return CONSULT_TEXT in annotations['recommendation']