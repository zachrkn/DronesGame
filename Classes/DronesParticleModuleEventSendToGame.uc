/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class DronesParticleModuleEventSendToGame extends ParticleModuleEventSendToGame;
/*
	native(Particle)
	abstract
	editinlinenew
	hidecategories(Object);
*/

/** This is our function to allow subclasses to "do the event action" **/
function DoEvent( const out vector InCollideDirection, const out vector InHitLocation, const out vector InHitNormal, const out name InBoneName )
{
	super.DoEvent(InCollideDirection, InHitLocation, InHitNormal, InBoneName);
	`Log("Do Event triggered in class DronesParticleModuleEventSendToGame");
}



defaultproperties
{
}

