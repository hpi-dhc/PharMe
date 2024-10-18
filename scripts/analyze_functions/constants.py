METABOLIZATION_SEVERITY_OVERWRITES = [
    {
        'drug': 'voriconazole',
        'lookup': {'CYP2C19': ['Ultrarapid Metabolizer']},
        'overwrite': True,
    },
    {
        'drug': 'siponimod',
        'lookup': {'CYP2C9': ['0.0']},
        'overwrite': True,
    },
]

IMPLICATION_TYPE = 'implication'
RECOMMENDATION_TYPE = 'recommendation'

IGNORED_GUIDELINE_INCONSISTENCIES = [
    {
        'guideline': 'guideline-for-tricyclic-antidepressants-and-cyp2d6-and-cyp2c19',
        'type': RECOMMENDATION_TYPE,
        'text': 'No recommendation',
    },
    {
        'guideline': 'cpic-guideline-for-tamoxifen-based-on-cyp2d6-genotype',
        'type': IMPLICATION_TYPE,
        'text': 'therapeutic endoxifen concentrations',
    },
    {
        'guideline': 'cpic-guideline-for-atomoxetine-based-on-cyp2d6-genotype',
        'type': IMPLICATION_TYPE,
        'text': 'normal metabolizers of #drug-name have a lower likelihood of response as compared to poor metabolizers. this is associated with increased discontinuation due to lack of efficacy as compared to poor metabolizers.',
    },
    {
        'guideline': 'guideline-for-phenytoin-and-cyp2c9-and-hla-b',
        'type': IMPLICATION_TYPE,
        'text': 'n/a',
    },
]

IGNORE_STAGED_CHECK = [
    'amikacin',
    'gentamicin',
    'kanamycin',
    'paromomycin',
    'tobramycin',
    'streptomycin',
    'plazomicin',
]

CONSULT_TEXT = 'consult your pharmacist or doctor'
WHOLE_CONSULT_TEXT = '{} for more information.'.format(CONSULT_TEXT)
NORMAL_RISK_TEXTS = [
    'normal risk',
    'low or reduced risk',
    'typical myopathy risk',
    'weak or no evidence for an increased risk',
    '"normal" risk',
]
NON_METABOLIZERS = [
    'G6PD',
    'SLCO1B1',
    'MT-RNR1',
    'HLA-B',
    'HLA-A',
]
BREAK_DOWN_TEXT = 'break down'
ACTIVATE_TEXT = 'activate'
METABOLIZER_TEXTS = [BREAK_DOWN_TEXT, ACTIVATE_TEXT]
MISSING_PHENOTYPES = ['no result', 'indeterminate']
IGNORED_PHENOTYPES = [*MISSING_PHENOTYPES, 'normal metabolizer']
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
MAY_NOT_WORK_TEXT = 'may not work'
YELLOW_IMPLICATION_TEXTS = [
    'increased risk',
    MAY_NOT_WORK_TEXT,
]
GREEN_TEXTS = ['at standard dose', 'there is no reason to avoid']
MUCH_IMPLYING_METABOLIZATION_FORMULATIONS = [
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
MUCH_METABOLIZATION_FORMULATIONS = [
    'much faster',
    'much slower'
]
METABOLIZATION_FORMULATIONS = [
    'activate',
    'break down',
]
CONSEQUENCE_FORMULATIONS = [
    'risk',
    MAY_NOT_WORK_TEXT,
]