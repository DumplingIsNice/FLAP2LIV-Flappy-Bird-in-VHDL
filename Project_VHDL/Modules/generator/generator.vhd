-- GENERATOR
-- IN: Tracker
-- OUT: Graphics

-- The Generator module generates the background layout and obstacles
-- using simple alogorithms and RNG, and outputs a raster of the
-- composite image.
-- Output is in the format of 480xNx4 columns, where N is the number of
-- pixel columns to be sent each frame. N increases with speed. The 4
-- layers take the form of RGB and a one-bit collision flag layer.

-- The Tracker module stores the current difficulty, which influences:
-- * Background colour scheme (and perhaps pattern)
-- * Obstacle (barrier) patterns and frequency
-- * Obstacle (barrier) colour scheme and sprite shape
-- * Pickup frequency and type

-- New generation begins when the previous buffer clears (is shifted out).
-- As the speed varies, generation will be irregular, and on-demand. 
-- There is a blank space between each obstacle column, so generation
-- does not have to be continuous (we have the time to repopulate the
-- buffer before needing to shift it out again).



-- NOTE: For more complex sprites it may be cheaper to have a pool of mapped,
-- pre-defined bitmaps for objects, rather than trying to generate with vectors.