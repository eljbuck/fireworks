# fireworks

`fireworks` is a an ambient soundscape firework generator and sandbox. Each firework makes different has a different sonic aesthetic and can run on its own as a passive screensaver or have the user enqueue different fireworks!

## Installation

### Method 1: 

Download .zip file from [live app.](https://ccrma.stanford.edu/~eljbuck/256A/final/)

### Method 2: Install from Source

```{bash}
$ git clone https://github.com/eljbuck/fireworks.git
```

## Run Instructions

To run the program, ensure that the [latest version](https://chuck.stanford.edu/release/) of ChucK is installed. If version 1.5.2.1 or greater is installed, ChuGL will be included. Otherwise, download the [ChuGL chugin](https://chuck.stanford.edu/release/alpha/chugl/).

From here, navigate to `fireworks/src` in terminal and run the following program:

```{bash}
$ chuck run.ck
```

## App Instructions

Use <kbd>space</kbd> to toggle user interface

Use <kbd>↑</kbd> and <kbd>↓</kbd> to navigate firework selection

Press <kbd>enter</kbd> to enqueue a firework

## Acknowledgements

The most massive shoutout to Andrew Zhu Aday for spending so much time helping me through this project. There were a lot of optimizations that I needed to make and those would not have been possible without Andrew's guidance. Also, big thanks to Tristan Peng for helping me with the HUD code for the dock and sidebar. (Also I stole your snare code again ty haha.) Of course, a huge thank you to Professor Ge Wang for his incredible ideas and inspiration throughout this project and this class more broadly. This has been one of the best classes I've ever taken, so I'm hugely appreciative. Also, shoutout to everyone for make such cool projects. 