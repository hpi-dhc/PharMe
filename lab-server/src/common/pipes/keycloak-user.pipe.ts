import { Injectable, PipeTransform } from '@nestjs/common';

import { KeycloakJwt } from '../oidc/jwt.interface';
import { OIDCUser } from '../oidc/oidc-user';

@Injectable()
export class KeycloakUserPipe implements PipeTransform {
    transform(value: KeycloakJwt): OIDCUser {
        return new OIDCUser(value);
    }
}
