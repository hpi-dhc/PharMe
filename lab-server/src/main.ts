import { join } from 'path';

import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

import { AppModule } from './app.module';

async function bootstrap() {
    const app = await NestFactory.create<NestExpressApplication>(AppModule);
    app.useStaticAssets(join(__dirname, '..', '..', 'assets'));
    app.useGlobalPipes(new ValidationPipe());
    app.setGlobalPrefix('/api/v1');

    const config = new DocumentBuilder()
        .setTitle('Lab Server')
        .setDescription('API Endpoints of our Lab Server')
        .setVersion('1.0')
        .build();
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api-docs', app, document, {
        customSiteTitle: 'Lab Server API Documentation',
        customCssUrl: '../custom-theme.css',
        customfavIcon: '../favicon.png',
    });

    await app.listen(3001);
}
bootstrap();
