import * as KeycloakMockServer from 'keycloak-mock';

export class KeycloakMock {
    private static instance: KeycloakMock;
    private keycloakMock: KeycloakMockServer.Mock;
    private keycloakMockInstance: KeycloakMockServer.MockInstance;
    private exampleUser: KeycloakMockServer.MockUser;
    private exampleUserWithoutAllelesFile: KeycloakMockServer.MockUser;

    // eslint-disable-next-line @typescript-eslint/no-empty-function
    private constructor() {}

    public static getInstance(): KeycloakMock {
        if (!KeycloakMock.instance) {
            KeycloakMock.instance = new KeycloakMock();
        }
        return KeycloakMock.instance;
    }

    public async activate(): Promise<void> {
        this.keycloakMockInstance = await KeycloakMockServer.createMockInstance(
            {
                authServerURL: process.env.KEYCLOAK_AUTH_SERVER_URL,
                realm: process.env.KEYCLOAK_REALM,
                clientID: process.env.KEYCLOAK_CLIENT_ID,
                clientSecret: process.env.KEYCLOAK_CLIENT_SECRET,
            },
        );
        this.keycloakMock = KeycloakMockServer.activateMock(
            this.keycloakMockInstance,
        );

        this.exampleUser = this.createUser();
        this.exampleUserWithoutAllelesFile = this.createUser(false);
    }

    public deactivate(): void {
        KeycloakMockServer.deactivateMock(this.keycloakMock);
    }

    public getExampleUser(): string {
        return this.keycloakMockInstance.createBearerToken(
            this.exampleUser.profile.id,
        );
    }

    public getExampleUserWithoutAllelesFile(): string {
        return this.keycloakMockInstance.createBearerToken(
            this.exampleUserWithoutAllelesFile.profile.id,
        );
    }

    private createUser(
        hasValidAllelesFile = true,
    ): KeycloakMockServer.MockUser {
        if (hasValidAllelesFile) {
            return this.keycloakMockInstance.database.createUser({
                username: 'valid-user',
                email: 'hello@valid.com',
                id: '6314b9fc-2054-4637-be77-9e0cc48c186f',
                credentials: [
                    {
                        value: 'mypassword',
                    },
                ],
            });
        }

        return this.keycloakMockInstance.database.createUser({
            username: 'valid-without-file',
            email: 'hello@valid-without-file.com',
            id: '340d6476-68dc-4852-90ca-caf6fce1a50d',
            credentials: [
                {
                    value: 'mypassword',
                },
            ],
        });
    }
}
