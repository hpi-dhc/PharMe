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