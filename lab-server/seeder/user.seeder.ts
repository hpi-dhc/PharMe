import * as fs from 'fs';

import { Connection } from 'typeorm';
import { Factory, Seeder } from 'typeorm-seeding';

import { User } from '../src/user/entities/user.entity';

export default class CreateUsers implements Seeder {
    public async run(_: Factory, connection: Connection): Promise<void> {
        const USER_FILE = 'seeder/users.json';
        if (!fs.existsSync(USER_FILE)) {
            fs.copyFileSync('seeder/users.example.json', USER_FILE);
        }
        const seedUserData = JSON.parse(fs.readFileSync(USER_FILE, 'utf-8'));
        const seedUsers: User[] = seedUserData.map((userData: object) => ({
            createdAt: new Date(),
            updatedAt: new Date(),
            ...userData,
        }));
        await Promise.all(
            seedUsers.map(
                async (x) => await connection.getRepository(User).save(x),
            ),
        );
    }
}
