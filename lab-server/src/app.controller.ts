import { Controller, Get } from '@nestjs/common';
import { Unprotected } from 'nest-keycloak-connect';

@Controller()
export class AppController {
    @Unprotected()
    @Get('health')
    getHealth(): string {
        return 'ok';
    }
}
