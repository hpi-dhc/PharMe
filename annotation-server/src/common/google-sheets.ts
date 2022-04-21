import { sheets as googleSheets, sheets_v4 } from '@googleapis/sheets';

export async function fetchSpreadsheet(
    spreadsheetId: string,
    apiKey: string,
    ranges: string[],
): Promise<sheets_v4.Schema$ValueRange[]> {
    return new Promise((resolve, reject) => {
        const sheets = googleSheets('v4');
        sheets.spreadsheets.values.batchGet(
            { spreadsheetId: spreadsheetId, key: apiKey, ranges: ranges },
            (error, result) => {
                if (error) reject(error);
                resolve(result.data.valueRanges);
            },
        );
    });
}
