import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

import { AppModule } from './app.module';

async function bootstrap() {
    const app = await NestFactory.create<NestExpressApplication>(AppModule);
    app.useGlobalPipes(new ValidationPipe());
    app.setGlobalPrefix('/api/v1');

    const config = new DocumentBuilder()
        .setTitle('Lab Server')
        .setDescription('API Endpoints of our Lab Server')
        .setVersion('1.0')
        .build();
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api', app, document, {
        customSiteTitle: 'API Endpoints of our Lab Server',
        swaggerOptions: {
            persistAuthorization: true,
        },
        customfavIcon: `${process.env.ASSETS_URL}/favicon.png`,
        customCssUrl: `${process.env.ASSETS_URL}/styles.css`,
    });

    await app.listen(3001);
}
bootstrap();
