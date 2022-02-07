import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import * as argon2 from 'argon2';
import { InjectRepository } from '@nestjs/typeorm';
import * as path from 'path';
import { readFile } from 'fs/promises';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async authenticateUser(username: string, password: string): Promise<string> {
    const user = await this.userRepository.findOneOrFail({
      username: username,
    });
    // uncomment this line and then copy the logged result in order to add a valid entry in your db
    //console.log(argon2.hash(password));
    if (!(await argon2.verify(user.password, password))) {
      throw new HttpException('User not found', HttpStatus.UNAUTHORIZED);
    }
    await sleep(4000);
    return 'Some star alleles';
  }

  async getStarAlleles(): Promise<string> {
    return await readFile(path.resolve(__dirname, '../../src/alleles.json'), {
      encoding: 'utf8',
    });
  }
}

function sleep(time: number) {
  return new Promise((resolve) => {
    setTimeout(resolve, time);
  });
}
