/// <reference types="@rbxts/types" />

type Disconnect = () => void;

declare function createSignal(): {
	subscribe: (callback: () => void) => Disconnect;
	fire: () => void;
};
declare function createSignal<T extends ReadonlyArray<any>>(): {
	subscribe: (callback: (...args: T) => void) => Disconnect;
	fire: (...args: T) => void;
};
declare function createSignal<T>(): {
	subscribe: (callback: (value: T) => void) => Disconnect;
	fire: (value: T) => void;
};

export = createSignal;
