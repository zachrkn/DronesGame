//==========================CLASS DECLARATION==================================
class DronesGame extends SimpleGame;
//class DronesGame extends UTGame;

//==========================VARIABLES==========================================
/** Holds an array of my brick actors
 *	Set in the function PostBeginPlay 
 *  Used in the function PostBeginPlay */
var array<DronesBrickKActor> AvailableBricks;
var array<DronesBrickKActor> UnavailableBricks;

var float OverallDroneSpeed;
var float CurrentDroneSpeed;

var int NumDrones;

//==========================EVENTS==========================================
/** Inherited from parent class */
event PostBeginPlay()
{
	local DronesBrickKActor NewBrick;
	local int i;
	local rotator r;
	local vector v;
			
	// invoke the PostBeginPlay method of the parent class
	super.PostBeginPlay();

	// spawn bricks
	for( i=0; i<5000; i++)
	{
		v.X = RandRange(-4500,2000);
		v.Y = RandRange(-3000, 7000);
		v.Z = RandRange(50, 500);
		r.Pitch = 0;
		r.Yaw = 0;
		r.Roll = 0;

		NewBrick = Spawn(class'DronesBrickKActor',,,v,r,,);
		NewBrick.SetPhysics(PHYS_rigidbody);
			
		AvailableBricks.AddItem(NewBrick);
	}
	
	/*
	v.X = 1000;
	v.Y = 3000;
	v.Z = 500;
	NewDrone = Spawn(class'DronesDrone',,,v,,,);
	NewDrone.Controller = Spawn(class'DronesDroneAIController');
	NewDrone.Controller.Possess(NewDrone, FALSE);
	*/
	
}


event Tick ( float DeltaTime )
{
	local DronesDrone OutActor;
	local DronesDrone FreshDrone;
	local vector v;
	NumDrones = 0;
	
	foreach AllActors(class'DronesDrone', OutActor)
	{
		NumDrones++;
	}
	//`Log("number of Drones" $NumActors);
	If (NumDrones <= 0)
	{
		v.X = 0;
		v.Y = 0;
		v.Z = 500;
		FreshDrone = Spawn(class'DronesDrone',,,v,,,);
		FreshDrone.Controller = Spawn(class'DronesDroneAIController');
		FreshDrone.Controller.Possess(FreshDrone, FALSE);
		//`Log("end of game");
		//ConsoleCommand("open DronesLandscape01");
	}
}

/*
event Tick ( float Deltatime)
{
	local DronesBrickKActor ThisDronesBrickKActor;
	local int Index;
	`Log(" ");
	`Log("Presort");
	foreach AvailableBricks(ThisDronesBrickKActor, Index)
	{
		`Log("ThisDronesBrickKActor: "$ThisDronesBrickKActor$" at index: "$Index$" at location: "$ThisDronesBrickKActor.Location.X);
	}
	
	AvailableBricks.Sort(SortBricks);
	
	`Log("Postsort");
	foreach AvailableBricks(ThisDronesBrickKActor, Index)
	{
		`Log("ThisDronesBrickKActor: "$ThisDronesBrickKActor$" at index: "$Index$" at location: "$ThisDronesBrickKActor.Location.X);
	}
}
*/

//==========================FUNCTIONS==========================================
delegate int SortBricks(DronesBrickKActor BrickA, DronesBrickKActor BrickB)
{
	if(BrickA.Location.X > BrickB.Location.X)
	{
		return 1;
	}
	else
	{
		return -1;
	}
}

delegate int SortBricksRandomly(DronesBrickKActor BrickA, DronesBrickKActor BrickB)
{
	if(RandRange(0,1) < 0.5)
	{
		return -1;
	}
	else
	{
		return 1;
	}
}

function Actor GetStaticMeshActorInstanceByTag(name actorTag)
{
	local StaticMeshActor actorInstance;

	foreach AllActors(class'StaticMeshActor', actorInstance)
	{
		if(actorInstance.Tag == actorTag)
			return actorInstance;
	}

	return None;
}

function Actor GetDecalActorMovableInstanceByTag(name actorTag)
{
	local DecalActorMovable actorInstance;

	foreach AllActors(class'DecalActorMovable', actorInstance)
	{
		if(actorInstance.Tag == actorTag)
			return actorInstance;
	}

	return None;
}

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return Default.Class;
}

//==========================DEFAULT PROPERTIES==========================================
defaultproperties
{
	OverallDroneSpeed = 10

	//MapPrefixes[1]='Tube_stairs_map_map'
	HUDType=class'Drones.DronesHUDWrapper'
	PlayerControllerClass=class'Drones.DronesPlayerController'
	//PlayerControllerClass=class'UTPlayerController'
	DefaultPawnClass=class'DronesPawn'
	//DefaultPawnClass=class'UTPawn'

}

