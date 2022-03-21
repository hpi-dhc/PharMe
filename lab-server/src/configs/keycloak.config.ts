import { ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import {
    AuthGuard,
    KeycloakConnectModule,
    TokenValidation,
} from 'nest-keycloak-connect';

export const KeycloakModule = KeycloakConnectModule.registerAsync({
    useFactory: (configService: ConfigService) => ({
        authServerUrl: configService.get<string>('KEYCLOAK_AUTH_SERVER_URL'),
        realm: configService.get<string>('KEYCLOAK_REALM'),
        clientId: configService.get<string>('KEYCLOAK_CLIENT_ID'),
        secret: configService.get<string>('KEYCLOAK_SECRET'),
        useNestLogger: true,
        tokenValidation: TokenValidation.OFFLINE,
    }),
    inject: [ConfigService],
});

export const KeycloakProviders = [
    {
        provide: APP_GUARD,
        useClass: AuthGuard,
    },
];
