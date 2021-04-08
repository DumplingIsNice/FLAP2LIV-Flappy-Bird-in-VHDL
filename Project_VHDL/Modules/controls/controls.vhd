-- CONTROLS
-- IN: <mouse_controls>
-- OUT: Graphics, Tracker

-- The Controls module monitors inputs from the user, via mouse or
-- on-board controls (buttons, DIP switches, etc).
-- On input events it interprets the input in the context of the game,
-- and generates commands for the Graphics and Tracker modules.

-- The Graphics module needs to know when the mouse clicks, so that
-- it can apply a transform to the position of the bird.
-- The Controls module needs to know when the game is paused.

