import * as KeycloakMock from 'keycloak-mock';

interface KeycloakMockHelper {
    mockInstance: KeycloakMock.MockInstance;
    mockToken: string;
}

export const getKeycloakMockHelper = async (
    isValid = true,
): Promise<KeycloakMockHelper> => {
    const keycloakMock = await KeycloakMock.createMockInstance({
        authServerURL: process.env.KEYCLOAK_AUTH_SERVER_URL,
        realm: process.env.KEYCLOAK_REALM,
        clientID: process.env.KEYCLOAK_CLIENT_ID,
        clientSecret: process.env.KEYCLOAK_SECRET,
    });
    const user = keycloakMock.database.createUser({
        username: isValid ? 'test' : 'invalid-user',
        email: isValid ? 'hello@hello.com' : 'invalid-email@hello.com',
        // Make sure that user with this UUID is added by the seeder
        id: isValid ? '6314b9fc-2054-4637-be77-9e0cc48c186f' : 'invalid-uuid',
        credentials: [
            {
                value: 'mypassword',
            },
        ],
    });
    const token = keycloakMock.createBearerToken(user.profile.id);

    return { mockInstance: keycloakMock, mockToken: token };
};
