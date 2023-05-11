import copy
import pytest

from update import remove_outdated_drugs
from update import add_missing_drugs
from update import update_drugs

from common.constants import GUIDELINE_COLLECTION_NAME
from common.constants import DRUG_COLLECTION_NAME
from common.constants import GUIDELINE_HISTORY_COLLECTION_NAME
from common.constants import DRUG_HISTORY_COLLECTION_NAME
from common.mongo import get_timestamp, get_object_id

def build_guideline(id, phenotypes, lookupkey, external_data):
    return {
        '_id': id,
        '_v': 1,
        '_vDate': get_timestamp(),
        'phenotypes': phenotypes,
        'lookupkey': lookupkey,
        'externalData': external_data,
    }

def build_drug(name, guideline_ids, rx_norm=None):
    rx_norm = rx_norm if rx_norm != None else f'rx:{name}'
    return {
        '_id': get_object_id(),
        'rxNorm': rx_norm,
        'name': name,
        'guidelines': guideline_ids,
        '_v': 1,
        '_vDate': get_timestamp(),
    }

def build_guidelines(drug_guideline_map, phenotypes, lookupkeys, external_data):
    guidelines = []
    for _, guideline_ids in drug_guideline_map.items():
        for index, guideline_id in enumerate(guideline_ids):
            guideline_phenotypes = phenotypes[guideline_id] \
                if guideline_id in phenotypes \
                    else STANDARD_PHENOTYPES[index % len(STANDARD_PHENOTYPES)]
            guideline_lookupkey = lookupkeys[guideline_id] \
                if guideline_id in lookupkeys \
                    else STANDARD_PHENOTYPES[index % len(STANDARD_PHENOTYPES)]
            guideline_external_data = external_data[guideline_id] \
                if guideline_id in external_data \
                    else STANDARD_EXTERNAL_DATA[index % \
                                                len(STANDARD_EXTERNAL_DATA)]
            guidelines.append(
                build_guideline(guideline_id, guideline_phenotypes, \
                                guideline_lookupkey, guideline_external_data))
    return guidelines

def build_drugs(drug_guideline_map, rx_norms):
    return list(map(
        lambda drug_name: build_drug(drug_name, drug_guideline_map[drug_name],
            rx_norm=rx_norms[drug_name] if drug_name in rx_norms else None),
        drug_guideline_map
    ))

def build_data(drug_guideline_map, rx_norms={}, phenotypes={}, lookupkeys={}, \
               external_data={}):
    drugs = build_drugs(drug_guideline_map, rx_norms)
    guidelines = build_guidelines(
        drug_guideline_map, phenotypes, lookupkeys, external_data)
    return {
        DRUG_HISTORY_COLLECTION_NAME: [],
        DRUG_COLLECTION_NAME: drugs,
        GUIDELINE_HISTORY_COLLECTION_NAME: [],
        GUIDELINE_COLLECTION_NAME: guidelines,
    }

REMOVED_DRUG = 'drug and guidelines not present in updated'
UNCHANGED_DRUG = 'drug and guidelines should be kept unchanged'
ADDED_DRUG = 'drug and guidelines should be added'
RX_NORM_CHANGED_DRUG = 'drug rxNorm changed'
GUIDELINE_REMOVED_DRUG = 'drug with guideline for phenotype removed'
GUIDELINE_ADDED_DRUG = 'drug with guideline for new phenotype'
GUIDELINE_LOOKUPKEY_CHANGED = 'drug with guidelines with updated lookupkey'
GUIDELINE_EXTERNAL_DATA_CHANGED = \
    'drug with guidelines with external data change'
ADDED_GUIDELINE_ID = 'new.add-guideline'
STANDARD_PHENOTYPES = [{
        'CYP2C19': [ 'Poor Metabolizer' ],
        'CYP2D6': [ 'Poor Metabolizer' ]
    },
    {
        'CYP2C19': [ 'Intermediate Metabolizer' ],
        'CYP2D6': [ 'No Result' ]
    },
    {
        'HLA-B': [ '*58:01 positive' ]
    }]
# Original lookupkeys like STANDARD_PHENOTYPES, only second item with additional
# key (test that key is removed)
CHANGED_LOOKUPKEYS = {
    'new.keyadded': {
        'CYP2C19': [ 'Poor Metabolizer', 'Likely Poor Metabolizer' ],
        'CYP2D6': [ 'Poor Metabolizer' ]
    },
    'new.keyremoved': {
        'CYP2C19': [ 'Intermediate Metabolizer' ],
        'CYP2D6': [ 'No Result' ]
    },
    'new.keychanged': {
        'HLA-B': [ '*58:01 negative' ]
    }}
