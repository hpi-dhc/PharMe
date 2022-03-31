import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { AppController } from './app.controller';
import { KeycloakModule, KeycloakProviders } from './configs/keycloak.config';
import { S3Module } from './s3/s3.module';
import { StarAllelesModule } from './star-alleles/star-alleles.module';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
        }),
        S3Module,
        KeycloakModule,
        StarAllelesModule,
    ],

    controllers: [AppController],
    providers: [...KeycloakProviders],
})
export class AppModule {}
