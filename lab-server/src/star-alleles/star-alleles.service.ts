import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { OIDCUser } from '../common/oidc/oidc-user';
import { S3Service } from '../s3/s3.service';
import { User } from '../user/entities/user.entity';
@Injectable()
export class StarAllelesService {
    constructor(
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
        private readonly s3Service: S3Service,
    ) {}
    async getStarAlleles(oidcUser: OIDCUser): Promise<object> {
        const result = await this.userRepository.findOneOrFail({
            where: { sub: oidcUser.sub },
        });
        return this.s3Service.getFile(result.allelesFile);
    }
}
