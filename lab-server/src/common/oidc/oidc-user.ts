import { KeycloakJwt } from './jwt.interface';

export class OIDCUser {
    sub: string;
    email_verified: boolean;
    name: string;
    preferred_username: string;
    given_name: string;
    family_name: string;
    email: string;

    constructor(jwt: KeycloakJwt) {
        this.sub = jwt.sub;
        this.email_verified = jwt.email_verified;
        this.name = jwt.name;
        this.preferred_username = jwt.preferred_username;
        this.given_name = jwt.given_name;
        this.family_name = jwt.family_name;
        this.email = jwt.email;
    }
}
