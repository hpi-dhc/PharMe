import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

import { AppModule } from './app.module';
import { TypeormErrorInterceptor } from './common/interceptors/typeorm-error.interceptor';

async function bootstrap() {
    const app = await NestFactory.create<NestExpressApplication>(AppModule);
    const configService = app.get(ConfigService);

    app.setGlobalPrefix('/api/v1');
    app.useGlobalInterceptors(new TypeormErrorInterceptor());

    const config = new DocumentBuilder()
        .setTitle('Annotation Server')
        .setDescription('API Endpoints of our Annotation Server')
        .setVersion('1.0')
        .build();
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api', app, document, {
        customSiteTitle: 'API Endpoints of our Annotation Server',
        swaggerOptions: {
            persistAuthorization: true,
        },
        customfavIcon: `${process.env.ASSETS_URL}/favicon.png`,
        customCssUrl: `${process.env.ASSETS_URL}/styles.css`,
    });

    await app.listen(configService.get('PORT'));
}
bootstrap();
