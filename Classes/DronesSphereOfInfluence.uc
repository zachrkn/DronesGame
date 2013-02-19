//==========================CLASS DECLARATION==================================
class DronesSphereOfInfluence extends DynamicSMActor
    placeable;
	
//==========================VARIABLES==========================================

//==========================EVENTS==========================================

//==========================FUNCTIONS==========================================


//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{	
	bStatic=FALSE
	bNoDelete=FALSE
	bBlockActors=FALSE
	bMovable=TRUE
	bCollideActors=FALSE
	
	bNoEncroachCheck=FALSE
	
	bCanStepUpOn=FALSE
	
	Begin Object Name=StaticMeshComponent0
        StaticMesh=StaticMesh'EngineMeshes.Sphere'

		BlockRigidBody=FALSE
		CollideActors=FALSE
		BlockActors=FALSE
		bNotifyRigidBodyCollision=FALSE
		ScriptRigidBodyCollisionThreshold=0.0001
		BlockZeroExtent=FALSE
		BlockNonZeroExtent=FALSE
		MaxDrawDistance=0
//		LightEnvironment=MyLightEnvironment
		bUsePrecomputedShadows=FALSE
		Materials[0]=Material'WP_ShockRifle.Effects.M_Shock_colorball_mesh_sphere';
    End Object

}

