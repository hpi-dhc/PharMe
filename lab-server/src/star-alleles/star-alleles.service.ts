import { Injectable } from '@nestjs/common';

@Injectable()
export class StarAllelesService {
    async getStarAlleles(): Promise<string> {
        return Buffer.from(process.env.ALLELES_FILE || '', 'base64').toString();
    }
}
