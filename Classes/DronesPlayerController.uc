//==========================CLASS DECLARATION==================================
class DronesPlayerController extends PlayerController;

//==========================VARIABLES==========================================
var DronesDrone LastTraceHitDrone;
var DronesFogVolumeConstantDensityInfo DestinationFogVolume;

var DronesHUDWrapper HUDWrapper;

var float LastOverallDroneSpeed;

//==========================EVENTS==========================================
/** Inherited from parent class
 *  Calls the HUDWrapper's SetMouseCoordinates function every tick, which in turns moves the mouse in the GUI.
 *  If I find an event that happens every tick in the HUD class, this wouldn't have to be here */
event PlayerTick( float DeltaTime )
{	
	local vector ThisVectorLocation;
	local vector cameraLocation;
	local rotator cameraRotation;
	local Actor traceHit;
	local TraceHitInfo hitInfo;
	local vector hitLoc, hitNorm, startTraceLoc, endTraceLoc;
	local DronesDrone TraceHitDrone;
	//local vector TargetDestinationRange01, TargetDestinationRange02;
	//local vector AtoB, MidPoint;
	local rotator r;
	local vector NewScale3D;
	local StaticMeshComponent ThisStaticMeshComponent;
	local MaterialInstanceConstant ThisMaterialInstanceConstant;
	
	super.PlayerTick( DeltaTime );
		
	HUDWrapper = DronesHUDWrapper(myHUD);
	
	if (Pawn.Location.Z < -1000)
	{
		ThisVectorLocation.X = 0;
		ThisVectorLocation.Y = 0;
		ThisVectorLocation.Z = 50;
		Pawn.SetLocation(ThisVectorLocation);
	}
	
	
	if(LastTraceHitDrone != NONE)
	{
		LastTraceHitDrone.ToggleHighlightOff();
	}
	if(DestinationFogVolume != NONE)
	{
		DestinationFogVolume.Destroy();
	}
	
	cameraLocation = DronesPawn(Pawn).FinalCameraLocation;
	cameraRotation = DronesPawn(Pawn).FinalCameraRotation;
	endTraceLoc = cameraLocation + normal(vector(cameraRotation))*32768;
	startTraceLoc = cameraLocation;
	traceHit = trace(hitLoc, hitNorm, endTraceLoc, startTraceLoc, true, , hitInfo);
	
	if(traceHit == none)
	{
		//ClientMessage("Nothing found, try again.");
		HUDWrapper.bDrawDroneInfo = FALSE;
	}
	else
	{
		// By default only 4 console messages are shown at the time
		//ClientMessage(" ");
		//ClientMessage("Hit: "$traceHit$"  class: "$traceHit.class$"."$traceHit.class);
		//ClientMessage("Location: "$hitLoc.X$","$hitLoc.Y$","$hitLoc.Z);
		//ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
		//ClientMessage("Component: "$hitInfo.HitComponent);

		if(traceHit.class.name == 'DronesDrone')
		{
			TraceHitDrone = DronesDrone(traceHit);
			TraceHitDrone.ToggleHighlightOn();
			
			r.Pitch = 0; r.Yaw = 0; r.Roll = 0;

			NewScale3D.X = DronesDroneAIController(TraceHitDrone.Controller).DestinationRangeSize.X / 256;
			NewScale3D.Y = DronesDroneAIController(TraceHitDrone.Controller).DestinationRangeSize.Y / 256;
			NewScale3D.Z = DronesDroneAIController(TraceHitDrone.Controller).DestinationRangeSize.Z / 256;
			
			DestinationFogVolume = Spawn(class'DronesFogVolumeConstantDensityInfo',,,DronesDroneAIController(TraceHitDrone.Controller).DestinationRangeCenter,r,,);
			DestinationFogVolume.SetDrawScale3D (NewScale3D);
	
			foreach DestinationFogVolume.ComponentList(class'StaticMeshComponent', ThisStaticMeshComponent)
			{
				ThisMaterialInstanceConstant = ThisStaticMeshComponent.CreateAndSetMaterialInstanceConstant(0);
			}
			ThisMaterialInstanceConstant.SetVectorParameterValue('EmissiveColor',TraceHitDrone.DroneColor);
			
			HUDWrapper.bDrawDroneInfo = TRUE;
		}
		else
		{
			HUDWrapper.bDrawDroneInfo = FALSE;
		}
	}

	LastTraceHitDrone = TraceHitDrone;
}


 
//==========================EXECS==========================================
exec function StartFire( optional Byte FireModeNum )
{
	local vector cameraLocation;
	local rotator cameraRotation;
	local Actor traceHit;
	local TraceHitInfo hitInfo;
	local vector hitLoc, hitNorm, startTraceLoc, endTraceLoc;
		
	cameraLocation = DronesPawn(Pawn).FinalCameraLocation;
	cameraRotation = DronesPawn(Pawn).FinalCameraRotation;
	
	endTraceLoc = cameraLocation + normal(vector(cameraRotation))*32768;
	startTraceLoc = cameraLocation;
	
	traceHit = trace(hitLoc, hitNorm, endTraceLoc, startTraceLoc, true, , hitInfo);
	
	if(traceHit != none)
	{
		if(traceHit.class.name == 'DronesDrone')
		{
			DronesDrone(traceHit).Feed();
			HUDWrapper.DrawMessageFedDrone();
		}
		else
		{
			HUDWrapper.DrawMessageNothingHit();
		}
	}
	else
	{
		HUDWrapper.DrawMessageNothingHit();
	}
}

