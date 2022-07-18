import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

import { AppModule } from './app.module';

async function bootstrap() {
    const app = await NestFactory.create<NestExpressApplication>(AppModule);
    app.setGlobalPrefix('/api/v1');
    app.useGlobalPipes(new ValidationPipe());

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

    await app.listen(3000);
}
bootstrap();
