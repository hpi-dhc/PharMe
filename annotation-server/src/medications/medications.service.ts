import { Injectable, NotFoundException } from '@nestjs/common';
import { Medication } from './medications.entity';
import { Ingredient } from './ingredients.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as https from 'https';
import { DOMParser } from 'xmldom';
import * as xpath from 'xpath';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom, map } from 'rxjs';
import { constants } from 'buffer';

import { ibuprofenSetIDs } from './medications';

@Injectable()
export class MedicationsService {
  constructor(
    @InjectRepository(Medication)
    private medicationRepository: Repository<Medication>,
    @InjectRepository(Ingredient)
    private ingredientRepository: Repository<Ingredient>,
    private httpService: HttpService,
  ) {}

  async fetchMedications(): Promise<void> {
    const medicationGroups = new Map<string, Array<Medication>>();

    let nextPageUrl =
      'https://dailymed.nlm.nih.gov/dailymed/services/v2/spls.json';

    let counter = 1;

    console.time();

    while (nextPageUrl !== 'null' && counter < 10) {
      const observable = this.httpService.get(nextPageUrl);

      const response = await lastValueFrom(observable);

      const promises = [];

      for (const splMedication of ibuprofenSetIDs) {
        const fetchMedication = async (setid: string): Promise<void> => {
          const url = `https://dailymed.nlm.nih.gov/dailymed/services/v2/spls/${setid}.xml`;

          const chunk = await new Promise((resolve, reject) => {
            https
              .get(url, (res) => {
                const data = [];
                res.on('data', (chunk) => {
                  data.push(chunk);
                });

                res.on('end', () => {
                  resolve(Buffer.concat(data));
                });
              })
              .on('error', (error) => {
                reject(error);
              });
          });

          const domParser = new DOMParser();
          const xml = chunk
            .toString()
            .replace(/<\?.*\?>/g, '')
            .replace(/<document.*>/, '<document>');
          const doc = domParser.parseFromString(xml);

          const medication = new Medication();

          medication.name = xpath
            .select('string(//manufacturedProduct/*/name)', doc)
            .toString()
            .trim();
          medication.agents = xpath
            .select('string(//genericMedicine/name)', doc)
            .toString()
            .toLowerCase()
            .trim();

          const agentKey = (agentsString?: string): string => {
            if (!agentsString) {
              return undefined;
            }

            const agents = agentsString
              .toLowerCase()
              .split(/,|and/)
              .map((agent) =>
                agent
                  .trim()
                  .split(' ')
                  .filter((agent) => !/\d/.test(agent) && agent.length > 2)
                  .join('')
                  .replace(/[^a-zA-Z]/g, ''),
              )
              .filter((agent) => !!agent);

            agents.sort();

            return agents.join(',');
          };

          const key = agentKey(medication.agents);

          // const key = medication.name.toLowerCase().trim();
          if (medicationGroups.has(key)) {
            medicationGroups.get(key).push(medication);
          } else {
            medicationGroups.set(key, [medication]);
            console.log(key);
          }
        };

        promises.push(fetchMedication(splMedication));
      }

      await Promise.all(promises);

      nextPageUrl = 'null'; // response.data.metadata.next_page_url;
      console.log(`counter: ${counter}, size: ${medicationGroups.size}`);
      counter++;
    }

    console.log(medicationGroups);
    console.timeEnd();
    console.log(medicationGroups.size);
  }

  /*
  async findOne(id: string): Promise<Medication> {
    const mappings = await this.rxNormMappingRepository.find({
      where: {
        setid: id.toLowerCase(),
      },
      relations: ['medication'],
    });

    if (!mappings.length) {
      throw new NotFoundException('Id could not be found in RxNormMappings!');
    }

    if (mappings[0].medication) {
      const medication = await this.medicationRepository.findOne(
        mappings[0].medication.id,
        {
          relations: ['ingredients'],
        },
      );

      return medication;
    }
  }
  */

  async removeMedication(id: string): Promise<void> {
    this.medicationRepository.delete(id);
  }
}
