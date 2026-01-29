# todo-cli

Simple ToDo CLI built with Moonbit.

## Setup

```bash
moon test
```

## Usage

```bash
moon run -- add "buy milk"
moon run -- list
moon run -- done 1
moon run -- delete 1
```

## Data

Tasks are stored in `data/todo.txt` using this format:

```
id|done|text
```

- `done` is `0` or `1`.
