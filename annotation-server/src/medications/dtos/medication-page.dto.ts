import { Medication } from '../medication.entity';

export class MedicationPageDto {
    medications: Medication[];

    total: number;
}
