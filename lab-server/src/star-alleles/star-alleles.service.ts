import { Injectable } from '@nestjs/common'
import { readFile } from 'fs/promises';
import * as path from 'path';

@Injectable()
export class StarAllelesService {
  async getStarAlleles(): Promise<string> {
    return await readFile(path.resolve(__dirname, '../../src/alleles.json'), {
      encoding: 'utf8',
    });
  }
}

function sleep(time: number) {
  return new Promise((resolve) => {
    setTimeout(resolve, time)
  })
}