STANDARD_EXTERNAL_DATA = [
    [
        {
            'implications': {
                'CYP2C19': 'Higher plasma concentrations',
                'CYP2D6': 'Lower plasma concentrations'
            },
            'recommendation': 'Avoid use',
            'comments': 'No comments'
        },
        {
            'implications': {
                'CYP2C19': 'Likely higher plasma concentrations',
                'CYP2D6': 'Lower plasma concentrations'
            },
            'recommendation': 'Avoid use or adjust dosage',
            'comments': 'More data needed'
        }
    ],
    [
        {
            'implications': {
                'CYP2C19': 'Slightly higher plasma concentrations',
                'CYP2D6': 'More data needed'
            },
            'recommendation': 'No recommendation can be given',
            'comments': 'More research needed'
        }
    ],
    [
        {
            'implications': {
                'HLA-B': 'Low or reduced risk of abacavir hypersensitivity'
            },
            'recommendation': 'Use abacavir per standard dosing guidelines',
            'comments': 'n/a',
        }
    ],
]
CHANGED_EXTERNAL_DATA = {
    'new.data-rm': [
        {
            'implications': {
                'CYP2C19': 'Higher plasma concentrations',
                'CYP2D6': 'Lower plasma concentrations'
            },
            'recommendation': 'Avoid use',
            'comments': 'No comments'
        }
    ],
    'new.data-change': [
        {
            'implications': {
                'CYP2C19': 'Slightly higher plasma concentrations',
                'CYP2D6': 'Some data found'
            },
            'recommendation': 'Use per standard dose',
            'comments': 'None'
        }
    ],
    'new.data-add': [
        {
            'implications': {
                'HLA-B': 'Low risk of abacavir hypersensitivity'
            },
            'recommendation': 'Use abacavir per standard dosing guidelines',
            'comments': 'n/a',
        },
        {
            'implications': {
                'HLA-B': 'Reduced risk of abacavir hypersensitivity'
            },
            'recommendation': 'Use abacavir per standard dosing guidelines',
            'comments': 'n/a',
        }
    ],
}

@pytest.fixture
def data():
    drug_guideline_map = {
        REMOVED_DRUG: ['old.rm-drug.1', 'old.rm-drug.2', 'old.rm-drug.3'],
        UNCHANGED_DRUG: ['old.unchanged.1', 'old.unchanged.2'],
        RX_NORM_CHANGED_DRUG: ['old.rx-change.1', 'old.rx-change.2'],
        GUIDELINE_REMOVED_DRUG: ['old.rm-guideline', 'old.keep-guideline'],
        GUIDELINE_ADDED_DRUG: ['old.present-guideline'],
        GUIDELINE_LOOKUPKEY_CHANGED: \
            ['old.keyadded', 'old.keyremoved', 'old.keychanged'],
        GUIDELINE_EXTERNAL_DATA_CHANGED: \
            ['old.data-rm', 'old.data-change', 'old.data-add'],
    }
    rx_norms = { RX_NORM_CHANGED_DRUG: 'rx.old' }
    phenotypes = {
        'old.rm-guideline': { 'CYP2D6': [ 'Poor metabolizer' ]},
        'old.keep-guideline': STANDARD_PHENOTYPES[0],
        'old.unchanged.2': {
            'CYP2D6': [ 'Indeterminate' ],
            'CYP2C19': [ 'Intermediate Metabolizer' ]},
    }
    lookupkeys = {
        'old.keep-guideline': STANDARD_PHENOTYPES[0],
        'old.keyadded': STANDARD_PHENOTYPES[0],
        'old.keyremoved': copy.deepcopy(STANDARD_PHENOTYPES[1]), # to be changed
        'old.keychanged': STANDARD_PHENOTYPES[2],
    }
    lookupkeys['old.keyremoved']['CYP2C19'].append(
        'Likely Intermediate Metabolizer')
    external_data = {
        'old.keep-guideline': STANDARD_EXTERNAL_DATA[0]
    }
    return build_data(
        drug_guideline_map, rx_norms, phenotypes, lookupkeys, external_data)

