export abstract class CacheMap<Value, RetrieveFailedError> {
    protected abstract retrieve(...keys: string[]): Promise<Value>;
    protected abstract createError(...keys: string[]): RetrieveFailedError;
    protected abstract validate(
        valueOrError: Value | RetrieveFailedError,
    ): Value;

    cache: Map<string, Value | RetrieveFailedError>;

    constructor() {
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
            const value = await this.retrieve(...keys);
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
