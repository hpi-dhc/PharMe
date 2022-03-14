import { HttpService } from '@nestjs/axios'
import { Injectable } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import axiosRetry from 'axios-retry'
import { lastValueFrom } from 'rxjs'
import { Repository } from 'typeorm'
import { DOMParser } from 'xmldom'
import * as xpath from 'xpath'

import { Medication } from './medications.entity'
import { MedicationsGroup } from './medicationsGroup.entity'

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
    await this.medicationRepository.delete({})
    await this.medicationsGroupRepository.delete({})
  }

  async fetchAllMedications(startPageURL: string): Promise<void> {
    await this.clearAllMedicationData()

    const medicationGroups = new Map<string, Array<Medication>>()

    axiosRetry(this.httpService.axiosRef, {
      retryDelay: axiosRetry.exponentialDelay,
    })

    let nextPageUrl = startPageURL

    while (nextPageUrl !== 'null') {
      nextPageUrl = await this.fetchMedicationPage(
        nextPageUrl,
        medicationGroups,
      )
    }

    const groups: MedicationsGroup[] = []

    for (const [groupName, medications] of medicationGroups.entries()) {
      const group = new MedicationsGroup()
      group.name = groupName
        .replace(/,/g, ', ')
        .replace(/\b\w/g, (c) => c.toUpperCase())
      group.medications = medications
      groups.push(group)
    }

    await this.medicationsGroupRepository.save(groups)
  }

  async fetchMedicationPage(
    pageURL: string,
    medicationGroups: Map<string, Array<Medication>>,
  ): Promise<string> {
    const observable = this.httpService.get(pageURL)
    const response = await lastValueFrom(observable)

    const promises = []

    for (const splMedication of response.data.data) {
      const fetchMedication = async (setid: string): Promise<void> => {
        const url = `https://dailymed.nlm.nih.gov/dailymed/services/v2/spls/${setid}.xml`

        const medObservable = this.httpService.get(url)
        const chunk = await lastValueFrom(medObservable)

        const domParser = new DOMParser()
        const xml = chunk.data
          .toString()
          .replace(/<\?.*\?>/g, '')
          .replace(/<document.*>/, '<document>')
        const doc = domParser.parseFromString(xml)

        const medication = new Medication()

        medication.name = xpath
          .select('string(//manufacturedProduct/*/name)', doc)
          .toString()
          .trim()
        medication.agents = xpath
          .select('string(//genericMedicine/name)', doc)
          .toString()
          .toLowerCase()
          .trim()
        medication.manufacturer = xpath
          .select('string(//representedOrganization/name)', doc)
          .toString()
          .trim()

        const key = this.genAgentKey(medication.agents)
        if (!key) return

        if (medicationGroups.has(key)) {
          medicationGroups.get(key).push(medication)
        } else {
          medicationGroups.set(key, [medication])
        }
      }

      promises.push(fetchMedication(splMedication.setid))
    }

    await Promise.all(promises)

    return response.data.metadata.next_page_url
  }

  async getAll(): Promise<MedicationsGroup[]> {
    return await this.medicationsGroupRepository.find({
      relations: ['medications'],
    })
  }

  async removeMedication(id: number): Promise<void> {
    this.medicationRepository.delete(id)
  }

  private genAgentKey(agentsString?: string): string {
    if (!agentsString) {
      return undefined
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
      .filter((agent) => agent.length > 2)
    agents.sort()
    return agents.join(',')
  }
}
