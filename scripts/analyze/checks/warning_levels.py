from analyze.checks.constants import CONSULT_TEXT

WHOLE_CONSULT_TEXT = '{} for more information.'.format(CONSULT_TEXT)
RED_TEXT = 'not be the right medication'
NOT_RED_TEXTS = [
    'if more than this dose is needed',
    "if #drug-name isn't working for you",
]
ADJUST_TEXT = 'adjusted'
YELLOW_RECOMMENDATION_TEXTS = NOT_RED_TEXTS + [
    ADJUST_TEXT,
    'increased',
    'decreased',
    'lower dose',
    'higher dose',
    'up to a certain dose',
    'dose increases should be done cautiously and slowly',
    'further testing is recommended',
]
YELLOW_IMPLICATION_TEXTS = [
    'increased risk',
    'may not work',
]
GREEN_TEXTS = ['at standard dose', 'there is no reason to avoid']

def should_be_red(annotations):
    return RED_TEXT in annotations['recommendation'] and all(map(
        lambda not_red_text: not_red_text not in annotations['recommendation'],
        NOT_RED_TEXTS,
    ))

def should_be_yellow(annotations):
    return any(map(
        lambda yellow_text: yellow_text in annotations['recommendation'],
        YELLOW_RECOMMENDATION_TEXTS,
    )) or any(map(
        lambda yellow_text: yellow_text in annotations['implication'],
        YELLOW_IMPLICATION_TEXTS,
    )) or (
        # Special case: no other recommendation given
        annotations['recommendation'] == WHOLE_CONSULT_TEXT
    )

def should_be_green(annotations):
    return any(map(
        lambda green_text: green_text in annotations['recommendation'],
        GREEN_TEXTS,
    ))

def check_red_warning_level(_, annotations):
    has_warning_level = annotations['warning_level'] == 'red'
    should_have_warning_level = should_be_red(annotations)
    return has_warning_level == should_have_warning_level

def check_yellow_warning_level(_, annotations):
    has_warning_level = annotations['warning_level'] == 'yellow'
    should_have_warning_level = not should_be_red(annotations) and \
        should_be_yellow(annotations)
    return has_warning_level if should_have_warning_level else True

def check_green_warning_level(_, annotations):
    has_warning_level = annotations['warning_level'] == 'green'
    should_have_warning_level = not should_be_red(annotations) and \
        not should_be_yellow(annotations) and \
        should_be_green(annotations)
    return has_warning_level == should_have_warning_level

def check_none_warning_level(_, annotations):
    has_warning_level = annotations['warning_level'] == 'none'
    should_have_warning_level = not should_be_red(annotations) and \
        not should_be_yellow(annotations) and \
        not should_be_green(annotations)
    return has_warning_level == should_have_warning_level