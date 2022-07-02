import { spawn } from 'child_process';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import * as JSONStream from 'JSONStream';
import {
    FindOptionsWhere,
    FindManyOptions,
    FindOneOptions,
    In,
    IsNull,
    Not,
    Repository,
    FindOptionsOrderValue,
} from 'typeorm';

import { PatchBodyDto } from '../common/dtos/patch-body.dto';
import { fetchSpreadsheetCells } from '../common/utils/google-sheets';
import { FetchTarget } from '../fetch-dates/fetch-date.entity';
import { FetchDatesService } from '../fetch-dates/fetch-dates.service';
import { DrugDto } from './dtos/drugbank.dto';
import { Medication, MedicationSearchView } from './medication.entity';

@Injectable()
export class MedicationsService {
    private readonly logger = new Logger(MedicationsService.name);

    constructor(
        private configService: ConfigService,
        @InjectRepository(Medication)
        private medicationRepository: Repository<Medication>,
        private fetchDatesService: FetchDatesService,
    ) {}

    async findAll(
        limit: number,
        offset: number,
        search: string,
        sortBy: string,
        orderBy: FindOptionsOrderValue,
        withGuidelines: boolean,
        getGuidelines: boolean,
        onlyIds: boolean,
    ): Promise<Medication[]> {
        if (onlyIds) return this.getAllIds();

        const whereClause: FindOptionsWhere<Medication> = {};
        const findOptions = <FindManyOptions<Medication>>{
            where: whereClause,
            take: limit,
            skip: offset,
            order: { [sortBy]: orderBy },
        };

        if (search) {
            const matchingIds = await this.findIdsMatching(search);
            whereClause.id = In(matchingIds);
        }

        if (withGuidelines) whereClause.guidelines = { id: Not(IsNull()) };

        if (getGuidelines) {
            findOptions.relations = [
                'guidelines',
                'guidelines.phenotype.geneResult',
                'guidelines.phenotype.geneSymbol',
            ];
        }

        return await this.medicationRepository.find(findOptions);
    }

    async getAllIds(): Promise<Medication[]> {
        return await this.medicationRepository.find({ select: ['id'] });
    }

    async findOne(id: number, getGuidelines: boolean): Promise<Medication> {
        const findOptions: FindOneOptions<Medication> = { where: { id: id } };

        if (getGuidelines) {
            findOptions.relations = [
                'guidelines',
                'guidelines.phenotype.geneResult',
                'guidelines.phenotype.geneSymbol',
            ];
        }

        return await this.medicationRepository.findOneOrFail(findOptions);
    }

    getOne(options: FindOneOptions<Medication>): Promise<Medication> {
        return this.medicationRepository.findOneOrFail(options);
    }

    async fetchAllMedications(): Promise<void> {
        await this.clearAllMedicationData();
        const jsonPath = await this.getJSONfromZip();
        this.logger.log('Extracting medications from JSON ...');
        const drugs = await this.getDataFromJSON(jsonPath);
        this.logger.log('Writing to database ...');
        const medications = drugs.map((drug) => Medication.fromDrug(drug));
        const savedMedications = await this.medicationRepository.save(
            medications,
        );
        await this.fetchDatesService.set(FetchTarget.MEDICATIONS);
        this.logger.log(
            `Successfully saved ${savedMedications.length} medications!`,
        );
    }

    async supplementSheetData(): Promise<void> {
        this.logger.log('Fetching medication data from Google Sheet ...');
        const [names, drugclasses, indications] = await fetchSpreadsheetCells(
            this.configService.get<string>('GOOGLESHEET_ID'),
            this.configService.get<string>('GOOGLESHEET_APIKEY'),
            [
                this.configService.get<string>('GOOGLESHEET_RANGE_MEDICATIONS'),
                this.configService.get<string>('GOOGLESHEET_RANGE_DRUGCLASSES'),
                this.configService.get<string>('GOOGLESHEET_RANGE_INDICATIONS'),
            ],
        );

        const updateQueries = new Array<Promise<void>>();
        const updateMedication = async (
            name: string,
            drugclass?: string,
            indication?: string,
        ) => {
            const medication = await this.medicationRepository.findOne({
                where: { name },
            });
            if (!medication) return;
            medication.drugclass = drugclass;
            medication.indication = indication;
            await this.medicationRepository.save(medication);
        };

        for (let row = 0; row < names.length; row++) {
            const drugclass = drugclasses[row]?.[0].value;
            const indication = indications[row]?.[0].value;
            const name = names[row][0].value;
            if (!name || (!drugclass && !indication)) continue;
            updateQueries.push(updateMedication(name, drugclass, indication));
        }

        await Promise.all(updateQueries);
        this.logger.log('Successfully supplemented matching data!');
    }

