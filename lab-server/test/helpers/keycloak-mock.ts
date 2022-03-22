import * as KeycloakMock from 'keycloak-mock';

interface KeycloakMockHelper {
    mockInstance: KeycloakMock.MockInstance;
    mockToken: string;
}

export const getKeycloakMockHelper = async (): Promise<KeycloakMockHelper> => {
    const keycloakMock = await KeycloakMock.createMockInstance({
        authServerURL: process.env.KEYCLOAK_AUTH_SERVER_URL,
        realm: process.env.KEYCLOAK_REALM,
        clientID: process.env.KEYCLOAK_CLIENT_ID,
        clientSecret: process.env.KEYCLOAK_SECRET,
    });
    const user = keycloakMock.database.createUser({
        username: 'test',
        email: 'hello@hello.com',
        credentials: [
            {
                value: 'mypassword',
            },
        ],
    });
    const token = keycloakMock.createBearerToken(user.profile.id);

    return { mockInstance: keycloakMock, mockToken: token };
};
