import copy

from update import get_drug_names
from update import remove_outdated_drugs
from update import add_missing_drugs
from update import update_drugs
from update import remove_outdated_guidelines
from update import add_missing_guidelines
from update import update_guidelines
from common.constants import GUIDELINE_COLLECTION_NAME
from common.constants import DRUG_COLLECTION_NAME

REMOVED_DRUG = 'drug and guidelines not present in updated'
UNCHANGED_DRUG = 'drug and guidelines should be kept unchanged'
ADDED_DRUG = 'drug and guidelines should be added'
RX_NORM_CHANGED_DRUG = 'drug rxNorm changed'

def get_guideline_ids(data):
    return list(map(
        lambda guideline: guideline['_id'],
        data[GUIDELINE_COLLECTION_NAME]
    ))

def get_data():
    return {
        DRUG_COLLECTION_NAME: [{
            '_id': 'D1',
            'rxNorm': 'rx:1',
            'name': REMOVED_DRUG,
            'guidelines': ['g.old.rm.1', 'g.old.rm.2', 'g.old.rm.3'],
        }, {
            '_id': 'D2',
            'rxNorm': 'rx:2',
            'name': UNCHANGED_DRUG,
            'guidelines': ['g.old.uc.1', 'g.old.uc.2']
        }, {
            '_id': 'D3',
            'rxNorm': 'rx:old',
            'name': RX_NORM_CHANGED_DRUG,
            'guidelines': ['g.old.rx.1', 'g.old.rx.2']
        }],
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
            'rxNorm': 'rx:2'
        }, {
            'name': ADDED_DRUG,
            'rxNorm': 'rx:added',
            'guidelines': [ 'g.new.add.1', 'g.new.add.2' ],
        }, {
            'name': RX_NORM_CHANGED_DRUG,
            'rxNorm': 'rx:new',
        }],
        GUIDELINE_COLLECTION_NAME: [
            { '_id': 'g.new.add.1' },
            { '_id': 'g.new.add.2' },
        ]}

def test_remove_outdated_drugs():
    data = get_data()
    updated_data = get_updated_data()
    expected_data = copy.deepcopy(data)
    del expected_data[DRUG_COLLECTION_NAME][0]
    del expected_data[GUIDELINE_COLLECTION_NAME][0:3]
    data, _ = remove_outdated_drugs(data, updated_data)
    assert data == expected_data

def test_add_missing_drugs():
    data = get_data()
    updated_data = get_updated_data()
    expected_data = copy.deepcopy(data)
    expected_data[DRUG_COLLECTION_NAME].append({
        'name': ADDED_DRUG,
        'rxNorm': 'rx:added',
        'guidelines': [ 'g.new.add.1', 'g.new.add.2' ],
    })
    expected_data[GUIDELINE_COLLECTION_NAME] += [
        { '_id': 'g.new.add.1' },
        { '_id': 'g.new.add.2' },
    ]
    data, _ = add_missing_drugs(data, updated_data)
    assert data == expected_data

def test_updating_drugs():
    data = get_data()
    updated_data = get_updated_data()
    expected_data = copy.deepcopy(data)
    expected_data[DRUG_COLLECTION_NAME][2]['rxNorm'] = 'rx:new'
    data, _ = update_drugs(data, updated_data)
    assert data == expected_data