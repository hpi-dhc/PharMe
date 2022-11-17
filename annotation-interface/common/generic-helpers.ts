export const mod = (a: number, b: number): number => ((a % b) + b) % b;

export const matches = (test: string, query: string): boolean => {
    test = test.toLowerCase();
    return (
        query
            .toLowerCase()
            .split(/\s+/)
            .filter((word) => !test.includes(word)).length === 0
    );
};
