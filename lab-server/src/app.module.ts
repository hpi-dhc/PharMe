import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthGuard, KeycloakConnectModule } from 'nest-keycloak-connect';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    KeycloakConnectModule.registerAsync({
      useFactory: (configService: ConfigService) => ({
        authServerUrl: configService.get<string>('KEYCLOAK_AUTH_SERVER_URL'),
        realm: configService.get<string>('KEYCLOAK_REALM'),
        clientId: configService.get<string>('KEYCLOAK_CLIENT_ID'),
        secret: configService.get<string>('KEYCLOAK_SECRET'),
      }),
      inject: [ConfigService],
    }),
    TypeOrmModule.forRootAsync({
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('LAB_SERVER_DB_HOST'),
        port: configService.get<number>('LAB_SERVER_DB_PORT'),
        username: configService.get<string>('LAB_SERVER_DB_USER'),
        password: configService.get<string>('LAB_SERVER_DB_PASS'),
        database: configService.get<string>('LAB_SERVER_DB_NAME'),
        autoLoadEntities: true,
        synchronize: true,
      }),
      inject: [ConfigService],
    }),
    UsersModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: AuthGuard,
    },
  ],
})
export class AppModule {}
