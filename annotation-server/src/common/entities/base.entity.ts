import { IsNumber } from 'class-validator';
import { PrimaryGeneratedColumn } from 'typeorm';

export abstract class BaseEntity {
    @PrimaryGeneratedColumn()
    @IsNumber()
    id: number;
}
