import { register } from './LibraryErrors';

const Messages: Record<string | number | symbol, any> = {
  NOT_IMPLEMENTED: (what: string, name: string) => `Method ${what} not implemented on ${name}.`
};

for (const [name, message] of Object.entries(Messages)) register(Symbol(name), message);