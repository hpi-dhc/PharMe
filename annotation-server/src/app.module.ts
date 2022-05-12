import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { GenePhenotypesModule } from './gene-phenotypes/gene-phenotypes.module';
import { GuidelinesModule } from './guidelines/guidelines.module';
import { MedicationsModule } from './medications/medications.module';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
            envFilePath: (process.env.NODE_ENV === 'test'
                ? ['test/.env']
                : []
            ).concat(['.env']),
        }),
        TypeOrmModule.forRootAsync({
            imports: [ConfigModule],
            useFactory: (configService: ConfigService) => ({
                type: 'postgres',
                host: configService.get<string>('ANNOTATION_DB_HOST'),
                port: configService.get<number>('ANNOTATION_DB_PORT'),
                username: configService.get<string>('ANNOTATION_DB_USER'),
                password: configService.get<string>('ANNOTATION_DB_PASS'),
                database: configService.get<string>('ANNOTATION_DB_NAME'),
                autoLoadEntities: true,
                synchronize: true,
            }),
            inject: [ConfigService],
        }),
        ScheduleModule.forRoot(),
        MedicationsModule,
        GenePhenotypesModule,
        GuidelinesModule,
    ],
    controllers: [AppController],
    providers: [AppService],
})
export class AppModule {}
