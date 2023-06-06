import { ConfigModule, ConfigService } from '@nestjs/config';
import { MinioModule } from 'nestjs-minio-client';

export const MinioModuleConfig = MinioModule.registerAsync({
    imports: [ConfigModule],
    useFactory: async (config: ConfigService) => ({
        endPoint: config.get<string>('MINIO_ENDPOINT'),
        port: parseInt(config.get<string>('MINIO_PORT')),
        useSSL: false,
        accessKey: config.get<string>('MINIO_ROOT_USER'),
        secretKey: config.get<string>('MINIO_ROOT_PASSWORD'),
    }),
    inject: [ConfigService],
});
