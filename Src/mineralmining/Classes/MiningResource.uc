class MiningResource extends MiningActor;

struct resourceInfo{
	var(Resource) editinline String		name;
	var(Resource) editinline int		resourceIndex;
	var(Resource) editinline int		maxCapacity;
};

var int									currentCapacity;
var(Resource) editinline resourceInfo	info;
var array<MiningHarvester> 				harvesters;

function PostBeginPlay(){
	super.PostBeginPlay();
	
	currentCapacity = info.maxCapacity;
	MiningGame.resources.AddItem(self);
}

function tick(float DeltaTime){
	super.Tick(DeltaTime);
	
	if(currentCapacity <= 0){
		kill();
	}
}

function removeHarvester(MiningHarvester deleteHarvester)
{
	harvesters.RemoveItem(deleteHarvester);
}	

function setHarvester(MiningHarvester newHarvester)
{
	harvesters.AddItem(newHarvester);
}

function kill(){
	MiningGame.resources.RemoveItem(self);
	destroy();
}

function harvested(int harvestAmount){
	currentCapacity -= harvestAmount;	
}

defaultproperties
{
	bIsStationary=true
	ObstacleType=EShape_Circle
}