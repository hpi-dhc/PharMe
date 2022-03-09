import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { KeycloakModule, KeycloakProviders } from './configs/keycloak.config';
import { OrmModule } from './configs/orm.config';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    KeycloakModule,
    OrmModule,
    UsersModule,
  ],
  providers: [...KeycloakProviders],
})
export class AppModule {}
