import { Module } from '@nestjs/common'
import { ConfigModule } from '@nestjs/config'

import { KeycloakModule, KeycloakProviders } from './configs/keycloak.config'
import { StarAllelesModule } from './star-alleles/star-alleles.module'

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    KeycloakModule,
    StarAllelesModule,
  ],
  providers: [...KeycloakProviders],
})
export class AppModule {}
