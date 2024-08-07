import copy

from common.get_data import get_data, get_drug_by_name, get_phenotype
from common.get_data import get_guidelines_by_ids
from common.get_data import get_phenotype_key
from common.get_data import get_lookupkey_key
from common.get_data import get_information_key
from common.mongo import get_timestamp, get_object_id
from common.constants import DRUG_COLLECTION_NAME
from common.constants import GUIDELINE_COLLECTION_NAME
from common.constants import NON_RESULT_PHENOTYPES
from common.constants import get_history_collection_name
from common.constants import SCRIPT_POSTFIXES
from common.write_data import write_data, write_log

VERBOSE = False

def get_single_source(drug, data):
    collected_external_data = []
    guidelines = get_guidelines_by_ids(data, drug['guidelines'])
    for guideline in guidelines:
        collected_external_data += guideline['externalData']
    sources = set(list(map(
        lambda external_data: external_data['source'],
        collected_external_data
    )))
    if len(sources) > 1:
        raise Exception(f'Guideline for {get_phenotype_key(guideline)} has ' \
                        'multiple sources but should have max. 1')
    if len(sources) == 0:
        return '_missing source_'
    source = sources.pop()
    return source

def get_source(drug, data, updated_drug, updated_external_data):
    former_source = get_single_source(drug, data)
    updated_source = get_single_source(updated_drug, updated_external_data)
    return former_source if former_source == updated_source \
        else f'{updated_source}, formerly {former_source}'


def get_drug_names(data):
    return list(map(
        lambda drug: drug['name'],
        data[DRUG_COLLECTION_NAME]
    ))

def log_item(text, level = 0):
    prefix = '  ' * level
    text = f'{prefix}* {text}'
    if VERBOSE:
        print(text)
    return f'{text}\n'

def remove_from_collection(data, collection_name, item_ids):
    history_collection_name = get_history_collection_name(collection_name)
    data[history_collection_name] += list(filter(
        lambda item: item['_id'] in item_ids,
        data[collection_name]
    ))
    data[collection_name] = list(filter(
        lambda item: item['_id'] not in item_ids,
        data[collection_name]
    ))
    return data

def update_version(data, collection_name, item):
    history_item = copy.deepcopy(item)
    history_item['_ref'] = history_item['_id']
    history_item['_id'] = get_object_id()
    data[get_history_collection_name(collection_name)].append(history_item)
    item['_v'] += 1
    item['_vDate'] = get_timestamp()

# As each recommendation returned by the CPIC API holds a drugId, we assume
# here that drugs and guidelines have a 1 to n relationship, i.e., one guideline
# is only referenced by one drug and can be removed when the drug is removed
def remove_outdated_drugs(data, updated_external_data):
    remove_log = []
    stale_drug_ids = []
    stale_guideline_ids = []
    updated_drug_name_list = get_drug_names(updated_external_data)
    for drug in data[DRUG_COLLECTION_NAME]:
        drug_name = drug['name']
        if not drug_name in updated_drug_name_list:
            stale_drug_ids.append(drug['_id'])
            drug_guidelines = drug['guidelines']
            stale_guideline_ids += drug_guidelines
            remove_log.append(log_item(
                f'{drug_name} (with {len(drug_guidelines)} guideline(s) ' \
                    f'from {get_single_source(drug, data)})'))
    data = remove_from_collection(data, DRUG_COLLECTION_NAME, stale_drug_ids)
    data = remove_from_collection(
        data, GUIDELINE_COLLECTION_NAME, stale_guideline_ids)
    return data, remove_log

def add_missing_drugs(data, updated_external_data):
    add_log = []
    present_drug_name_list = get_drug_names(data)
    for drug in updated_external_data[DRUG_COLLECTION_NAME]:
        drug_name = drug['name']
        if not drug_name in present_drug_name_list:
            drug_guidelines = get_guidelines_by_ids(
                updated_external_data, drug['guidelines'])
            data[DRUG_COLLECTION_NAME].append(drug)
            data[GUIDELINE_COLLECTION_NAME] += drug_guidelines
            add_log.append(log_item(
                f'{drug_name} ({get_single_source(drug, data)})'
            ))
    return data, add_log

def get_guideline_phenotypes(guidelines):
    guideline_phenotypes = []
    for guideline in guidelines:
        phenotype_key = get_phenotype_key(guideline)
        if phenotype_key in guideline_phenotypes:
            raise Exception('Phenotypes should be unique per drug guideline!')
        guideline_phenotypes.append(phenotype_key)
    return guideline_phenotypes

def get_stale_guidelines(guidelines, updated_guidelines):
    updated_guideline_phenotypes = get_guideline_phenotypes(updated_guidelines)
    stale_guidelines = list(filter(
        lambda guideline: get_phenotype_key(guideline) not in \
            updated_guideline_phenotypes,
        guidelines
    ))
    return stale_guidelines

