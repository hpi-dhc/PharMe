export type CpicRecommendation = {
    id: number;
    drugid: string;
    version: number;

    drug: { name: string };
    lookupkey: { [key: string]: string }; // gene-symbol: phenotype-description (can be activity score)
    phenotypes: { [key: string]: string }; // gene-symbol: phenotype (can be empty)

    guideline: { name: string; url: string };
    implications: { [key: string]: string }; // gene-symbol: implication
    drugrecommendation: string;
    comments?: string;
};

export const cpicRecommendationsURL =
    'https://api.cpicpgx.org/v1/recommendation';
export const cpicRecommendationsParams = {
    select: 'id,drugid,version,drug(name),lookupkey,phenotypes,guideline(name,url),implications,drugrecommendation,comments',
};
