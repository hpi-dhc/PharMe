import { ApiBody } from '@nestjs/swagger';

export function ApiBodyPatch(resourceName: string): MethodDecorator {
    return ApiBody({
        description: `An array of partial ${resourceName} entities. Note that the ID is required.`,
        required: true,
        isArray: true,
    });
}
