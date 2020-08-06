export interface Game{
    words: Word[];
    category: string;
}

export interface Word{
    word: string;
    category: string;
    hints: Hint[]
}

export interface Hint{
    title: string;
    timeShowAt: number;
}