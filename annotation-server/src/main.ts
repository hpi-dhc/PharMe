import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  app.useStaticAssets(join(__dirname, '..', '..', 'assets'));

  const config = new DocumentBuilder()
    .setTitle('Annotation Server')
    .setDescription('API Endpoints of our Annotation Server')
    .setVersion('1.0')
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document, {
    customSiteTitle: 'Annotation Server API Documentation',
    customCssUrl: '../custom-theme.css',
    customfavIcon: '../favicon.png',
  });

  await app.listen(3000);
}
bootstrap();
