import { GuidelineError } from '../entities/guideline-error.entity';

export class GuidelineErrorPageDto {
    guidelineErrors: GuidelineError[];
    total: number;
}
