#!/usr/bin/env python3

import argparse, xmltodict

def minimize(xml_in: str, xml_out: str, keep: list[str]):
    with open(xml_in, 'r') as fp:
        xml = xmltodict.parse(fp.read())  

    for drug in xml['drugbank']['drug']:
        dels = [key for key in drug.keys() if key not in keep]
        for key in dels:
            del drug[key]

    xml_string = xmltodict.unparse(xml)
    with open(xml_out, 'w') as fp:
        fp.write(xml_string)

if __name__ == '__main__':
    parser = argparse.ArgumentParser('Minimize DrugBank XML')
    parser.add_argument('xml_in', type=str)
    parser.add_argument('xml_out', type=str)
    parser.add_argument('-p', '--preserve', type=str,
            help='Comma-separated list of keys to preserve; defaults to what is needed',
            default='name,description,international-brands,external-identifiers')

    args = parser.parse_args()
    minimize(args.xml_in, args.xml_out, args.preserve.split(','))
