export const supportedLanguages = ['English', 'German'] as const;
export type SupportedLanguage = typeof supportedLanguages[number];

export const brickUsages = [
    'Drug class',
    'Drug indication',
    'Implication',
    'Recommendation',
] as const;
export type BrickUsage = typeof brickUsages[number];

export const displayCategories = ['All', ...brickUsages] as const;
export type DisplayCategory = typeof displayCategories[number];
