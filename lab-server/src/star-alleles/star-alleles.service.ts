import { Injectable } from '@nestjs/common';

import { OIDCUser } from 'src/common/oidc/oidc-user';
@Injectable()
export class StarAllelesService {
    async getStarAlleles(oidcUser: OIDCUser): Promise<string> {
        return Buffer.from(process.env.ALLELES_FILE || '', 'base64').toString();
    }
}
