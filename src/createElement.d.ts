/// <reference types="@rbxts/types" />

import Roact from "./index";

type MapBindings<T> = { [K in keyof T]: T[K] | Roact.Binding<T[K]> };

/**
 * Creates a new Roact element representing the given `component`. Elements are lightweight descriptions about what a
 * Roblox Instance should look like, like a blueprint!
 *
 * The `children` argument is shorthand for adding a `Roact.Children` key to `props`. It should be specified as a
 * dictionary of names to elements.
 *
 * `component` can be a string, a function, or a table created by `Component:extend`.
 *
 * **Caution:** Make sure not to modify `props` or `children` after they're passed into `createElement`!
 */

// Functional Component
declare function createElement<P>(
	component: Roact.FunctionComponent<P>,
	props?: MapBindings<P>,
	children?:
		| { [childName: string]: Roact.Element | undefined }
		| ReadonlyMap<string | number, Roact.Element | undefined>
		| ReadonlyArray<Roact.Element | undefined>,
): Roact.Element;

// Class Component
declare function createElement<P>(
	component: Roact.ComponentConstructor<P>,
	props?: MapBindings<P>,
	children?:
		| { [childName: string]: Roact.Element | undefined }
		| ReadonlyMap<string | number, Roact.Element | undefined>
		| ReadonlyArray<Roact.Element | undefined>,
): Roact.Element;

type HostComponentProps<T extends Roact.HostComponent> = Roact.JsxInstanceProperties<CreatableInstances[T]> & {
	[Roact.Ref]?: Roact.Ref<CreatableInstances[T]> | ((ref: CreatableInstances[T]) => void);
};

// Host Component
declare function createElement<C extends Roact.HostComponent>(
	component: C,
	props?: MapBindings<HostComponentProps<C>>,
	children?:
		| { [childName: string]: Roact.Element | undefined }
		| ReadonlyMap<string | number, Roact.Element | undefined>
		| ReadonlyArray<Roact.Element | undefined>,
): Roact.Element;

export = createElement;
