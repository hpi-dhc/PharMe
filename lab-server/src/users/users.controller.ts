import { Body, Controller, Post } from '@nestjs/common';
import { AuthenticateDto } from './dto/authenticate.dto';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  authenticate(@Body() authenticateDto: AuthenticateDto): Promise<string> {
    return this.usersService.authenticateUser(
      authenticateDto.username,
      authenticateDto.password,
    );
  }
}
