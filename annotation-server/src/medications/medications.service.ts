import { Injectable, NotFoundException } from '@nestjs/common';
import { Medication } from './medications.entity';
import { RxNormMapping } from './rxnormmappings.entity';
import { Ingredient } from './ingredients.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as https from 'https';
import { DOMParser } from 'xmldom';
import * as xpath from 'xpath';

@Injectable()
export class MedicationsService {
  constructor(
    @InjectRepository(RxNormMapping)
    private rxNormMappingRepository: Repository<RxNormMapping>,
    @InjectRepository(Medication)
    private medicationRepository: Repository<Medication>,
    @InjectRepository(Ingredient)
    private ingredientRepository: Repository<Ingredient>,
  ) {}

  async getAll(): Promise<void> {
    const mappings = await this.rxNormMappingRepository.find();
    for(const mapping of mappings){
      console.log(`Fetching ${mapping.setid}.`);
      await this.findOne(mapping.setid);
    }
  }

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

    const url = `https://dailymed.nlm.nih.gov/dailymed/services/v2/spls/${id}.xml`;

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
    const xml = chunk.toString().replace(/<\?.*\?>/g, '').replace(/<document.*>/, '<document>');
    const doc = domParser.parseFromString(xml);

    const medication = new Medication();

    // TODO quantities might be floats

    medication.name = xpath.select("string(//manufacturedProduct/*/name)", doc).toString();
    medication.manufacturer = xpath.select("string(//representedOrganisation/name)", doc).toString();
    medication.agents = xpath.select("string(//genericMedicine/name)", doc).toString();
    medication.numeratorQuantity = xpath.select('string(//manufacturedProduct/*/asContent/quantity/numerator/@value)', doc).toString();
    medication.numeratorUnit = xpath.select('string(//manufacturedProduct/*/asContent/quantity/numerator/@unit)', doc).toString();
    medication.denominatorQuantity = xpath.select('string(//manufacturedProduct/*/asContent/quantity/denominator/@value)', doc).toString();
    medication.denominatorUnit = xpath.select('string(//manufacturedProduct/*/asContent/quantity/denominator/@unit)', doc).toString();

    const ingredients: Ingredient[] = [];
    for (const xmlIngredient of xpath.select("//manufacturedProduct/*/ingredient", doc)) {
      const ingredient = new Ingredient();

      const ingredientDoc = domParser.parseFromString(xmlIngredient.toString());

      if(xpath.select("//quantity", ingredientDoc).length !== 0){
        ingredient.numeratorQuantity = xpath.select("string(//quantity/numerator/@value)", ingredientDoc).toString();
        ingredient.numeratorUnit = xpath.select("string(//quantity/numerator/@unit)", ingredientDoc).toString();
        ingredient.denominatorQuantity = xpath.select("string(//quantity/denominator/@value)", ingredientDoc).toString();
        ingredient.denominatorUnit = xpath.select("string(//quantity/denominator/@unit)", ingredientDoc).toString();
      }

      ingredient.ingredient = xpath.select("string(//ingredientSubstance/name)", ingredientDoc).toString();

      ingredients.push(ingredient);
    }

    medication.ingredients = ingredients;

    const rxNormMappings = await this.rxNormMappingRepository.find({
      where: {
        setid: id,
      },
    });

    medication.rxNormMappings = rxNormMappings;

    return await this.medicationRepository.save(medication);
  }

  async removeMedication(id: string): Promise<void> {
    this.medicationRepository.delete(id);
  }
}
