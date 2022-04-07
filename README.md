# GravitySim

Drawing a gravity map for static bodies and flying satellites through it

---

## Overview

The user can place and size any number of celestial bodies into the "sky", a 2D plane, and the program will automatically update the background to display a map of the gravity for the environment.

![Lunar mission gif](/Movies/lunar%20mission.gif)

The strength of the force is given by the brightness of the color, and the direction of the force is given by the Hue. Black means there is no force, neon colors surround each body as the force is strongest there. So, placing two bodies next to each other, there should be a black smudge in between the two where the gravitational forces cancel out.

![Satellite weaving example gif](/Movies/weaving.gif)

---

## Coding Environment

This project is built in [Processing](processing.org), a framework to write java code to display images and shapes on the screen. Download the latest version to run it, since github won't allow me to upload the exported edition.

![Processing coding environment](/Movies/Processing%20code.png)

I'm using version 4.0b7, but I'm not using anything too fancy so I'm guessing that it should work with most other versions. Perhaps the recordings would break.

Since I don't expect you to run this, I've included several pre-made gifs of simulations in the `Movies` folder. These are made by capturing each frame as a `frames/<#>.tif` file, and then using Processing's included movie maker. The colors are grainy due to the gif compression, so a few images are included as well.

![Quality pic of many satellites orbiting](/Movies/quality%20pic%20of%20orbits.png)
![Quality pic of many bodies](/Movies/quality%20pic%20of%20many%20bodies.png)

It's really quite smooth and pretty, so it's a shame that the gif doesn't show that.

---

## Code Explanation

The code is very well commented, but a description of how it works follows:

### Processing Specific Functions
`GravitySim.pde`
1. The processing `setup()` function is called and initializes all of our variables
2. Each frame (60 frames per second is the default), the `draw` function is called. This draws the background map, the bodies on top of that, then updates/moves the satellites and draws them on top of it all. It also draws any UI elements, like the path the satellite will take, or the mouse cursor.
`Input.pde`
3. If the mouse is clicked or a key is pressed, the corresponding `mouseClicked()` or `keyPressed()` function is called. I route these to the proper UI functions to actually interact as needed.

### Global classes

There are 5 global variables. These are items that I wanted to persist across files, especially the `setup()`, `draw()`, and `mouseClicked()` functions. Technically global variables are not suggested practice, but for such a small program, I saw no use in making a wrapper for them or creating references between each object.

They are prefixed with "g_" to indicate that they are global. The 5 are:
- g_bodies
- g_satellites
- g_forceMap
- g_ui
- g_recorder

### Helper `JAarray.pde`

Having used a lot of python recently, I really wanted a version of NumPy to make it easy to create and add matrices. So, I built my own basic version called JArray. While not the most efficient, this helped abstract away the matrix math from the actual logic of the program. I hope to use this in other projects as well

### `ForceMap.pde`

This class is responsible for creating the colored backgrounds of the gravity. I made it somewhat roundabout, to allow for different methods of modifying the map.

When adding a new body, the `addBody()` function is called. This creates a new ForceMap from the body. It loads the specifics of the body into a Gravity class, which can be used as an equation to create a new JArray. This fills the entire array with the result of the gravity calculation.

With the new ForceMap, a copy of this is stored in the body, and then it is added to the current ForceMap, to update the total forces.

Finally, the actual image is created. Processing's JImage class allows us to modify the pixel data of an image. The `getGravityColor()` function converts a force vector into a color value, which we do for each location/pixel on screen.

### `Body.pde` Superclass

Body is a superclass for both the bodies and the satellites, as they share a lot of properties.

It is pretty basic and mostly used for storing data. A copy of the gravity map is stored here too, but the actual data that's displayed is stored as the combined version of the gravity map.

### `Satellite.pde`

These are sub-classes of the Body class. This is more imporant since it contains the velocity for the satellite and functions to update it. It uses the ForceMap in its location, then uses basic calculus to update the velocity, then update the position with these values.

It also contains checks for if the satellite is out of bounds or if it's collided with a planet, and then stores a flag of if it should be deleted or not. When looping through, we check this flag and delete the satellite as desired.

### `UI.pde`

I wanted to wrap all of the UI functionality into one class to keep it together and rename the functions with what they actually do.

So, this includes functions to add bodies and update the force map, add satellites, start/stop recordings, clear the screen, and show all of the various UI elements (like the launch path).

![Twisty launch of satellite](/Movies/multi-planet%20launch_mouse.png)

### `Recording.pde`

This contains all of the code to record the simulation. It stores the data as `.tif` frames in the `frames/` folder.

It has a flag whether it's recording or not, and if it does calls the function to save a frame. It does this before the UI elements are drawn, meaning that it avoids capturing the mouse. When recording, you also aren't allowed to click anywhere.

Start a recording with 'k', it clears all of the satellites and launches the last one. It counts up until the satellite either dies or at 200 frames. It uses an observer interface to know when the satellite dies.

---

## Operating the Simulation


### Clicks

For bodies:
Clicking once will center your object at that location, then it will follow the mouse to choose how large the body is. Clicking a second time will place the body and update the gravity map.

For satellites:
Clicking once will choose the starting point for the satellite, and it will begin tracing the path that the satellite will follow. Clicking a second time will launch the satellite towards your mouse, using the distance and angle of the mouse as the velocity for the created satellite.

![Path drawing example](/Movies/satellite_launch_mouse.png)

### Keyboard commands

- SPACE: Changes the mode between placing a planet or placing a satellite
- 'r': reset: resets the entire simulation back to empty
- 'c': clear: clears just the satellites from the simulation
- 'v': "ctrl+v": pastes the last satellite you just created a second time. Fun to make streams of them, or to rewatch the path
- 'k': start recording: clears all satellites and pastes the last launched one, then begins recording the frames of the simulation
- 'l': stop recording: stops saving the frames for recording (will automatically stop after 200 frames as well)

### Other notes

- The satellites will be destroyed if they crash into a planet
- The satellites will be destroyed if they run off the screen. I suggest making your bodies small and centered if you want to avoid this.
- The satellites don't affect each other. They can cross paths and won't crash or exert gravity on each other.
- Planets can overlap. This is helpful for making near-uniform gravity maps
![Uniform gravity map making a parabolic launch](/Movies/parabolic%20ground%202.gif)
- There is not limit to the number of bodies or satellites. Your computer may run slower though
- To clear either a partial body or unlaunched satellite, hit space_bar to swap the modes and it will clear your choice
- The mode that you're in is shown by either a circle for a body, or a square for a satellite.

#### Built March 2022 by Jake Swartwout