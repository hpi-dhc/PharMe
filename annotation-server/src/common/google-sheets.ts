import { sheets as googleSheets, sheets_v4 } from '@googleapis/sheets';

export async function fetchSpreadsheetCells(
    spreadsheetId: string,
    apiKey: string,
    ranges: string[],
): Promise<{ value?: string; backgroundColor?: sheets_v4.Schema$Color }[][][]> {
    const sheets = googleSheets('v4');
    const spreadsheetData = await sheets.spreadsheets.get({
        spreadsheetId: spreadsheetId,
        key: apiKey,
        ranges: ranges,
        includeGridData: true,
    });

    // this asumes data is in first sheet!
    return spreadsheetData.data.sheets[0].data.map((range) =>
        range.rowData.map((row) =>
            row.values.map((cell) => {
                return {
                    value: cell.effectiveValue?.stringValue,
                    backgroundColor: cell.effectiveFormat?.backgroundColor,
                };
            }),
        ),
    );
}
