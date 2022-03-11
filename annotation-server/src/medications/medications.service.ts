import { Injectable } from '@nestjs/common';
import { Medication } from './medications.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DOMParser } from 'xmldom';
import * as xpath from 'xpath';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';
import axiosRetry from 'axios-retry';
import { MedicationsGroup } from './medicationsGroup.entity';

@Injectable()
export class MedicationsService {
  constructor(
    @InjectRepository(Medication)
    private medicationRepository: Repository<Medication>,
    @InjectRepository(MedicationsGroup)
    private medicationsGroupRepository: Repository<MedicationsGroup>,
    private httpService: HttpService,
  ) {}

  async clearAllMedicationData(): Promise<void> {
    await this.medicationRepository.delete({});
    await this.medicationsGroupRepository.delete({});
  }

  async fetchAllMedications(startPageURL: string): Promise<void> {
    await this.clearAllMedicationData();

    const medicationGroups = new Map<string, Array<Medication>>();

    axiosRetry(this.httpService.axiosRef, {
      retryDelay: axiosRetry.exponentialDelay,
    });

    let nextPageUrl = startPageURL;

    // console.time();

    while (nextPageUrl !== 'null') {
      // console.log(`FETCHING PAGE: ${nextPageUrl}`);
      nextPageUrl = await this.fetchMedicationPage(
        nextPageUrl,
        medicationGroups,
      );
    }

    // console.timeEnd();

    const groups: MedicationsGroup[] = [];

    for (const [groupName, medications] of medicationGroups.entries()) {
      const group = new MedicationsGroup();
      group.name = groupName
        .replace(/,/g, ', ')
        .replace(/\b\w/g, (c) => c.toUpperCase());
      group.medications = medications;
      groups.push(group);
    }

    await this.medicationsGroupRepository.save(groups);
  }

  async fetchMedicationPage(
    pageURL: string,
    medicationGroups: Map<string, Array<Medication>>,
  ): Promise<string> {
    const observable = this.httpService.get(pageURL);
    const response = await lastValueFrom(observable);

    const promises = [];

    for (const splMedication of response.data.data) {
      const fetchMedication = async (setid: string): Promise<void> => {
        const url = `https://dailymed.nlm.nih.gov/dailymed/services/v2/spls/${setid}.xml`;

        const medObservable = this.httpService.get(url);
        const chunk = await lastValueFrom(medObservable);

        const domParser = new DOMParser();
        const xml = chunk.data
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
        medication.manufacturer = xpath
          .select('string(//representedOrganization/name)', doc)
          .toString()
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
                .replace(
                  /capsules|capsule|pill|pills|coated|tablets|tablet|oral|childrens|children|adults|adult|liquidfilled/g,
                  '',
                )
                .trim(),
            )
            .filter((agent) => agent.length > 2);

          agents.sort();

          return agents.join(',');
        };

        const key = agentKey(medication.agents);
        if (!key) return;

        // const key = medication.name.toLowerCase().trim();
        if (medicationGroups.has(key)) {
          medicationGroups.get(key).push(medication);
        } else {
          medicationGroups.set(key, [medication]);
        }
      };

      promises.push(fetchMedication(splMedication.setid));
    }

    await Promise.all(promises);

    return response.data.metadata.next_page_url;
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

  async getAll(): Promise<MedicationsGroup[]> {
    return await this.medicationsGroupRepository.find({
      relations: ['medications'],
    });
  }

  async removeMedication(id: string): Promise<void> {
    this.medicationRepository.delete(id);
  }
}