@pytest.fixture
def updated_data():
    drug_guideline_map = {
        UNCHANGED_DRUG: ['new.unchanged.1', 'new.unchanged.2'],
        ADDED_DRUG: ['new.add-drug.1', 'new.add-drug.2'],
        RX_NORM_CHANGED_DRUG: ['new.rx-change.1', 'new.rx-change.2'],
        GUIDELINE_REMOVED_DRUG: ['new.keep-guideline'],
        GUIDELINE_ADDED_DRUG: ['new.present-guideline', ADDED_GUIDELINE_ID],
        GUIDELINE_LOOKUPKEY_CHANGED: \
            ['new.keyadded', 'new.keyremoved', 'new.keychanged'],
        GUIDELINE_EXTERNAL_DATA_CHANGED: \
            ['new.data-rm', 'new.data-change', 'new.data-add'],
    }
    rx_norms = { RX_NORM_CHANGED_DRUG: 'rx.new' }
    phenotypes = {
        'new.unchanged.2': {
            'CYP2D6': [ 'Indeterminate' ],
            'CYP2C19': [ 'Intermediate Metabolizer' ]},
        'new.keep-guideline': STANDARD_PHENOTYPES[0]
    }
    return build_data(drug_guideline_map, rx_norms, phenotypes, \
        lookupkeys=CHANGED_LOOKUPKEYS, external_data=CHANGED_EXTERNAL_DATA)

def test_remove_outdated_drugs(data, updated_data):
    expected_data = copy.deepcopy(data)
    data, _ = remove_outdated_drugs(data, updated_data)
    expected_data[DRUG_HISTORY_COLLECTION_NAME].append(
        expected_data[DRUG_COLLECTION_NAME].pop(0))
    for _ in range(3):
        expected_data[GUIDELINE_HISTORY_COLLECTION_NAME].append(
            expected_data[GUIDELINE_COLLECTION_NAME].pop(0)
        )
    assert data == expected_data

def test_add_missing_drugs(data, updated_data):
    expected_data = copy.deepcopy(data)
    data, _ = add_missing_drugs(data, updated_data)
    expected_data[DRUG_COLLECTION_NAME].append(
        copy.deepcopy(updated_data[DRUG_COLLECTION_NAME][1]))
    expected_data[GUIDELINE_COLLECTION_NAME] += copy.deepcopy(
        updated_data[GUIDELINE_COLLECTION_NAME][2:4])
    assert data == expected_data