def remove_outdated_guidelines(data, drug, guidelines, updated_guidelines):
    remove_log = []
    stale_guidelines = get_stale_guidelines(guidelines, updated_guidelines)
    stale_guideline_ids = list(map(
        lambda guideline: guideline['_id'],
        stale_guidelines
    ))
    if len(stale_guidelines) > 0:
        data = remove_from_collection(
            data, GUIDELINE_COLLECTION_NAME, stale_guideline_ids)
        update_version(data, DRUG_COLLECTION_NAME, drug)
        drug['guidelines'] = list(filter(
            lambda guideline_id: guideline_id not in stale_guideline_ids,
            drug['guidelines']
        ))
        remove_log += list(map(
            lambda guideline: log_item(
                f'Removed guideline for {get_phenotype_key(guideline)}',
                level=1),
            stale_guidelines
        ))
    return remove_log

def get_external_data_key(guideline):
    return ' '.join(sorted(list(map(
        lambda external_data_item: get_information_key(external_data_item),
        guideline['externalData']
    ))))

def update_guideline_information(
        data, guideline, updated_guideline, information_name, get_key):
    guideline_updates = []
    information_key = get_key(guideline)
    updated_information_key = get_key(updated_guideline)
    if information_key != updated_information_key:
        update_version(data, GUIDELINE_COLLECTION_NAME, guideline)
        guideline[information_name] = copy.deepcopy(
            updated_guideline[information_name])
        guideline_updates += [
            log_item(f'Updated {information_name}', level=2),
            log_item(f'_Before:_ {information_key}', level=3),
            log_item(f'_Now:_ {updated_information_key}', level=3),
        ]
        
    return guideline_updates

def update_guidelines(data, guidelines, updated_guidelines):
    update_log = []
    for guideline in guidelines:
        guideline_updates = []
        phenotype_key = get_phenotype_key(guideline)
        # To not be dependent on removal and addition of guidelines
        updated_phenotypes = list(map(
            lambda guideline: get_phenotype_key(guideline),
            updated_guidelines))
        if not phenotype_key in updated_phenotypes:
            continue
        guideline_log_item = log_item(phenotype_key, level=1)
        updated_guideline = next(
            updated_guideline for updated_guideline in updated_guidelines \
                if get_phenotype_key(updated_guideline) == phenotype_key)
        # Test if lookupkey changed; this is legacy code that removes multiples
        # of one lookupkey, as now the phenotype key also includes the
        # lookupkey; everything else will be covered by removing or adding
        # phenotype guidelines
        guideline_updates += update_guideline_information(data, guideline, \
            updated_guideline, 'lookupkey', get_lookupkey_key)
        # Test if external data changed
        guideline_updates += update_guideline_information(data, guideline, \
            updated_guideline, 'externalData', get_external_data_key)
        if len(guideline_updates) > 0:
            update_log.append(guideline_log_item)
            update_log += guideline_updates
    return update_log

def add_missing_guidelines(data, drug, guidelines, updated_guidelines):
    add_log = []
    present_guideline_phenotypes = get_guideline_phenotypes(guidelines)
    new_guidelines = list(filter(
        lambda guideline: get_phenotype_key(guideline) not in \
            present_guideline_phenotypes,
        updated_guidelines
    ))
    new_guideline_ids = list(map(
        lambda guideline: guideline['_id'],
        new_guidelines
    ))
    if len(new_guidelines) > 0:
        update_version(data, DRUG_COLLECTION_NAME, drug)
        drug['guidelines'] += new_guideline_ids
        data[GUIDELINE_COLLECTION_NAME] += new_guidelines
        add_log += list(map(
            lambda guideline: log_item(
                f'Added guideline for {get_phenotype_key(guideline)}',
                level=1),
            new_guidelines
        ))
    return add_log

def get_new_genes(stale_guideline, updated_guideline):
    return list(filter(
        lambda gene: gene not in stale_guideline['phenotypes'],
        updated_guideline['phenotypes']))

def lookups_for_phenotype_changed(stale_guideline, updated_guideline):
    same_phenotype = get_phenotype(stale_guideline) == \
        get_phenotype(updated_guideline)
    lookups_changed = get_phenotype_key(stale_guideline) != \
        get_phenotype_key(updated_guideline)
    return same_phenotype and lookups_changed

def new_genes_are_non_results(stale_guideline, updated_guideline):
    stale_phenotype = get_phenotype_key(stale_guideline)
    updated_phenotype = get_phenotype_key(updated_guideline)
    if stale_phenotype in updated_phenotype:
        new_genes = get_new_genes(stale_guideline, updated_guideline)
        non_results = list(filter(
            lambda gene: any(map(
                lambda non_result_value: non_result_value in \
                    updated_guideline['phenotypes'][gene],
                NON_RESULT_PHENOTYPES)),
            new_genes
        ))
        return len(new_genes) == len(non_results)

