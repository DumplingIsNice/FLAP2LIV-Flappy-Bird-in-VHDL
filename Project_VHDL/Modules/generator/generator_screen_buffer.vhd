-- GENERATOR_SCREEN_BUFFER

-- IN: Generator
-- OUT: Graphics

-- Block in memory that stores predetermined data to be sent to the VGA output.
-- Predetermined data includes background imagery and obstacles (including collision
-- bool layer). The bird sprite and GUI are overlayed in the Graphics module.

-- It works as a shift register, moving along a set number of pixels each frame.
-- Only the Generator module writes to this memory block.
-- The Graphics module reads this block, sending pixel columns overlapping with the bird
-- sprite to the Collision module, and overwriting pixels with GUI content and bird sprite
-- before sending the final composite to the VGA output module.