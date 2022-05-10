export class CacheMap<Value, RetrieveFailedError> {
    retrieve: (...keys: string[]) => Promise<Value>;
    createError: (...keys: string[]) => RetrieveFailedError;
    validate: (valueOrError: Value | RetrieveFailedError) => Value;
    cache: Map<string, Value | RetrieveFailedError>;

    constructor(
        retrieve: (...keys: string[]) => Promise<Value>,
        createError: (...keys: string[]) => RetrieveFailedError,
        validate: (valueOrError: Value | RetrieveFailedError) => Value,
    ) {
        this.retrieve = retrieve;
        this.createError = createError;
        this.validate = validate;
        this.cache = new Map();
    }

    private mapKey(keys: string[]) {
        return keys.join(';');
    }

    async get(...keys: string[]): Promise<Value> {
        const key = this.mapKey(keys);
        if (this.cache.has(key)) {
            return this.validate(this.cache.get(key));
        }
        try {
            const value = await this.retrieve(key);
            this.cache.set(key, value);
            return value;
        } catch {
            const error = this.createError(...keys);
            this.cache.set(key, error);
            throw error;
        }
    }

    clear(): void {
        this.cache.clear();
    }
}
