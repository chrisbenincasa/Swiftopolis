Swiftopolis
===

Swiftopolis is a port of [Micropolis](https://code.google.com/p/micropolis/) written in Swift. Swiftopolis is heavily based on both 
Micropolis and [MicropolisJ](https://github.com/jason17055/micropolis-java) written by @jason17055.

### Why make another port?

I thought that porting Micropolis to the Swift language would serve as a good exercise in learning the Swift language as well as
getting more acquainted with game programming. I have been a fan of the SimCity series for as long as I can remember and became 
fascinated and overwhelmed when the source code to the original game was open sourced. 

### Running Swiftopolis

At the moment, Swiftopolis must be built from source using XCode (see the section below). This produces an executable file that is 
runnable on OSX 10.10 and up. I have not attempted to build Swiftopolis for OSX 10.9, but Swift programs do run on that version, so 
it is possible in theory.

### Building Swiftopolis

Right now the easiest way to build Swiftopolis is to clone this repo and open the .xcodeproj file in XCode. I have been developing 
Micropolis using XCode 6.2 Beta (6C107a), but I have also built it using version 6.1.1. Just open the project file and build using 
XCode.

Eventually, I will write some scripts to generate the executable without using XCode.

### Future

Swiftopolis is currently non-playable. I am in the process of fleshing out the user interface and having it interact with the 
simulation, which is complete. The main focus right now is just completing the port, however I have some really cool ideas in store 
for when everything is finished! I hope to add features and complexity to the original engine.
