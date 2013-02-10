//==========================CLASS DECLARATION==================================
class DronesGame extends SimpleGame;
//class DronesGame extends UTGame;

//==========================VARIABLES==========================================
/** Holds an array of my brick actors
 *	Set in the function PostBeginPlay 
 *  Used in the function PostBeginPlay */
var array<DronesBrickShell> Bricks;
var array<DronesDrone> Drones;

var array<DronesBrickShell> BricksPP;
var array<DronesBrickShell> BricksNP;
var array<DronesBrickShell> BricksPN;
var array<DronesBrickShell> BricksNN;
var int TimeToNextBrickSort;
/*
struct yCoord
{
	var array<DronesBrickShell> Bricks;
};

struct xCoord
{
	var array<yCoord> yCoords;
};



var array<XCoord> SortedBricks;
*/

var float OverallDroneSpeed;
var float CurrentDroneSpeed;

var int NumBricks;
var int DistanceBetweenBricks;

var int NumDrones;

var bool bResetBricks;
var int ResetBricksIndex;
var int NumBricksToResetPerTick;
//==========================EVENTS==========================================
/** Inherited from parent class */
event PostBeginPlay()
{
	super.PostBeginPlay();
	
	SpawnBricks();

	SpawnDronesWithoutController();

}

event Tick ( float DeltaTime )
{
/*
//	local DronesDrone FreshDrone;
//	local vector v;

	if(bResetBricks==TRUE)
	{
		ResetBricks();
	}

	If (Drones.Length <= 0)
	{

//		v.X = 0;
//		v.Y = 0;
//		v.Z = 500;
//		FreshDrone = Spawn(class'DronesDrone',,,v,,,);
//		FreshDrone.Controller = Spawn(class'DronesDroneAIController');
//		FreshDrone.Controller.Possess(FreshDrone, FALSE);
		//`Log("end of game");
		//ConsoleCommand("open DronesLandscape01");
	}
*/
	
	if( TimeToNextBrickSort <= 0 )
	{
		SortBricksIntoPools();
		TimeToNextBrickSort=15000;
	}
	TimeToNextBrickSort--;
}

/*
event Tick ( float Deltatime)
{
	local DronesBrickKActor ThisDronesBrickKActor;
	local int Index;
	`Log(" ");
	`Log("Presort");
	foreach Bricks(ThisDronesBrickKActor, Index)
	{
		`Log("ThisDronesBrickKActor: "$ThisDronesBrickKActor$" at index: "$Index$" at location: "$ThisDronesBrickKActor.Location.X);
	}
	
	Bricks.Sort(SortBricksRandomly);
	
	`Log("Postsort");
	foreach Bricks(ThisDronesBrickKActor, Index)
	{
		`Log("ThisDronesBrickKActor: "$ThisDronesBrickKActor$" at index: "$Index$" at location: "$ThisDronesBrickKActor.Location.X);
	}
}
*/

//==========================FUNCTIONS==========================================
function ResetBricks()
{
	local int i;
	local bool bABrickWasReset;
	local int RandomIndex;
	local int NumBricksOutOfPlace;
	local DronesBrickShell CurrentBrick;
	local int FuckMeInt;
	
	NumBricksOutOfPlace=0;
	
	foreach Bricks(CurrentBrick)
	{
		if(CurrentBrick.Brick.Location != CurrentBrick.OriginalLocation)
		{
			NumBricksOutOfPlace++;
		}
	}
	
	if( NumBricksOutOfPlace < NumBricksToResetPerTick )
	{
		NumBricksToResetPerTick = NumBricksOutOfPlace;
	}
	
	for(i=0; i<NumBricksToResetPerTick; i++)
	{
		FuckMeInt = 0;
		bABrickWasReset=FALSE;
		while(bABrickWasReset==FALSE && FuckMeInt < 10000)
		{
			RandomIndex = RandRange(0, Bricks.Length-1);
			if( Bricks[RandomIndex].Availability == AVAIL_InStructure )
			{
				if( Bricks[RandomIndex].Brick.Location != Bricks[RandomIndex].OriginalLocation )
				{
					Bricks[RandomIndex].ResetPositionAndRotationToOriginal();
					Bricks[RandomIndex].Availability=AVAIL_Available;
					bABrickWasReset=TRUE;
				}
			}
			FuckMeInt++;
		}
	}
}

