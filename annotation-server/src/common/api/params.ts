import { ApiParam } from '@nestjs/swagger';

export function ApiParamGetById(resourceName: string): MethodDecorator {
    return ApiParam({
        name: 'id',
        description: `ID of the ${resourceName} to fetch details of`,
        example: '144',
        type: 'integer',
        required: true,
    });
}
