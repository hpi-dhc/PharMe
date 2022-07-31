export class InstantiableDto<T> {
    constructor(dto: T) {
        Object.entries(dto).forEach(([key, value]) => {
            this[key] = value;
        });
    }
}
