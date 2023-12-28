import copy

from common.get_data import get_data
from common.get_data import get_information_key
from common.get_data import get_guidelines_by_ids
from common.get_data import get_phenotype_value_lengths
from common.get_data import get_phenotype_value
from common.get_data import get_phenotype_key
from common.write_data import write_data
from common.constants import DRUG_COLLECTION_NAME
from common.constants import GUIDELINE_COLLECTION_NAME
from common.constants import SCRIPT_POSTFIXES
from common.cpic_data import get_phenotype_map
from common.remove_history import remove_history
from common.mongo import get_object_id

# Migrate data
def reset_data():
    data = remove_history(get_data())
    write_data(data, postfix=SCRIPT_POSTFIXES['reset'])

if __name__ == '__main__':
    reset_data()