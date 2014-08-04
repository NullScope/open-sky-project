class MiningBuilding extends MiningActor_Comandable;

var ParticleSystemComponent 				launcher1;
var ParticleSystemComponent 				launcher2;
var ParticleSystemComponent 				launcher3;
var ParticleSystemComponent 				launcher4;

var array<int> 								rallyPointActions;
var array<int> 								buildQueue;
var array<class<MiningActor_Comandable> > 	buildQueueClasses;

var(Building) bool							canSetRallyPoint;
var(Building) bool							isStorage;
var bool									isRallySet;
var(Spawn) bool 							bDoSpawnAnimation;

var Vector 									desiredLanding;
var float 									targetLandingDistance;									

var class<MiningActor_Comandable>			currentUnitClass;
var float 									currentBuildTime;
var float 									readyToSpawnTime;

var MiningRallyPoint						rallyPoint;
var Vector									rallyPointLocation;

function PostBeginPlay(){
	super.PostBeginPlay();

	unitMesh.AttachComponentToSocket(launcher1, 'Rocket_1');
	unitMesh.AttachComponentToSocket(launcher2, 'Rocket_2');
	unitMesh.AttachComponentToSocket(launcher3, 'Rocket_3');
	unitMesh.AttachComponentToSocket(launcher4, 'Rocket_4');
	
	preSkills[0] = none;
	preSkills[1] = none;
	preSkills[2] = none;

	skills[0] = cancelLastUnit;
	skills[1] = setRallyPoint;
	skills[2] = setRallyPoint;

	skillsInfo.remove(0, skillsInfo.Length);

	tempSkill.key = 11;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0;
	tempSkill.range = 0;
	tempSkill.skillName = "Cancel last unit";
	tempSkill.skillDescription = "Cancels the construction of the last unit";
	tempSkill.skillIcon = 6;
	tempSkill.skillButtonIndex = 15;
	tempSkill.requiresTarget = FALSE;

	skillsInfo.AddItem(tempSkill);

	tempSkill.key = 3;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0;
	tempSkill.range = 0;
	tempSkill.skillName = "Rally Point";
	tempSkill.skillDescription = "Sets a rally point in the targeted location";
	tempSkill.skillIcon = 11;
	tempSkill.skillButtonIndex = 1;
	tempSkill.requiresTarget = TRUE;
	
	skillsInfo.AddItem(tempSkill);

	tempSkill.key = 0;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0;
	tempSkill.range = 0;
	tempSkill.skillName = "Rally Point";
	tempSkill.skillDescription = "Sets a rally point in the targeted location";
	tempSkill.skillIcon = 11;
	tempSkill.skillButtonIndex = -1;
	tempSkill.requiresTarget = TRUE;

	skillsInfo.AddItem(tempSkill);

	if(!bDoSpawnAnimation){
		desactivateLanding();	
	}

}

function Tick(float DeltaTime){
	super.Tick(DeltaTime);

	if(isRallySet && isSelected && rallyPoint == none){
		rallyPoint = Spawn(class'MiningRallyPoint',,,rallyPointLocation);
	}else{
		if(!isSelected && rallyPoint != none){
			rallyPoint.Destroy();
			rallyPoint = none;
		}
	}

	if(!IsInState('landing')){
		GotoState('building');
	}
}

function cancelUnitQueue(int index)
{
	if(index == 0){
		currentBuildTime = 0.0f;
		readyToSpawnTime = 0.0f;
	}
		buildQueue.remove(buildQueue.Length-1, 1);
		buildQueueClasses.remove(buildQueueClasses.Length-1, 1);
}

function cancelLastUnit()
{
	if(buildQueue.Length > 1){
		buildQueue.remove(buildQueue.Length-1, 1);
		buildQueueClasses.remove(buildQueueClasses.Length-1, 1);
	}else{
		GotoState('idle');
		readyToSpawnTime = 0;
		currentBuildTime = 0;
		currentUnitClass = none;
		buildQueue.remove(buildQueue.Length-1, 1);
		buildQueueClasses.remove(buildQueueClasses.Length-1, 1);
	}

	if(MiningAIOwner == none){

	}else{

	}
}

function selectUnit(){
	super.selectUnit();
}

function deselectUnit(){
	super.deselectUnit();
	
	rallyPoint.Destroy();
	rallyPoint = none;
}

function setRallyPoint(){
	local Rotator rot;
	
	if(canSetRallyPoint){
		Rot.Pitch = (0.0f     *DegToRad) * RadToUnrRot;
		Rot.Roll =  (0          *DegToRad) * RadToUnrRot;
		Rot.Yaw =   (0.0f      *DegToRad) * RadToUnrRot;
		
		if(!isRallySet){
			if(MiningAIOwner == none){
				rallyPoint = Spawn(class'MiningRallyPoint',,,MiningPlayerOwner.mouseWorldLocation, rot);
			}
			rallyPointLocation = rallyPoint.Location;
			isRallySet = true;
		}else{
			rallyPoint.SetLocation(MiningPlayerOwner.mouseWorldLocation);
			rallyPointLocation = rallyPoint.Location;
		}
	}
}

