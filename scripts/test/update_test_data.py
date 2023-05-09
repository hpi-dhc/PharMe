from common.constants import GUIDELINE_COLLECTION_NAME
from common.constants import DRUG_COLLECTION_NAME
from common.constants import GUIDELINE_HISTORY_COLLECTION_NAME
from common.constants import DRUG_HISTORY_COLLECTION_NAME

REMOVED_DRUG = 'drug and guidelines not present in updated'
UNCHANGED_DRUG = 'drug and guidelines should be kept unchanged'
ADDED_DRUG = 'drug and guidelines should be added'
RX_NORM_CHANGED_DRUG = 'drug rxNorm changed'


def get_data():
    return {
        DRUG_HISTORY_COLLECTION_NAME: [],
        DRUG_COLLECTION_NAME: [{
            '_id': 'D1',
            'rxNorm': 'rx:1',
            'name': REMOVED_DRUG,
            'guidelines': ['g.old.rm.1', 'g.old.rm.2', 'g.old.rm.3'],
        }, {
            '_id': 'D2',
            'rxNorm': 'rx:2',
            'name': UNCHANGED_DRUG,
            'guidelines': ['g.old.uc.1', 'g.old.uc.2'],
        }, {
            '_id': 'D3',
            'rxNorm': 'rx:old',
            'name': RX_NORM_CHANGED_DRUG,
            'guidelines': ['g.old.rx.1', 'g.old.rx.2'],
            '_v': 1,
            '_vDate': 1683640341969
        }],
        GUIDELINE_HISTORY_COLLECTION_NAME: [],
        GUIDELINE_COLLECTION_NAME: [
            { '_id': 'g.old.rm.1' },
            { '_id': 'g.old.rm.2' },
            { '_id': 'g.old.rm.3' },
            { '_id': 'g.old.uc.1' },
            { '_id': 'g.old.uc.2' },
            { '_id': 'g.old.rx.1' },
            { '_id': 'g.old.rx.2' },
        ]}

def get_updated_data():
    return {
        DRUG_COLLECTION_NAME: [{
            'name': UNCHANGED_DRUG,
            'rxNorm': 'rx:2',
        }, {
            'name': ADDED_DRUG,
            'rxNorm': 'rx:added',
            'guidelines': [ 'g.new.add.1', 'g.new.add.2' ],
        }, {
            'name': RX_NORM_CHANGED_DRUG,
            'rxNorm': 'rx:new',
        }],
        GUIDELINE_COLLECTION_NAME: [
            {
                '_id': 'g.new.add.1',
                'phenotypes': {
                    'HLA-B': [ '*58:01 positive' ]
                },
            },
            {
                '_id': 'g.new.add.2',
                'phenotypes': {
                    'CYP2D6': [
                        'Indeterminate'
                    ],
                    'CYP2C19': [
                        'Intermediate Metabolizer'
                    ]
                },
            },
        ]}