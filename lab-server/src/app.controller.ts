import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { Unprotected } from 'nest-keycloak-connect';

@Controller()
@ApiTags('Server status')
export class AppController {
    @Get('health')
    @ApiOperation({ summary: 'Get the health of the server' })
    @ApiResponse({
        status: 200,
        description: 'The service is running.',
        content: { 'application/json': { example: 'ok' } },
    })
    @Unprotected()
    getHealth(): string {
        return 'ok';
    }
}