def get_annotation_transfer_text(stale_guideline, updated_guideline, reason):
    stale_phenotype = get_phenotype_key(stale_guideline)
    updated_phenotype = get_phenotype_key(updated_guideline)
    update_text = f'Transferred annotations from {stale_phenotype} to ' \
        f'{updated_phenotype} because of {reason}'
    external_data_changed = len(stale_guideline['externalData']) != \
        len(updated_guideline['externalData'])
    if not external_data_changed:
        for index, external_data in enumerate(stale_guideline['externalData']):
            stale_key = get_information_key(external_data)
            new_genes = get_new_genes(stale_guideline, updated_guideline)
            updated_data_without_new_genes = copy.deepcopy(
                updated_guideline['externalData'][index])
            for gene in new_genes:
                del updated_data_without_new_genes['implications'][gene]
            updated_key = get_information_key(updated_data_without_new_genes)
            external_data_changed = stale_key != updated_key
    if external_data_changed:
        update_text += '; external data was updated, PLEASE REVIEW ANNOTATIONS'
    else:
        update_text += ' (no external data change)'
    return log_item(update_text, level=1)

# Changes updated_guidelines in-place
def transfer_annotations(guidelines, updated_guidelines):
    update_log = []
    stale_guidelines = get_stale_guidelines(guidelines, updated_guidelines)
    for stale_guideline in stale_guidelines:
        for updated_guideline in updated_guidelines:
            transfer_because_of_new_genes = new_genes_are_non_results(
                stale_guideline,
                updated_guideline,
            )
            transfer_because_of_lookups = (not transfer_because_of_new_genes) \
                and lookups_for_phenotype_changed(
                    stale_guideline,
                    updated_guideline,
                )
            if transfer_because_of_new_genes or transfer_because_of_lookups:
                reason = 'unknown reason'
                if transfer_because_of_new_genes:
                    reason = 'added genes'
                if transfer_because_of_lookups:
                    reason = 'changed lookupkey'
                updated_guideline['annotations'] = \
                    stale_guideline['annotations']
                update_text = get_annotation_transfer_text(
                    stale_guideline, updated_guideline, reason)
                update_log.append(update_text)
    return update_log

def update_drugs(data, updated_external_data):
    update_log = []
    updated_drugs_map = {}
    for drug in updated_external_data[DRUG_COLLECTION_NAME]:
        updated_drugs_map[drug['name']] = drug
    for current_drug in data[DRUG_COLLECTION_NAME]:
        drug_name = current_drug['name']
        # To not be dependent on removal of outdated drugs before calling
        # update, check if drug present in updated drugs
        if not drug_name in updated_drugs_map:
            continue

        updated_drug = get_drug_by_name(updated_external_data, drug_name)
        source = get_source(
            current_drug,
            data,
            updated_drug,
            updated_external_data,
        )
        drug_log_item = log_item(
            f'{drug_name} ' \
            f'({source})'
        )
        updated_drug = updated_drugs_map[drug_name]
        drug_updates = []

        # Test if RxNorm changed
        current_rxNorm = current_drug['rxNorm']
        updated_rxNorm = updated_drug['rxNorm']
        if current_rxNorm != updated_rxNorm:
            update_version(data, DRUG_COLLECTION_NAME, current_drug)
            current_drug['rxNorm'] = updated_drug['rxNorm']
            drug_updates.append(log_item(
                f'Changed RxNorm from {current_rxNorm} to {updated_rxNorm}',
                level=1
            ))

        # Update guidelines; changes are done in place
        current_guidelines = get_guidelines_by_ids(
            data, current_drug['guidelines'])
        updated_guidelines = get_guidelines_by_ids(
            updated_external_data, updated_drug['guidelines'])
        drug_updates += transfer_annotations(
            current_guidelines, updated_guidelines
        )
        drug_updates += remove_outdated_guidelines(
            data, current_drug, current_guidelines, updated_guidelines)
        drug_updates += \
            update_guidelines(data, current_guidelines, updated_guidelines)
        drug_updates += add_missing_guidelines(
            data, current_drug, current_guidelines, updated_guidelines)

        if len(drug_updates) != 0:
            update_log.append(drug_log_item)
            update_log += drug_updates

    return data, update_log

def add_log_content(log_content, new_content):
    if len(new_content) == 0:
        log_content.append('_None_\n')
    else:
        log_content += new_content
    return log_content

def update_data():
    data = get_data()
    updated_external_data = get_data(argv_index = 2)
    log_content = ['# Update Log\n']

    data, remove_log = remove_outdated_drugs(data, updated_external_data)
    data, update_log = update_drugs(data, updated_external_data)
    data, add_log = add_missing_drugs(data, updated_external_data)

    log_content.append('\n## Added drugs\n\n')
    log_content = add_log_content(log_content, add_log)
    log_content.append('\n## Updated drugs\n\n')
    log_content = add_log_content(log_content, update_log)
    log_content.append('\n## Removed drugs\n\n')
    log_content = add_log_content(log_content, remove_log)

    write_data(data, postfix=SCRIPT_POSTFIXES['update'])
    write_log(log_content, postfix=SCRIPT_POSTFIXES['update'])

if __name__ == '__main__':
    update_data()