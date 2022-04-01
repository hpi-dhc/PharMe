import * as KeycloakMock from 'keycloak-mock';

interface KeycloakMockHelper {
    mockInstance: KeycloakMock.MockInstance;
    mockToken: string;
}

/*
If the argument isUserValid is set to false, then the function returns a KeycloakMockHelper with
an invalid token, otherwise returns an an instance with a valid token
*/
export const getKeycloakMockHelperForUser = async (
    isUserValid = true,
): Promise<KeycloakMockHelper> => {
    const keycloakMock = await getMockInstance();
    const user = getUser(keycloakMock, isUserValid);
    const token = keycloakMock.createBearerToken(user.profile.id);

    return { mockInstance: keycloakMock, mockToken: token };
};

const getMockInstance = async (): Promise<KeycloakMock.MockInstance> => {
    return await KeycloakMock.createMockInstance({
        authServerURL: process.env.KEYCLOAK_AUTH_SERVER_URL,
        realm: process.env.KEYCLOAK_REALM,
        clientID: process.env.KEYCLOAK_CLIENT_ID,
        clientSecret: process.env.KEYCLOAK_SECRET,
    });
};

const getUser = (
    keycloakMock: KeycloakMock.MockInstance,
    isUserValid: boolean,
) => {
    return keycloakMock.database.createUser({
        username: isUserValid ? 'test' : 'invalid-user',
        email: isUserValid ? 'hello@hello.com' : 'hello@invalid.com',
        // Make sure that user with this UUID is added by the seeder
        id: isUserValid ? '6314b9fc-2054-4637-be77-9e0cc48c186f' : 'invalid-id',
        credentials: [
            {
                value: 'mypassword',
            },
        ],
    });
};
