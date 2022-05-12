import { CacheMap } from '../../common/cache-map';
import { GuidelineError } from '../entities/guideline-error.entity';

export abstract class GuidelineCacheMap<Value> extends CacheMap<
    Value,
    GuidelineError
> {
    protected validate(valueOrError: Value | GuidelineError): Value {
        if (valueOrError instanceof GuidelineError) throw valueOrError;
        return valueOrError;
    }
}