function buildUnit(class<MiningActor_Comandable> newUnit, int skillIndex){
	
	if(buildQueue.Length < 5 ){
		if(MiningAIOwner == none){
			if(MiningPlayerOwner.currentUnitCapacity+newUnit.default.spotNBR <= MiningPlayerOwner.maxUnitCapacity){
				buildQueue.AddItem(skillIndex);
				buildQueueClasses.AddItem(newUnit);
				GotoState('building');
			}
		}else{
			if(MiningAIOwner.currentUnitCapacity+newUnit.default.spotNBR <= MiningAIOwner.maxUnitCapacity){
				buildQueue.AddItem(skillIndex);
				buildQueueClasses.AddItem(newUnit);
				GotoState('building');
			}
		}
	}
}

function spawnUnit(class<MiningActor_Comandable> unitClass){
	local Vector						spawnLocation;
	local MiningActor_Comandable		localActor;
	local Rotator Rot;
	
	Rot.Pitch = (0.0f     *DegToRad) * RadToUnrRot;
	Rot.Roll =  (0          *DegToRad) * RadToUnrRot;
	Rot.Yaw =   (0.0f      *DegToRad) * RadToUnrRot;
	
	spawnLocation = Location;
	
	if(isRallySet){
		if(rallyPointLocation.Y >= Location.Y){
			spawnLocation.Y += radius;
		}else{
			spawnLocation.Y -= radius;
		}
		
		if(rallyPointLocation.X >= Location.X){
			spawnLocation.X += radius;
		}else{
			spawnLocation.X -= radius;
		}
	}else{
		spawnLocation.Y += radius;
	}

	localActor = Spawn(unitClass,,,spawnLocation, rot);
	
	localActor.setTeam(team);
	
	if(isRallySet){
		spawnLocation = rallyPointLocation;
		localActor.addDestination(spawnLocation, 0);
		localActor.addSkillQueue(1);
	}
	if(MiningAIOwner == none){
		MiningPlayerOwner.increaseCurrentUnitCapacity(localActor.default.spotNBR);
	}else{
		MiningAIOwner.increaseCurrentUnitCapacity(localActor.default.spotNBR);
		MiningAIOwner.addAIUnit(localActor);
	}
}

function unitLand(){
	local Vector direction;

	isExecuting = true;
	direction = (desiredLanding - Location);
	targetLandingDistance = VSize(direction);
	Velocity = direction * (moveSpeed/VSize(direction));
	GotoState('landing');
}

function setDesiredLanding(Vector newLocation){

	desiredLanding = newLocation;
}

function desactivateLanding(){
	launcher1.DeactivateSystem();
	launcher2.DeactivateSystem();
	launcher3.DeactivateSystem();
	launcher4.DeactivateSystem();

	launcher1.killParticlesForced();
	launcher2.killParticlesForced();
	launcher3.killParticlesForced();
	launcher4.killParticlesForced();
}

state building{
	function update(float DeltaTime)
	{
		if(buildQueue.Length > 0){
			currentBuildTime = currentBuildTime+DeltaTime;
			readyToSpawnTime = skillsInfo[buildQueue[0]].castTime;
			if(currentBuildTime >= readyToSpawnTime){
				currentBuildTime = 0;
				spawnUnit(buildQueueClasses[0]);
				buildQueue.remove(0,1);
				buildQueueClasses.remove(0,1);
			}
		}else{
			GotoState('idle');
		}
	}
}

state landing{
	function update(float DeltaTime){
		local Vector direction;
		if(targetLandingDistance <= 0 ){
			isExecuting = false;
			GotoState('idle');
			return;
		}else{
			direction = (desiredLanding - Location);
			targetDistance = VSize(direction);
			Velocity = direction * (moveSpeed/VSize(direction));
			Move(Velocity * DeltaTime);
			targetLandingDistance -= VSize(Velocity * DeltaTime);	
		}	
	}
}

defaultproperties
{
	radius = 130
	isRallySet = FALSE
	bIsStationary=true
	bDoSpawnAnimation=true
	ObstacleType=EShape_Circle

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_WP_RocketLauncher_RocketTrail'
		bAutoActivate = true;
	End Object

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent1
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_WP_RocketLauncher_RocketTrail'
		bAutoActivate = true;
	End Object

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent2
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_WP_RocketLauncher_RocketTrail'
		bAutoActivate = true;
	End Object

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent3
		Template=ParticleSystem'MineralMiningGameContent.ParticleSystems.P_WP_RocketLauncher_RocketTrail'
		bAutoActivate = true;
	End Object

	launcher1 = ParticleSystemComponent0;
	launcher2 = ParticleSystemComponent1;
	launcher3 = ParticleSystemComponent2;
	launcher4 = ParticleSystemComponent3;
}