import { ILike } from 'typeorm';

import { Medication } from '../../medications/medication.entity';
import { MedicationsService } from '../../medications/medications.service';
import {
    GuidelineError,
    GuidelineErrorBlame,
    GuidelineErrorType,
} from '../entities/guideline-error.entity';
import { GuidelineCacheMap } from './guideline-cache';

export class MedicationByNameCache extends GuidelineCacheMap<Medication> {
    private medicationsService: MedicationsService;

    constructor(medicationsService: MedicationsService) {
        super();
        this.medicationsService = medicationsService;
    }

    protected retrieve(...[name]: string[]): Promise<Medication> {
        return this.medicationsService.getOne({ where: { name: ILike(name) } });
    }

    protected createError(...[name]: string[]): GuidelineError {
        const error = new GuidelineError();
        error.type = GuidelineErrorType.MEDICATION_NAME_NOT_FOUND;
        error.blame = GuidelineErrorBlame.DRUGBANK;
        error.context = name;
        return error;
    }
}

export class MedicationByRxcuiCache extends GuidelineCacheMap<Medication> {
    private medicationsService: MedicationsService;

    constructor(medicationsService: MedicationsService) {
        super();
        this.medicationsService = medicationsService;
    }

    protected retrieve(...[rxcui]: string[]): Promise<Medication> {
        return this.medicationsService.getOne({ where: { rxcui } });
    }

    protected createError(...[rxcui]: string[]): GuidelineError {
        const error = new GuidelineError();
        error.type = GuidelineErrorType.MEDICATION_RXCUI_NOT_FOUND;
        error.blame = GuidelineErrorBlame.DRUGBANK;
        error.context = rxcui;
        return error;
    }
}
