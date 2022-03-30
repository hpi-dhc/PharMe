import { Controller, Get } from '@nestjs/common';
import { AuthenticatedUser } from 'nest-keycloak-connect';

import { OIDCUser } from 'src/common/oidc/oidc-user';
import { KeycloakUserPipe } from 'src/common/pipes/keycloak-user.pipe';

import { StarAllelesService } from './star-alleles.service';
@Controller('star-alleles')
export class StarAllelesController {
    constructor(private readonly starAllelesService: StarAllelesService) {}

    @Get()
    async starAlleles(
        @AuthenticatedUser(KeycloakUserPipe) oidcUser: OIDCUser,
    ): Promise<string> {
        return await this.starAllelesService.getStarAlleles(oidcUser);
    }
}
