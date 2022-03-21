import { Injectable } from '@nestjs/common';

@Injectable()
export class StarAllelesService {
    async getStarAlleles(): Promise<string> {
        await sleep(4000);
        return 'Some star alleles';
    }
}

function sleep(time: number) {
    return new Promise((resolve) => {
        setTimeout(resolve, time);
    });
}