exec function StartAltFire( optional Byte FireModeNum )
{
	local vector cameraLocation;
	local rotator cameraRotation;
	local Actor traceHit;
	local TraceHitInfo hitInfo;
	local vector hitLoc, hitNorm, startTraceLoc, endTraceLoc;
		
	cameraLocation = DronesPawn(Pawn).FinalCameraLocation;
	cameraRotation = DronesPawn(Pawn).FinalCameraRotation;
	
	endTraceLoc = cameraLocation + normal(vector(cameraRotation))*32768;
	startTraceLoc = cameraLocation;
	
	traceHit = trace(hitLoc, hitNorm, endTraceLoc, startTraceLoc, true, , hitInfo);
	
	if(traceHit != none)
	{
		if(traceHit.class.name == 'DronesDrone')
		{
			DronesDrone(traceHit).Kill();
		}
		else
		{
		}
	}
	else
	{
	}
}

exec function ShowMenu()
{
   ConsoleCommand("Quit"); // call the quit command to quit.
}

exec function Use()
{
	//ConsoleCommand("open DronesLandscape01");
}

exec function PauseDrones()
{
	local DronesDrone ThisDrone;
	local DronesDroneAIController DroneController;
	
	`Log("In exec PauseDrones");
	
	foreach AllActors(class'DronesDrone', ThisDrone)
	{
		//DronesGame(WorldInfo.Game).CurrentDroneSpeed = 0;
		DroneController = DronesDroneAIController(ThisDrone.Controller);
		DroneController.PushState('PauseDrone');
	}
}

exec function UnpauseDrones()
{
	local DronesDrone ThisDrone;
	local DronesDroneAIController DroneController;

	`Log("In exec UnpauseDrones");
	
	foreach AllActors(class'DronesDrone', ThisDrone)
	{
		//DronesGame(WorldInfo.Game).CurrentDroneSpeed = DronesGame(WorldInfo.Game).OverallDroneSpeed;
		DroneController = DronesDroneAIController(ThisDrone.Controller);
		DroneController.PopState();
	}
}

exec function PrevWeapon()
{
	if( DronesGame(WorldInfo.Game).OverallDroneSpeed < 100)
	{
		DronesGame(WorldInfo.Game).OverallDroneSpeed += 0.5;
	}
}

exec function NextWeapon()
{
	if( DronesGame(WorldInfo.Game).OverallDroneSpeed > 0.0)
	{
		DronesGame(WorldInfo.Game).OverallDroneSpeed -= 0.5;
	}
}

//==========================STATES==========================================


//==========================FUNCTIONS==========================================
/** Inherited from parent class
 *  Controller rotates with turning input 
 *  I didn't write most of this code, so I don't understand everything it does
 *  I only added in the if clause to only update the pawn's facerotation if the right mouse button isn't down and the GUI isn't showing */
function UpdateRotation( float DeltaTime )
{
	local rotator DeltaRot, NewRotation, ViewRotation;

   ViewRotation = Rotation;
   if (Pawn!=none)
   {
      Pawn.SetDesiredRotation(ViewRotation);
   }

   // Calculate Delta to be applied on ViewRotation
   DeltaRot.Yaw   = PlayerInput.aTurn;
   DeltaRot.Pitch   = PlayerInput.aLookUp;

   ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
   SetRotation(ViewRotation);

   NewRotation = ViewRotation;
   NewRotation.Roll = Rotation.Roll;
	
	Pawn.FaceRotation(NewRotation, deltatime); //notify pawn of rotation


}


//==========================DEFAULT PROPERTIES==========================================
DefaultProperties
{

}