    async getLastUpdate(): Promise<Date | undefined> {
        return this.fetchDatesService.get(FetchTarget.MEDICATIONS);
    }

    async clearAllMedicationData(): Promise<void> {
        await this.medicationRepository.delete({});
    }

    async hasData(): Promise<boolean> {
        return (await this.medicationRepository.count()) > 0;
    }

    async patch(patch: PatchBodyDto<Medication>): Promise<void> {
        await Promise.all(
            patch.map(({ id, ...update }) =>
                this.medicationRepository.update(id, update),
            ),
        );
    }

    getJSONfromZip(): Promise<string> {
        const jsonPath = path.join(os.tmpdir(), 'drugbank-data.json');
        const proc = getOsSpecificPyProcess(this.configService);

        proc.on('error', (error) => {
            this.logger.error(error);
        });
        proc.stdout.on('data', (data: string) => {
            this.logger.log(data.toString().replace(/\n\r?/, ''));
        });
        proc.stderr.on('data', (data: string) => {
            this.logger.error(data.toString().replace(/\n\r?/, ''));
        });
        return new Promise((resolve, reject) => {
            proc.on('exit', (code) => {
                if (code === 0) resolve(jsonPath);
                else reject(`Subprocess exited with ${code}.`);
            });
        });

        function getOsSpecificPyProcess(
            configService: ConfigService<Record<string, unknown>, false>,
        ) {
            if (process.platform == 'win32')
                return spawn('python', [
                    path.join(__dirname, './scripts/zipped-xml-to-json'),
                    configService.get<string>('DRUGBANK_ZIP'),
                    configService.get<string>('DRUGBANK_XML'),
                    jsonPath,
                ]);

            return spawn(path.join(__dirname, './scripts/zipped-xml-to-json'), [
                configService.get<string>('DRUGBANK_ZIP'),
                configService.get<string>('DRUGBANK_XML'),
                jsonPath,
            ]);
        }
    }

    getDataFromJSON(path: string): Promise<DrugDto[]> {
        const fileStream = fs.createReadStream(path);
        const jsonStream = fileStream.pipe(JSONStream.parse('drugbank.drug.*'));
        const drugs: Array<DrugDto> = [];
        const clearLine = () => {
            process.stdout.write(`\r${String.fromCharCode(27)}[0J`);
        };
        jsonStream.on('data', (drug: DrugDto) => {
            if (!(drugs.length % 50)) {
                clearLine();
                process.stdout.write(`${drugs.length} drugs parsed ...`);
            }
            drugs.push(drug);
        });
        return new Promise<DrugDto[]>((resolve, reject) => {
            fileStream.on('error', (error) => {
                clearLine();
                reject(error);
            });
            jsonStream.on('error', (error) => {
                clearLine();
                reject(error);
            });
            jsonStream.on('end', () => {
                clearLine();
                resolve(drugs);
            });
        });
    }

    private async findIdsMatching(search: string): Promise<number[]> {
        const queryRes = await this.medicationRepository
            .createQueryBuilder('medication')
            .select([
                'medication.id',
                'medication.name',
                'medication.description',
                'medication.drugclass',
                'medication.indication',
            ])
            .leftJoinAndSelect(
                MedicationSearchView,
                'searchView',
                'searchView.id = medication.id',
            )
            .where('searchView.searchString ilike :searchString', {
                searchString: `%${search}%`,
            })
            .orderBy('searchView.priority', 'ASC')
            .getMany();

        return queryRes.map((e) => e.id);
    }
}
