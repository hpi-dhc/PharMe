import { ConfigModule, ConfigService } from '@nestjs/config';
import { MinioModule } from 'nestjs-minio-client';

export const MinioModuleConfig = MinioModule.registerAsync({
    imports: [ConfigModule],
    useFactory: async (config: ConfigService) => ({
        endPoint: config.get<string>('MINIO_ENDPOINT', '127.0.0.1'),
        port: parseInt(config.get<string>('MINIO_PORT', '9000')),
        useSSL: false,
        accessKey: config.get<string>('MINIO_ROOT_USER', 'admin'),
        secretKey: config.get<string>('MINIO_ROOT_PASSWORD', 'admin'),
    }),
    inject: [ConfigService],
});
