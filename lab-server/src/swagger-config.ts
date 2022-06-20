import { DocumentBuilder } from '@nestjs/swagger';

export const swaggerConfig = new DocumentBuilder()
    .setTitle('Lab Server')
    .setDescription('API Endpoints of our Lab Server')
    .setDescription(
        'The OpenAPI description of a mock lab-server created as part of a bachelors project at the Hasso-Plattner-Institut (HPI) in Potsdam. Note that you will need to obtain a valid access token in order to make any request other than the health-check. Upon obtaining an access token, you can authorize yourself for all future requests (that is, until the token expires) you make by clicking on the "Authorize" button.',
    )
    .setVersion('1.0')
    .addTag('Lab Server')
    .addBearerAuth(
        { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
        'access-token',
    )
    .build();
