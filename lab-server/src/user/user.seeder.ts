import { Connection } from 'typeorm';
import { Factory, Seeder } from 'typeorm-seeding';

import { User } from './entities/user.entity';

export default class CreateUsers implements Seeder {
    private mockData: User[] = [
        {
            createdAt: new Date(),
            updatedAt: new Date(),
            id: 1,
            sub: '6314b9fc-2054-4637-be77-9e0cc48c186f',
            allelesFile: '204753010001_R01C01.json',
        },
        {
            createdAt: new Date(),
            updatedAt: new Date(),
            id: 2,
            sub: '4beb7675-e415-4580-bdcb-75b63ca14766',
            allelesFile: '204753010001_R02C01.json',
        },
        {
            createdAt: new Date(),
            updatedAt: new Date(),
            id: 3,
            sub: '340d6476-68dc-4852-90ca-caf6fce1a50d',
            allelesFile: 'does_not_exist.json',
        },
    ];

    public async run(_: Factory, connection: Connection): Promise<void> {
        await Promise.all(
            this.mockData.map(
                async (x) => await connection.getRepository(User).save(x),
            ),
        );
    }
}
