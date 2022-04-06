import * as path from 'path';

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
        entities: [path.join(__dirname, '..', '**', '*.entity{.ts,.js}')],
        synchronize: true,
        logging: ['warn', 'error'],
    }),
    inject: [ConfigService],
});
