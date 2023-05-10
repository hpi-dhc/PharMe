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

def build_guideline(id, phenotypes=None):
    phenotypes = phenotypes if phenotypes != None \
        else { 'HLA-B': [ '*58:01 positive' ]}
    return {
        '_id': id,
        '_v': 1,
        '_vDate': get_timestamp(),
        'phenotypes': phenotypes,
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

def build_guidelines(guideline_ids, phenotypes):
    return list(map(
        lambda guideline_id: build_guideline(guideline_id,
            phenotypes=phenotypes[guideline_id] if guideline_id in phenotypes \
                else None),
        guideline_ids
    ))

def build_drugs(drug_guideline_map, rx_norms):
    return list(map(
        lambda drug_name: build_drug(drug_name, drug_guideline_map[drug_name],
            rx_norm=rx_norms[drug_name] if drug_name in rx_norms else None),
        drug_guideline_map
    ))

def build_data(drug_guideline_map, rx_norms={}, phenotypes={}):
    guideline_ids = [id for ids in drug_guideline_map.values() for id in ids]
    drugs = build_drugs(drug_guideline_map, rx_norms)
    guidelines = build_guidelines(guideline_ids, phenotypes)
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

@pytest.fixture
def data():
    drug_guideline_map = {
        REMOVED_DRUG: ['old.rm-drug.1', 'old.rm-drug.2', 'old.rm-drug.3'],
        UNCHANGED_DRUG: ['old.unchanged.1', 'old.unchanged.2'],
        RX_NORM_CHANGED_DRUG: ['old.rx-change.1', 'old.rx-change.2'],
        GUIDELINE_REMOVED_DRUG: ['old.rm-guideline', 'old.keep-guideline'],
    }
    rx_norms = { RX_NORM_CHANGED_DRUG: 'rx.old' }
    phenotypes = {
        'old.rm-guideline': { 'CYP2D6': [ 'Poor metabolizer' ]},
        'old.unchanged.2': {
            'CYP2D6': [ 'Indeterminate' ],
            'CYP2C19': [ 'Intermediate Metabolizer' ]},
    }
    return build_data(drug_guideline_map, rx_norms, phenotypes)

@pytest.fixture
def updated_data():
    drug_guideline_map = {
        UNCHANGED_DRUG: ['new.unchanged.1', 'new.unchanged.2'],
        ADDED_DRUG: ['new.add-drug.1', 'new.add-drug.2'],
        RX_NORM_CHANGED_DRUG: ['new.rx-change.1', 'new.rx-change.2'],
        GUIDELINE_REMOVED_DRUG: ['new.keep-guideline'],
    }
    rx_norms = { RX_NORM_CHANGED_DRUG: 'rx.new' }
    phenotypes = {
        'new.unchanged.2': {
            'CYP2D6': [ 'Indeterminate' ],
            'CYP2C19': [ 'Intermediate Metabolizer' ]},
    }
    return build_data(drug_guideline_map, rx_norms, phenotypes)

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
    data, _ = update_drugs(data, updated_data)

    # RxNorm is updated; drug history added
    expected_data[DRUG_HISTORY_COLLECTION_NAME].append(
        copy.deepcopy(expected_data[DRUG_COLLECTION_NAME][2]))
    expected_data[DRUG_COLLECTION_NAME][2]['rxNorm'] = \
        updated_data[DRUG_COLLECTION_NAME][2]['rxNorm']
    expected_data[DRUG_COLLECTION_NAME][2]['_v'] += 1
    expected_data[DRUG_COLLECTION_NAME][2]['_vDate'] = \
        data[DRUG_COLLECTION_NAME][2]['_vDate']

#     # Outdated (phenotype) guideline is removed from drug and guidelines;
#     # drug and guideline histories added
#     expected_data[DRUG_HISTORY_COLLECTION_NAME].append(
#         copy.deepcopy(expected_data[DRUG_COLLECTION_NAME][3]))
#     del expected_data[DRUG_COLLECTION_NAME][3]['guidelines'][1]
#     expected_data[DRUG_COLLECTION_NAME][3]['_v'] += 1
#     expected_data[DRUG_COLLECTION_NAME][3]['_vDate'] = \
#         data[DRUG_COLLECTION_NAME][3]['_vDate']
#     expected_data[GUIDELINE_HISTORY_COLLECTION_NAME].append(
#         copy.deepcopy(expected_data[GUIDELINE_COLLECTION_NAME][8]))
#     del expected_data[GUIDELINE_COLLECTION_NAME][8]

#     # New (phenotype) guideline is added to drug and guidelines; drug and
#     # guideline histories added
#     # TODO

#     # Guideline lookupkey is updated; guideline history added
#     # TODO

#     # Outdated external data is removed from guideline; guideline history added
#     # TODO

#     # New external data is added to guideline; guideline history added
#     # TODO

#     # External data is updated; guideline history added
#     # TODO

#     assert data == expected_data
