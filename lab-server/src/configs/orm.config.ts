import { ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

export const OrmModule = TypeOrmModule.forRootAsync({
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
});
