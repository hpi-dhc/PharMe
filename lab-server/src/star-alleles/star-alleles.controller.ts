import { Controller, Get } from '@nestjs/common';
import {
    ApiBearerAuth,
    ApiOperation,
    ApiResponse,
    ApiTags,
} from '@nestjs/swagger';
import { AuthenticatedUser } from 'nest-keycloak-connect';

import { OIDCUser } from '../common/oidc/oidc-user';
import { KeycloakUserPipe } from '../common/pipes/keycloak-user.pipe';
import { AllelesFile } from './entities/star-alleles.entity';
import { StarAllelesService } from './star-alleles.service';

@ApiTags('Alleles')
@ApiBearerAuth('access-token')
@Controller('star-alleles')
export class StarAllelesController {
    constructor(private readonly starAllelesService: StarAllelesService) {}

    @Get()
    @ApiOperation({ summary: `Return a user's star-alleles` })
    @ApiResponse({
        status: 200,
        description: `User's alleles are found and returned`,
        type: AllelesFile,
    })
    @ApiResponse({
        status: 500,
        description: `User's alleles could not be found`,
    })
    async starAlleles(
        @AuthenticatedUser(KeycloakUserPipe) oidcUser: OIDCUser,
    ): Promise<object> {
        return await this.starAllelesService.getStarAlleles(oidcUser);
    }
}
