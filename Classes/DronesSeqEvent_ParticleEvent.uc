class DronesSeqEvent_ParticleEvent extends SeqEvent_ParticleEvent;

/************************************************************************/
/* Enums, consts, structs, etc.                                         */
/*********************************************************************** */
/*
enum EParticleEventOutputType
{
	ePARTICLEOUT_Spawn,
	ePARTICLEOUT_Death,
	ePARTICLEOUT_Collision,
	ePARTICLEOUT_AttractorCollision,
	ePARTICLEOUT_Kismet
};
*/

function Initialize()
{
	local Actor ThisActor;
	local WorldInfo ThisWorldInfo;
	`Log("Initializing DronesSeqEvent_ParticleEvent");
	ThisWorldInfo = GetWorldInfo();
	
	foreach ThisWorldInfo.AllActors(class'Actor', ThisActor)
	{
		if(ThisActor.name == 'Emitter_0')
		{
			Instigator = ThisActor;
		}
	}
	
	`Log("Instigator: " $Instigator);
}

event Activated ()
{
	super.Activated();
	`Log("DronesSeqEvent_ParticleEvent Event Activated!");
}

event RegisterEvent ()
{
	super.RegisterEvent();
	`Log("DronesSeqEvent_ParticleEvent RegisterEvent");
}

defaultproperties
{
	MaxTriggerCount=0
}