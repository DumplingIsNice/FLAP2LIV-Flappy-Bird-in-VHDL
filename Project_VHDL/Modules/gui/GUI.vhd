
------------------------- TODO: UPDATE



-- GUI
-- IN: Tracker
-- OUT: Graphics

-- The GUI module generates the GUI overlay with information from
-- the Tracker module, and sends information on bits to be overwritten
-- to the Graphics module.

-- As changed areas are sparse, data should have the following information:
-- [x_pos, y_pos, R, G, B] for each modified pixel

-- Text and icons will likely need to reference bitmaps stored in memory.
-- GUI components will be fixed in position, with a few changing elements.

-- GUI Overlay:
-- * Pause/Unpause text
-- * Lives left e.g. []x1
-- * Colour effect/transition when lives lost/gained
-- * Could show icon for active effect
-- * Could show current score/difficulty stage/time


-- NOTE: Font should be white/black with an outline, for readability