def test_update_drugs(data, updated_data):
    expected_data = copy.deepcopy(data)

    # RxNorm is updated; drug history added
    expected_data[DRUG_HISTORY_COLLECTION_NAME].append(
        copy.deepcopy(expected_data[DRUG_COLLECTION_NAME][2]))
    expected_data[DRUG_COLLECTION_NAME][2]['rxNorm'] = \
        updated_data[DRUG_COLLECTION_NAME][2]['rxNorm']
    expected_data[DRUG_COLLECTION_NAME][2]['_v'] += 1

    # Outdated (phenotype) guideline is removed from drug and guidelines;
    # drug and guideline histories added
    expected_data[DRUG_HISTORY_COLLECTION_NAME].append(
        copy.deepcopy(expected_data[DRUG_COLLECTION_NAME][3]))
    del expected_data[DRUG_COLLECTION_NAME][3]['guidelines'][0]
    expected_data[DRUG_COLLECTION_NAME][3]['_v'] += 1
    expected_data[GUIDELINE_HISTORY_COLLECTION_NAME].append(
        copy.deepcopy(expected_data[GUIDELINE_COLLECTION_NAME][7]))
    del expected_data[GUIDELINE_COLLECTION_NAME][7]

    # New (phenotype) guideline is added to drug and guidelines; drug
    # history added
    expected_data[DRUG_HISTORY_COLLECTION_NAME].append(
         copy.deepcopy(expected_data[DRUG_COLLECTION_NAME][4]))
    expected_data[DRUG_COLLECTION_NAME][4]['guidelines'].append(
        ADDED_GUIDELINE_ID)
    expected_data[DRUG_COLLECTION_NAME][4]['_v'] += 1
    expected_data[GUIDELINE_COLLECTION_NAME].append(
        copy.deepcopy(updated_data[GUIDELINE_COLLECTION_NAME][8]))

    # Guideline lookupkey is updated; guideline history added (per guideline
    # change)
    expected_data[GUIDELINE_HISTORY_COLLECTION_NAME].append(
         copy.deepcopy(expected_data[GUIDELINE_COLLECTION_NAME][9]))
    expected_data[GUIDELINE_COLLECTION_NAME][9]['_v'] += 1
    expected_data[GUIDELINE_COLLECTION_NAME][9]['lookupkey'] = \
        CHANGED_LOOKUPKEYS['new.keyadded']
    expected_data[GUIDELINE_HISTORY_COLLECTION_NAME].append(
         copy.deepcopy(expected_data[GUIDELINE_COLLECTION_NAME][10]))
    expected_data[GUIDELINE_COLLECTION_NAME][10]['_v'] += 1
    expected_data[GUIDELINE_COLLECTION_NAME][10]['lookupkey'] = \
        CHANGED_LOOKUPKEYS['new.keyremoved']
    expected_data[GUIDELINE_HISTORY_COLLECTION_NAME].append(
         copy.deepcopy(expected_data[GUIDELINE_COLLECTION_NAME][11]))
    expected_data[GUIDELINE_COLLECTION_NAME][11]['_v'] += 1
    expected_data[GUIDELINE_COLLECTION_NAME][11]['lookupkey'] = \
        CHANGED_LOOKUPKEYS['new.keychanged']

    # External data is updated; guideline history added
    expected_data[GUIDELINE_HISTORY_COLLECTION_NAME].append(
         copy.deepcopy(expected_data[GUIDELINE_COLLECTION_NAME][12]))
    expected_data[GUIDELINE_COLLECTION_NAME][12]['_v'] += 1
    expected_data[GUIDELINE_COLLECTION_NAME][12]['externalData'] = \
        CHANGED_EXTERNAL_DATA['new.data-rm']
    expected_data[GUIDELINE_HISTORY_COLLECTION_NAME].append(
         copy.deepcopy(expected_data[GUIDELINE_COLLECTION_NAME][13]))
    expected_data[GUIDELINE_COLLECTION_NAME][13]['_v'] += 1
    expected_data[GUIDELINE_COLLECTION_NAME][13]['externalData'] = \
        CHANGED_EXTERNAL_DATA['new.data-change']
    expected_data[GUIDELINE_HISTORY_COLLECTION_NAME].append(
         copy.deepcopy(expected_data[GUIDELINE_COLLECTION_NAME][14]))
    expected_data[GUIDELINE_COLLECTION_NAME][14]['_v'] += 1
    expected_data[GUIDELINE_COLLECTION_NAME][14]['externalData'] = \
        CHANGED_EXTERNAL_DATA['new.data-add']

    data, _ = update_drugs(data, updated_data)

    # Adapt generated timestamps of adapted data
    expected_data[DRUG_COLLECTION_NAME][2]['_vDate'] = \
        data[DRUG_COLLECTION_NAME][2]['_vDate']
    expected_data[DRUG_COLLECTION_NAME][3]['_vDate'] = \
        data[DRUG_COLLECTION_NAME][3]['_vDate']
    expected_data[DRUG_COLLECTION_NAME][4]['_vDate'] = \
        data[DRUG_COLLECTION_NAME][4]['_vDate']
    expected_data[GUIDELINE_COLLECTION_NAME][9]['_vDate'] = \
        data[GUIDELINE_COLLECTION_NAME][9]['_vDate']
    expected_data[GUIDELINE_COLLECTION_NAME][10]['_vDate'] = \
        data[GUIDELINE_COLLECTION_NAME][10]['_vDate']
    expected_data[GUIDELINE_COLLECTION_NAME][11]['_vDate'] = \
        data[GUIDELINE_COLLECTION_NAME][11]['_vDate']
    expected_data[GUIDELINE_COLLECTION_NAME][12]['_vDate'] = \
        data[GUIDELINE_COLLECTION_NAME][12]['_vDate']
    expected_data[GUIDELINE_COLLECTION_NAME][13]['_vDate'] = \
        data[GUIDELINE_COLLECTION_NAME][13]['_vDate']
    expected_data[GUIDELINE_COLLECTION_NAME][14]['_vDate'] = \
        data[GUIDELINE_COLLECTION_NAME][14]['_vDate']

    # Makes it easier to interpret diff if test fails
    assert data[DRUG_COLLECTION_NAME] == expected_data[DRUG_COLLECTION_NAME]
    assert data[DRUG_HISTORY_COLLECTION_NAME] == \
        expected_data[DRUG_HISTORY_COLLECTION_NAME]
    assert data[GUIDELINE_COLLECTION_NAME] == \
        expected_data[GUIDELINE_COLLECTION_NAME]
    assert data[GUIDELINE_HISTORY_COLLECTION_NAME] == \
        expected_data[GUIDELINE_HISTORY_COLLECTION_NAME]