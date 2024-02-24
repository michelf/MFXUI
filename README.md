MFXUI
=====

MFXUI is a collection of helpers to build user interfaces for macOS, iOS, and tvOS using in a declartive style similar to SwiftUI. It builds hiearchies of AppKit or UIKit views and has some provisions for bindings. In the most cases, MFXUI uses the system views unchanged, only adding extension methods and initializers (many of which are provided by UXKit).

**This is experimental at the moment.** It *works*, but the structure of the API is still subjet to change. Expect future versions of this library to break client code.


TODO
----

- Untangle things with UXKit. Currently the UXKit module is part of the MFXUI package because the initial idea was to replace it. But whether MFXUI should be a full replacement or a complement is still up in the air.


Acknowledgments
---------------

MFXUI by [Michel Fortin](https://michelf.ca/).

This is an extension of **UXKit** by [ZeeZide](http://zeezide.de).