function ResetDrones()
{
	local DronesDrone CurrentDrone;
	while( Drones.Length > 0 )
	{
		CurrentDrone = Drones[0];
		CurrentDrone.Kill();
		/*
		Drones.RemoveItem(CurrentDrone);
		CurrentDrone.Controller.Destroy();
	//	CurrentDrone.Controller.Unpossess();
		CurrentDrone.Destroy();
		*/
	}
	
	SpawnDronesWithController();
}

function SpawnDronesWithoutController()
{
	local DronesDrone NewDrone;
	local int i;
	local rotator r;
	local vector v;
	
	for( i=0; i<NumDrones; i++)
	{
		v.X = i*500 - 6000;
		v.Y = 0;
		v.Z = 80;
		
		NewDrone = Spawn(class'DronesDrone',,,v,r,,);
		DronesDroneAIController(NewDrone.Controller).InitializeRandomBlueprint();
		NewDrone.UpdateDroneColor();
		
		Drones.AddItem(NewDrone);
	}
}

function SpawnDronesWithController()
{
	local DronesDrone NewDrone;
	local int i;
	local rotator r;
	local vector v;
	
	for( i=0; i<NumDrones; i++)
	{
		v.X = i*500 - 6000;
		v.Y = 0;
		v.Z = 80;
		
		NewDrone = Spawn(class'DronesDrone',,,v,r,,);
		NewDrone.SpawnDefaultController();
		DronesDroneAIController(NewDrone.Controller).InitializeRandomBlueprint();
		NewDrone.UpdateDroneColor();
		
		Drones.AddItem(NewDrone);
	}
}

function SpawnBricks()
{
	local DronesBrickShell NewBrick;
	local int i, j;
	local rotator r;
	local vector v;
	local int NumBricksSqrt;
		
	NumBricksSqrt = Round(Sqrt(NumBricks));
	for( i=0; i<NumBricksSqrt; i++)
	{
	for( j=0; j<NumBricksSqrt; j++)
	{
		v.X = (i*(DistanceBetweenBricks+40)) - ((DistanceBetweenBricks+40)*NumBricksSqrt)/2;
		v.Y = (j*(DistanceBetweenBricks+80)) - ((DistanceBetweenBricks+80)*NumBricksSqrt)/2;
		v.Z = 20;
		r.Pitch = 0;
		r.Yaw = 0;
		r.Roll = 0;
		//NewBrick = New class'DronesBrickShell';
		NewBrick = Spawn(class'DronesBrickShell',,,v,r,,);
		Bricks.AddItem(NewBrick);
	}
	}

	SortBricksIntoPools();
}

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

/*
function SortBricksRandomly(DronesBrickKActor BrickA, DronesBrickKActor BrickB)
{
while(Bricks.length > 0)
{
    i = Rand(Bricks.length);
    SortedBricks[SortedBricks.length] = Bricks[i];
    Bricks.Remove(i,1);
}

// SortedBricks should now be a randomized Bricks
}
*/

function SortBricksIntoPools()
{
	local DronesBrickShell CurrentBrick;
	local int i;
	
	for(i=0; i<BricksPP.Length; i++)
	{
		BricksPP.Remove(i, 1);
	}
	for(i=0; i<BricksNP.Length; i++)
	{
		BricksNP.Remove(i, 1);
	}	
	for(i=0; i<BricksPN.Length; i++)
	{
		BricksPN.Remove(i, 1);
	}	
	for(i=0; i<BricksNN.Length; i++)
	{
		BricksNN.Remove(i, 1);
	}
	
	foreach Bricks(CurrentBrick)
	{
		if( CurrentBrick.Location.X > 0 )
		{
			if( CurrentBrick.Location.Y > 0 )
			{
				BricksPP.AddItem(CurrentBrick);
			}
			else
			{
				BricksPN.AddItem(CurrentBrick);
			}
		}
		else
		{
			if( CurrentBrick.Location.Y > 0 )
			{
				BricksNP.AddItem(CurrentBrick);
			}
			else
			{
				BricksNN.AddItem(CurrentBrick);
			}
		}
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
	NumDrones = 30
	OverallDroneSpeed = 100
	NumBricks = 5000
	DistanceBetweenBricks = 200
	TimeToNextBrickSort = 0
	bResetBricks = FALSE
	NumBricksToResetPerTick = 100
	

	//MapPrefixes[1]='Tube_stairs_map_map'
	HUDType=class'Drones.DronesHUDWrapper'
	PlayerControllerClass=class'Drones.DronesPlayerController'
	//PlayerControllerClass=class'UTPlayerController'
	DefaultPawnClass=class'DronesPawn'
	//DefaultPawnClass=class'UTPawn'

}

