class DronesParticleEventManager extends ParticleEventManager;


event PostBeginPlay()
{
    `Log("DronesParticleEventManager PostBeginPlay()");
    super.PostBeginPlay();
}


event HandleParticleModuleEventSendToGame( ParticleModuleEventSendToGame InEvent, const out vector InCollideDirection, const out vector InHitLocation, const out vector InHitNormal, const out name InBoneName )
{
	`Log("DronesParticleEventManager HandleParticleModuleEventSendToGame()");
}