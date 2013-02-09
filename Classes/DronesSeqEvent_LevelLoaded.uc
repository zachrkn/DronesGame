/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 *
 * This event will be fired when a level is loaded and made visible. It is primarily 
 * used for notifying when a sublevel is associated with the world.
 *
 **/
class DronesSeqEvent_LevelLoaded extends SeqEvent_LevelLoaded
	native(Sequence);

event Activated ()
{
	super.Activated();
	`Log("LevelLoaded Event Activated!");
}

event RegisterEvent ()
{
	super.RegisterEvent();
	`Log("LevelLoaded RegisterEvent");
}

event Toggled ()
{
	super.Toggled();
	`Log("LevelLoaded Toggled Event");
}