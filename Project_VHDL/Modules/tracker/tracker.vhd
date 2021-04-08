-- TRACKER
-- IN: Controls, Collision
-- OUT: Generator, GUI

-- The Tracker module stores and updates game information.
-- This includes the bird's lives, the score, the time,
-- difficulty stage, active effects, game state, etc.

-- The Tracker receives pause/unpause commands from the Controller,
-- changing the game's state, and collision events from the
-- Collision module, with which it can apply damage or pickup
-- effects.

-- The Tracker then sends this information to the GUI to display,
-- and to the generator as arguments (the generator needs to know
-- the current difficulty when generating obstacles and landscapes,
-- and must be disabled to pause the game).
