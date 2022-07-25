import {
    BadRequestException,
    CallHandler,
    ExecutionContext,
    Injectable,
    NestInterceptor,
    NotFoundException,
} from '@nestjs/common';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { EntityNotFoundError, QueryFailedError, TypeORMError } from 'typeorm';

@Injectable()
export class TypeormErrorInterceptor implements NestInterceptor {
    intercept(
        context: ExecutionContext,
        next: CallHandler,
    ): Observable<unknown> {
        return next.handle().pipe(
            catchError((err) => {
                if (err instanceof TypeORMError) {
                    switch (err.constructor) {
                        case EntityNotFoundError:
                            return throwError(
                                () =>
                                    new NotFoundException(
                                        'Could not find any entity matching the given criteria.',
                                    ),
                            );
                        case QueryFailedError:
                            return throwError(
                                () => new BadRequestException('Invalid query.'),
                            );
                    }
                }
                return throwError(err);
            }),
        );
    }
}
