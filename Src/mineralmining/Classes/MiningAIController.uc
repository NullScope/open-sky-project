class MiningAIController extends AIController;

struct bases
{
	var MiningBase 						base;
	var array<MiningResource> 			resources;
};

var int 								team;
var int 								maxUnitCapacity;
var int 								currentUnitCapacity;
var int 								harvestersNum;

var MiningGameInfo                      MiningGame;
var MiningPlayer                        MiningPlayerController;

var array<int> 							resources;
var array<bases>						AIbases;
var array<MiningActor_Comandable> 		AIUnits;
var MiningBarracks 						barracks;

var bool 								bHasInitialBase;
var bool 								bHasBarracks;


var MiningActor 						focusedActor;
var Vector 								focusedLocation;

function PostBeginPlay()
{
	super.PostBeginPlay();

    MiningGame = MiningGameInfo(WorldInfo.Game);
    MiningGame.AIControllers.AddItem(self);
}

function Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	if(MiningGame == none){
      MiningGame = MiningGameInfo(WorldInfo.Game);
    }

	if(MiningPlayerController == none){
		MiningPlayerController = MiningPlayer(GetALocalPlayerController());
	}

	if(MiningPlayerController.gameStarted){
		update(DeltaTime);
	}
}

function addAIUnit(MiningActor_Comandable newUnit)
{
	AIUnits.AddItem(newUnit);
	newUnit.SetTeam(team);

	if(newUnit.IsA('MiningHarvester')){
		harvestersNum = harvestersNum + 1;
		if(harvestersNum < 6){
			MiningPlayerController.ClientMessage("yo");
			executeAICommand(newUnit, 2, FALSE, TRUE, FALSE, AIbases[0].resources[2]);
		}
	}

	if(newUnit.IsA('MiningBarracks')){
		barracks = MiningBarracks(newUnit);
		bHasBarracks = true;
	}
}

function MiningResource balanceResources(MiningActor_Comandable unit)
{
	local MiningResource 			tempResource;
	local bases 					tempBase;
	local bases 					closestBase;
	local MiningResource 			unbalancedResource;

	local int 						totalHarvesters;


	unbalancedResource = none;
	closestBase.base = none;
	totalHarvesters = -1;
	foreach AIbases(tempBase)
	{
		if(VSize(tempBase.base.Location - unit.Location) < VSize(closestBase.base.Location - unit.Location) || closestBase.base == none){
			closestBase = tempBase;
			//MiningPlayerController.ClientMessage(tempBase.base);
		}
	}

	if(closestBase.base != none){
		
		foreach closestBase.resources(tempResource)
		{
			if(tempResource.harvesters.length < totalHarvesters || totalHarvesters == -1){
				totalHarvesters = tempResource.harvesters.length;
				unbalancedResource = tempResource;
			}
		}
	}

	return unbalancedResource;
}

function executeAICommand(MiningActor_Comandable unit, int index, optional bool bClearQueue = true, optional bool bFocusActor = FALSE, optional bool bFocusLocation = FALSE, optional MiningActor focusActor = none, optional vector focusLocation = vect(0,0,0))
{
	if(unit.skillsInfo[index].cost <= resources[unit.skillsInfo[index].costIndex]){
		if(bClearQueue){
			unit.clearQueue();
		}


		if(bFocusActor){
			focusedActor = focusActor;
		}

		if(bFocusLocation){
			focusedLocation = focusLocation;
		}

		unit.executePreSkill(index);
		unit.addSkillQueue(index);
		resources[unit.skillsInfo[index].costIndex] = resources[unit.skillsInfo[index].costIndex] - unit.skillsInfo[index].cost;
	}
	

}

function removeAIUnit(MiningActor_Comandable removeUnit)
{
	AIUnits.RemoveItem(removeUnit);
}

function getResources(int index, int amount){
	resources[index] = resources[index]+ amount;
}

function array<MiningResource> getNearestResources(Vector baseLocation, optional int radius=1000){
	local array<MiningResource> tempArray;
	local MiningResource tempActor;

	foreach MiningGame.resources(tempActor)
	{
		if(VSize(baseLocation-tempActor.Location) <= radius){
			tempArray.AddItem(tempActor);
		}
	}	
	return tempArray;
}

function increaseCurrentUnitCapacity(int increase){
	currentUnitCapacity = currentUnitCapacity + increase;
}

function increaseMaxCurrentUnitCapacity(int increase){
	maxUnitCapacity = maxUnitCapacity + increase;
}

function update(float DeltaTime){
}

auto state gettingABase
{
	function update(float DeltaTime)
	{
		local MiningActor_Comandable 	tempBase;
		local bases 					AIBase;

		if(MiningPlayerController.gameStarted && !bHasInitialBase){

			foreach MiningGame.units(tempBase)
			{
				if(tempBase.team != MiningPlayerController.team && tempBase.MiningAIOwner == none && tempBase.IsA('MiningBase')){
					tempBase.setAIController(self);
					team = tempBase.team;
					AIBase.base = MiningBase(tempBase);
					AIBase.resources = getNearestResources(AIbase.base.Location);
					AIbases.AddItem(AIBase);

					bHasInitialBase = true;
				}	
			}
			GotoState('settingUpBase');
		}
	}
}

state settingUpBase
{
	function update(float DeltaTime)
	{
		local bases 			tempBase;

		foreach AIbases(tempBase)
		{
			
			tempBase.base.isExecuting = false;
			executeAICommand(tempBase.base, 3,FALSE, FALSE, FALSE);
		}
		if(harvestersNum >= 6){
			GotoState('settingUpArmy');
		}
	}
}

state settingUpArmy
{
	function update(float DeltaTime)
	{
		local bases 			tempBase;
		if(harvestersNum < 6){
			foreach AIbases(tempBase)
			{
				executeAICommand(tempBase.base, 1, FALSE, FALSE, TRUE,, tempBase.base.Location + vect(150,0,0));
				tempBase.base.isExecuting = false;
				executeAICommand(tempBase.base, 3,FALSE, FALSE, FALSE);
			}
		}else{
			if(bHasBarracks){
				executeAICommand(barracks, 1, FALSE, FALSE, TRUE,, barracks.Location + vect(0, 300, 0));
				executeAICommand(barracks, 3, FALSE, FALSE, FALSE,,);
			}else{
				executeAICommand(AIUnits[AIUnits.length-1], 6, FALSE, FALSE, TRUE,, AIbases[0].base.Location - vect(300, 0, 0));
			}
		}
	}
}

state idle{

}

defaultproperties
{
	resources[0] = 1000
	maxUnitCapacity = 15
	team = 2
}