import { readFile } from 'fs/promises'
import * as path from 'path'

import { Injectable } from '@nestjs/common'
import { bufferCount } from 'rxjs'

@Injectable()
export class StarAllelesService {
  
  async getStarAlleles(): Promise<string> {
    return Buffer.from(process.env.ALLELES_FILE || '', 'base64').toString()
  }
}
