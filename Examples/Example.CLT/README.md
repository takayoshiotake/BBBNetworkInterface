# Command Line Tool Example

This example displays network interfaces on your device.

This example project compiles BBBNetworkInterface sources, instead of using BBBNetworkInterface.framework. 
> I could not use this framework on Command Line Tool project by runtime error:  
> dyld: Library not loaded: @rpath/libswiftCore.dylib ...

## Build
First, you must checkout BBBNetworkInterface sources;

```
$ carthage checkout
```

Or you can use latest sources;

```
$ carthage update --no-build
```

Lets build with Xcode.
