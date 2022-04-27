import { ConfigModule, ConfigService } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';

import { fetchSpreadsheetCells } from './google-sheets';

describe('Helper to fetch spreadsheet', () => {
    let configService: ConfigService;

    beforeAll(async () => {
        const modelFixture: TestingModule = await Test.createTestingModule({
            imports: [ConfigModule.forRoot()],
        }).compile();

        configService = modelFixture.get<ConfigService>(ConfigService);

        // making sure right .env was loaded
        // FIX ME: multiple .envs are discuraged (https://www.npmjs.com/package/dotenv#faq)
        expect(configService.get<string>('DRUGBANK_XML')).toBe(
            'random-database.xml',
        );
    });

    describe('fetchSpreadsheetCells', () => {
        it('should not return an error with valid sheet id', async () => {
            const spreadsheetData = await fetchSpreadsheetCells(
                configService.get<string>('GOOGLESHEET_ID'),
                configService.get<string>('GOOGLESHEET_APIKEY'),
                [
                    configService.get<string>('GOOGLESHEET_RANGE_MEDICATIONS'),
                    configService.get<string>('GOOGLESHEET_RANGE_GENES'),
                    configService.get<string>('GOOGLESHEET_RANGE_PHENOTYPES'),
                    configService.get<string>('GOOGLESHEET_RANGE_IMPLICATIONS'),
                    configService.get<string>(
                        'GOOGLESHEET_RANGE_RECOMMENDATIONS',
                    ),
                ],
            );
            expect(spreadsheetData).toBeDefined();
        });

        it('should return an error with invalid sheet id', async () => {
            expect(() =>
                fetchSpreadsheetCells(
                    '1',
                    configService.get<string>('GOOGLESHEET_APIKEY'),
                    [
                        configService.get<string>(
                            'GOOGLESHEET_RANGE_MEDICATIONS',
                        ),
                        configService.get<string>('GOOGLESHEET_RANGE_GENES'),
                        configService.get<string>(
                            'GOOGLESHEET_RANGE_PHENOTYPES',
                        ),
                        configService.get<string>(
                            'GOOGLESHEET_RANGE_IMPLICATIONS',
                        ),
                        configService.get<string>(
                            'GOOGLESHEET_RANGE_RECOMMENDATIONS',
                        ),
                    ],
                ),
            ).rejects.toThrowError('Requested entity was not found.');
        });

        it('should return an error when sheet does not match structure', async () => {
            expect(() =>
                fetchSpreadsheetCells(
                    configService.get<string>('EMPTY_GOOGLESHEET_ID'),
                    configService.get<string>('GOOGLESHEET_APIKEY'),
                    [
                        configService.get<string>(
                            'GOOGLESHEET_RANGE_MEDICATIONS',
                        ),
                        configService.get<string>('GOOGLESHEET_RANGE_GENES'),
                        configService.get<string>(
                            'GOOGLESHEET_RANGE_PHENOTYPES',
                        ),
                        configService.get<string>(
                            'GOOGLESHEET_RANGE_IMPLICATIONS',
                        ),
                        configService.get<string>(
                            'GOOGLESHEET_RANGE_RECOMMENDATIONS',
                        ),
                    ],
                ),
            ).rejects.toThrowError(/Unable to parse range.*/);
        });

        it('should return correct data from sheet', async () => {
            const [
                medications,
                genes,
                phenotypeHeader,
                implications,
                recommendations,
            ] = await fetchSpreadsheetCells(
                configService.get<string>('GOOGLESHEET_ID'),
                configService.get<string>('GOOGLESHEET_APIKEY'),
                [
                    configService.get<string>('GOOGLESHEET_RANGE_MEDICATIONS'),
                    configService.get<string>('GOOGLESHEET_RANGE_GENES'),
                    configService.get<string>('GOOGLESHEET_RANGE_PHENOTYPES'),
                    configService.get<string>('GOOGLESHEET_RANGE_IMPLICATIONS'),
                    configService.get<string>(
                        'GOOGLESHEET_RANGE_RECOMMENDATIONS',
                    ),
                ],
            );
            expect(medications[0][0].value).toBe('Codeine');
            expect(genes[0][0].value).toBe('CYP2D6');
            expect(phenotypeHeader[0][0].value).toStrictEqual(
                'Ultrarapid metabolizer; increased function',
            );
            expect(implications[0][0].value).toBe(
                'Codeine/CYP2D6/implication/1',
            );
            expect(recommendations[0][0].backgroundColor).toStrictEqual({
                green: 1,
            });
            expect(recommendations[0][0].value).toBe(
                'Codeine/CYP2D6/recommendation/1/ok',
            );
        });
    });
});
