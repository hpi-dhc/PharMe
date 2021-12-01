import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ClinicalAnnotation } from './clinical_annotation/clinical_annotation.entity';
import { AnnotationsModule } from './clinical_annotation/clinical_annotation.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
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
        entities: [ClinicalAnnotation],
        autoLoadEntities: true,
        keepConnectionAlive: true,
        synchronize: true,
      }),
      inject: [ConfigService],
    }),
    AnnotationsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
