from analyze_functions.constants import IGNORED_PHENOTYPES, NORMAL_RISK_TEXTS
from analyze_functions.data_helpers import joint_implication_text

def check_normal_side_effect_risk(args):
    guideline = args['item']
    annotations = args['annotations']
    can_have_normal_risk = any(map(
        lambda normal_risk_text: normal_risk_text in \
            joint_implication_text(guideline),
        NORMAL_RISK_TEXTS,
    )) or all(map(
        lambda gene:
            (gene == 'HLA-B' and 'negative' in guideline['phenotypes'][gene][0]) \
                or guideline['phenotypes'][gene][0].lower() in IGNORED_PHENOTYPES,
        guideline['phenotypes'].keys(),
    ))
    has_normal_risk_text = any(map(
        lambda normal_risk_text: normal_risk_text in annotations['implication'],
        NORMAL_RISK_TEXTS,
    ))
    return can_have_normal_risk or not has_normal_risk_text