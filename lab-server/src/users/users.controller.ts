import { Body, Controller, HttpCode, Post } from '@nestjs/common';
import { AuthenticateDto } from './dto/authenticate.dto';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @HttpCode(200)
  authenticate(@Body() authenticateDto: AuthenticateDto): Promise<string> {
    return this.usersService.authenticateUser(
      authenticateDto.username,
      authenticateDto.password,
    );
  }
}
