# zox

Based on the book Crafting Interpreters - http://craftinginterpreters.com/

## Desktop

To build the desktop version, run 

```
$ zig build-exe src/main.zig
```

To run the repl, run it with no arguments

```
$ ./main
```

To run a script, pass the filename as the first parameter

```
$ ./main example/script.zag
```

## Web

To build the web version, run 

```
$ zig build-exe src/main.zig -target wasm32-freestanding --release-small
```
