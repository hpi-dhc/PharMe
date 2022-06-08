import { ApiQuery } from '@nestjs/swagger';

export function ApiQueryLimit(
    resourceName: string,
    defaultLimit?: number,
): MethodDecorator {
    const defaultLimitString = defaultLimit ? `${defaultLimit}` : 'unlimited';
    return ApiQuery({
        name: 'limit',
        description: `How many ${resourceName}s to return, at most. Defaults to ${defaultLimitString}`,
        type: 'number',
        required: false,
    });
}

export function ApiQueryOffset(resourceName: string): MethodDecorator {
    return ApiQuery({
        name: 'offset',
        description: `Specifies from where the subset of ${resourceName}s returned start from (based on ID). Defaults to 0`,
        type: 'number',
        required: false,
    });
}

export function ApiQuerySortby(resourceName: string): MethodDecorator {
    return ApiQuery({
        name: 'sortby',
        description: `Attribute by which returned ${resourceName}s are sorted. Defaults to "name"`,
        type: 'string',
        required: false,
    });
}

export function ApiQueryOrderby(resourceName: string): MethodDecorator {
    return ApiQuery({
        name: 'orderby',
        description: `Order in which returned ${resourceName}s are sorted. Defaults to ascending order`,
        enum: ['asc', 'desc'],
        required: false,
    });
}

export function ApiQuerySearch(resourceName: string): MethodDecorator {
    return ApiQuery({
        name: 'search',
        description: `String to search in the name of the ${resourceName}`,
        type: 'string',
        required: false,
    });
}
