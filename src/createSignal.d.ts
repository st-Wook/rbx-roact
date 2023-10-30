/// <reference types="@rbxts/types" />

declare function createSignal(): {
	subscribe: (callback: () => void) => void;
	fire: () => void;
};
declare function createSignal<T extends ReadonlyArray<any>>(): {
	subscribe: (callback: (...args: T) => void) => void;
	fire: (...args: T) => void;
};
declare function createSignal<T>(): {
	subscribe: (callback: (value: T) => void) => void;
	fire: (value: T) => void;
};

export = createSignal;
