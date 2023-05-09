import copy

from update import remove_outdated_drugs
from update import add_missing_drugs
from update import update_drugs
from common.constants import GUIDELINE_COLLECTION_NAME
from common.constants import DRUG_COLLECTION_NAME
from common.constants import GUIDELINE_HISTORY_COLLECTION_NAME
from common.constants import DRUG_HISTORY_COLLECTION_NAME
from test.update_test_data import get_data
from test.update_test_data import get_updated_data

def get_guideline_ids(data):
    return list(map(
        lambda guideline: guideline['_id'],
        data[GUIDELINE_COLLECTION_NAME]
    ))

def test_remove_outdated_drugs():
    data = get_data()
    updated_data = get_updated_data()
    expected_data = copy.deepcopy(data)
    expected_data[DRUG_HISTORY_COLLECTION_NAME].append(
        expected_data[DRUG_COLLECTION_NAME].pop(0))
    for _ in range(3):
        expected_data[GUIDELINE_HISTORY_COLLECTION_NAME].append(
            expected_data[GUIDELINE_COLLECTION_NAME].pop(0)
        )
    data, _ = remove_outdated_drugs(data, updated_data)
    assert data == expected_data

def test_add_missing_drugs():
    data = get_data()
    updated_data = get_updated_data()
    expected_data = copy.deepcopy(data)
    expected_data[DRUG_COLLECTION_NAME].append(
        copy.deepcopy(updated_data[DRUG_COLLECTION_NAME][1]))
    expected_data[GUIDELINE_COLLECTION_NAME] += copy.deepcopy(
        updated_data[GUIDELINE_COLLECTION_NAME][0:2])
    data, _ = add_missing_drugs(data, updated_data)
    assert data == expected_data

def test_update_drugs():
    data = get_data()
    updated_data = get_updated_data()

    # RxNorm is updated; drug history added
    expected_data = copy.deepcopy(data)
    expected_data[DRUG_HISTORY_COLLECTION_NAME].append(
        copy.deepcopy(expected_data[DRUG_COLLECTION_NAME][2]))
    expected_data[DRUG_COLLECTION_NAME][2]['rxNorm'] = \
        updated_data[DRUG_COLLECTION_NAME][2]['rxNorm']
    expected_data[DRUG_COLLECTION_NAME][2]['_v'] += 1
    data, _ = update_drugs(data, updated_data)
    timestamp = data[DRUG_COLLECTION_NAME][2]['_vDate']
    expected_data[DRUG_COLLECTION_NAME][2]['_vDate'] = timestamp

    # Outdated (phenotype) guideline is removed from drug and guidelines;
    # drug and guideline histories added
    # TODO

    # New (phenotype) guideline is added to drug and guidelines; drug and
    # guideline histories added
    # TODO

    # Guideline lookupkey is updated; guideline history added
    # TODO

    # Outdated external data is removed from guideline; guideline history added
    # TODO - test with one outdated and two outdated

    # New external data is added to guideline; guideline history added
    # TODO

    # External data is updated; guideline history added
    # TODO

    assert data == expected_data
