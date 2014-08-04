class MiningHarvester extends MiningActor_Comandable;

var ParticleSystemComponent			harvestParticle;
var ParticleSystemComponent 		thrusterParticle;
var ParticleSystemComponent 		groundDustParticle;

var int								currentHarvest;
var int								maxCapacity;
var int								harvestAmount;

var float							currentHarvestTime;
var float							harvestRate;

var array<MiningResource>			harvestResources;
var array<class<MiningBuilding> > 	buildingTypes;
var array<Vector>					buildingLocations;

var MiningConstructor 				currentConstructor;
var MiningResource					currentResource;
var MiningBuilding					nearestStorage;

function PostBeginPlay(){
	super.PostBeginPlay();

	unitMesh.AttachComponentToSocket(harvestParticle, 'fireLocation');
	unitMesh.AttachComponentToSocket(thrusterParticle, 'RearCenterThrusterSocket');
	unitMesh.AttachComponentToSocket(groundDustParticle, 'GroundEffectSocket');

	tempSkill.key = 10;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Mine";
	tempSkill.skillDescription = "Mines the selected resource";
	tempSkill.skillIcon = 9;
	tempSkill.skillButtonIndex = 6;
	tempSkill.requiresTarget = TRUE;
	
	skillsInfo[2] = tempSkill;

	tempSkill.key = 14;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Deliver Resources";
	tempSkill.skillDescription = "Delivers the resources to base";
	tempSkill.skillIcon = 7;
	tempSkill.skillButtonIndex = 7;
	tempSkill.requiresTarget = FALSE;
	
	skillsInfo.AddItem(tempSkill);

	tempSkill.key = 23;
	tempSkill.cost = 500;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 5.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Build Base";
	tempSkill.skillDescription = "Builds a base at the selected location";
	tempSkill.skillIcon = 3;
	tempSkill.skillButtonIndex = 11;
	tempSkill.requiresTarget = TRUE;
	
	skillsInfo.AddItem(tempSkill);

	tempSkill.key = 12;
	tempSkill.cost = 100;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 2.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Build Supply Depot";
	tempSkill.skillDescription = "Builds a supply depot at the selected location";
	tempSkill.skillIcon = 3;
	tempSkill.skillButtonIndex = 12;
	tempSkill.requiresTarget = TRUE;
	
	skillsInfo.AddItem(tempSkill);

	tempSkill.key = 10;
	tempSkill.cost = 350;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 7.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Build Barracks";
	tempSkill.skillDescription = "Builds a barracks at the selected location";
	tempSkill.skillIcon = 3;
	tempSkill.skillButtonIndex = 13;
	tempSkill.requiresTarget = TRUE;
	
	skillsInfo.AddItem(tempSkill);

	tempSkill.key = 21;
	tempSkill.cost = 0;
	tempSkill.costIndex = 0;
	tempSkill.cooldown = 0;
	tempSkill.castTime = 0.0f;
	tempSkill.range = 0;
	tempSkill.skillName = "Continue Construction";
	tempSkill.skillDescription = "Continues the construction of the selected building";
	tempSkill.skillIcon = 8;
	tempSkill.skillButtonIndex = 14;
	tempSkill.requiresTarget = TRUE;
	
	skillsInfo.AddItem(tempSkill);
}

function Tick(float DeltaTime){
	super.Tick(DeltaTime);
	
	if(!IsInState('harvesting') && !IsInState('building') && harvestParticle.bIsActive){
		harvestParticle.DeactivateSystem();	
		harvestParticle.KillParticlesForced();
	}

	if(!IsInState('harvesting') && currentResource != none){
		currentResource.removeHarvester(self);
	}

	//MiningPlayerOwner.ClientMessage("WHAT"$currentResource.Name);
}

function clearQueue(){
	super.clearQueue();
	harvestResources.remove(0, harvestResources.Length);	
}

function prepareHarvest(){
	if(MiningAIOwner == none){
		if(MiningPlayerOwner.mouseActor.isA('MiningResource')){
			harvestResources.AddItem(MiningResource(MiningPlayerOwner.mouseActor));
		}else{
			if(MiningPlayerOwner.mouseActor.IsA('MiningConstructor')){
				currentConstructor = MiningConstructor(MiningPlayerOwner.mouseActor);
				skillsQueue.remove(skillsQueue.Length-1,1);
				addSkillQueue(7);
			}else{
				skillsQueue.remove(skillsQueue.Length-1,1);
				addDestination(MiningPlayerOwner.mouseActor.Location, MiningPlayerOwner.mouseActor.radius+radius);
				addSkillQueue(1);
			}
		}
	}else{
		if(MiningAIOwner.focusedActor.isA('MiningResource')){
			harvestResources.AddItem(MiningResource(MiningAIOwner.focusedActor));
		}else{
			if(MiningAIOwner.focusedActor.IsA('MiningConstructor')){
				currentConstructor = MiningConstructor(MiningAIOwner.focusedActor);
				skillsQueue.remove(skillsQueue.Length-1,1);
				addSkillQueue(7);
			}else{
				skillsQueue.remove(skillsQueue.Length-1,1);
				addDestination(MiningAIOwner.focusedActor.Location, MiningAIOwner.focusedActor.radius+radius);
				addSkillQueue(1);
			}
		}
	}
}

function prepareBase(){
	if(MiningAIOwner == none){
		buildingLocations.AddItem(MiningPlayerOwner.mouseWorldLocation);
	}else{
		buildingLocations.AddItem(MiningAIOwner.focusedLocation);
	}
	buildingTypes.AddItem(class'MiningBase');
}

function prepareSupplyDepot(){
	if(MiningAIOwner == none){
		buildingLocations.AddItem(MiningPlayerOwner.mouseWorldLocation);
		
	}else{
		buildingLocations.AddItem(MiningAIOwner.focusedLocation);
	}
	buildingTypes.AddItem(class'MiningDepot');
}

function prepareBarracks(){
	if(MiningAIOwner == none){
		buildingLocations.AddItem(MiningPlayerOwner.mouseWorldLocation);
	}else{
		buildingLocations.AddItem(MiningAIOwner.focusedLocation);
	}
	buildingTypes.AddItem(class'MiningBarracks');
}

function prepareConstructor(){
	if(MiningAIOwner == none){
		if(MiningPlayerOwner.mouseActor.IsA('MiningConstructor')){
			currentConstructor = MiningConstructor(MiningPlayerOwner.mouseActor);
		}
	}else{
		if(MiningAIOwner.focusedActor.IsA('MiningConstructor')){
			currentConstructor = MiningConstructor(MiningAIOwner.focusedActor);
		}
	}
}

function harvest(){
	local Vector direction;

	if(harvestResources.Length > 0){
		currentResource = harvestResources[0];
		harvestResources.Remove(0,1);

	}else{
		if(currentResource == none){
			currentResource = getClosestResource();
		}	
	}
	
	if(currentResource != none){
		
		if(getDistanceBetweenActors(self, currentResource) > 0){
			addDestination(currentResource.Location, currentResource.radius+radius);
			skillsQueue.InsertItem(0, 1);
			skillsQueue.InsertItem(1, 2);
			isExecuting = false;
		}else{
			direction = currentResource.Location - Location;
			direction.Z = 0;
			SetRotation(Rotator(direction));
			SetCollisionType(COLLIDE_NoCollision);

			currentResource.setHarvester(self);
			GotoState('harvesting');
			harvestParticle.SetVectorParameter('LinkBeamEnd', currentResource.Location);
			harvestParticle.SetVectorParameter('LinkBeamStart', Location);
			harvestParticle.ActivateSystem();
		}
	}else{
		isExecuting = false;
	}
}

function MiningResource balanceResources()
{
	local array<MiningResource>		possibleResources;
	local MiningResource 			tempActor;
	local MiningResource 			closestResource;
	local bool 						foundUnbalancedResource;


	closestResource = none;
	foreach MiningGame.resources(tempActor)
	{
		if(tempActor.Class == currentResource.Class && VSize(Location - tempActor.Location) <= 1500 && tempActor.harvesters.Length < currentResource.harvesters.Length){
			possibleResources.AddItem(tempActor);
			foundUnbalancedResource = true;
			MiningPlayerOwner.ClientMessage(foundUnbalancedResource);
		}
	}
	
	if(foundUnbalancedResource){
		foreach possibleResources(tempActor)
		{
			if((VSize(Location - tempActor.Location) < VSize(Location - closestResource.Location)) || closestResource == none){
				closestResource = tempActor;
			}
		}
	}else{
		return currentResource;
	}

	return closestResource;
}

function buildBase(){
	makeBuilding(4);
}

function buildDepot(){
	makeBuilding(5);
}

function buildBarracks(){
	makeBuilding(6);
}

function makeBuilding(int skillIndex){
	local MiningActor_Comandable	tempActor;
	local MiningConstructor 		localConstructor;
	local Rotator rot;

	Rot.Pitch = (0.0f*DegToRad)*RadToUnrRot;
	Rot.Roll =  (0*DegToRad)* RadToUnrRot;
	Rot.Yaw =   (45.0f*DegToRad)*RadToUnrRot;

	localConstructor = Spawn(class'MiningConstructor',,,buildingLocations[0],Rot);

	if(localConstructor == none){
		foreach MiningGame.units(tempActor)
		{
			if(tempActor.team == team && tempActor.IsA('MiningConstructor') && tempActor.Location == buildingLocations[0]){
				localConstructor = MiningConstructor(tempActor);
			}
		}
	}else{
		localConstructor.setRadius(buildingTypes[0].Default.radius);
		localConstructor.setTeam(team);
		localConstructor.setBuildingToSpawn(buildingTypes[0]);
		localConstructor.setConstructionTime(skillsInfo[skillIndex].castTime);
	}
	buildingTypes.remove(0, 1);
	buildingLocations.remove(0, 1);
	currentConstructor = localConstructor;
	addSkillQueue(7);
	isExecuting = false;
}

function buildConstructor(){
	if(getDistanceBetweenActors(self, currentConstructor) > 0){
		addDestination(currentConstructor.Location, currentConstructor.radius+radius);
		addSkillQueue(1);
		addSkillQueue(7);
		isExecuting = false;
	}else{
		GotoState('building');
		harvestParticle.SetVectorParameter('LinkBeamEnd', currentConstructor.Location);
		harvestParticle.SetVectorParameter('LinkBeamStart', Location);
		harvestParticle.ActivateSystem();
		currentConstructor.setMiningBuilder(self);
	}
	
}


function MiningResource getClosestResource(){
	local MiningResource	closestResource, tempActor;
	local float				closestDistance;
	
	closestDistance = 999999;
	foreach MiningGame.resources(tempActor){
		if(VSize(tempActor.Location - Location) <= closestDistance && VSize(tempActor.Location - Location) <= 500){
			closestDistance = VSize(tempActor.Location - Location);
			closestResource = tempActor;
		}
	}
	
	return closestResource;
}

function prepareClosestStorage(){
	getClosestStorage();
}

function MiningBuilding getClosestStorage(){
	local MiningActor_Comandable	tempActor;
	local MiningBuilding			closestStorage;
	local float						closestDistance;
	
	closestDistance = 999999;
	foreach MiningGame.units(tempActor){
		if(tempActor.team == team && tempActor.isA('MiningBuilding') && VSize(tempActor.Location - Location) < closestDistance){
			closestDistance = VSize(tempActor.Location - Location);
			closestStorage = MiningBuilding(tempActor);
		}
	}
	
	return closestStorage;
}

state building{
	function update(float DeltaTime){
		if (currentConstructor.currentConstructionTime >= currentConstructor.constructionTime)
		{
			currentConstructor = none;
			harvestParticle.DeactivateSystem();
			harvestParticle.KillParticlesForced();
		}
	}
}

state idle{
	Begin:
		SetCollisionType(COLLIDE_BlockAll);
		
}

state harvesting{
	function update(float DeltaTime){
		if(currentResource.currentCapacity > 0 && currentHarvest < maxCapacity){
			if(currentHarvestTime < harvestRate){
				currentHarvestTime+=DeltaTime;	
			}else{
				currentHarvestTime = 0.0f;
				if(currentResource.currentCapacity >= harvestRate){
					if(currentHarvest+harvestAmount > maxCapacity){
						currentHarvest+=maxCapacity - currentHarvest;
					}else{
						currentHarvest += harvestAmount;
						currentResource.harvested(harvestAmount);
					}
				}else{
					currentHarvest+=currentResource.currentCapacity;
					currentResource.harvested(currentResource.currentCapacity);
					currentResource = none;
					if(skillsQueue.Length == 0){
						addSkillQueue(3);
						addSkillQueue(2);
					}
					isExecuting = false;
					
				}
			}
		}else{
			if(currentResource.currentCapacity <= 0){
				currentResource = none;	
			}
			if(skillsQueue.Length == 0){
				addSkillQueue(3);
				addSkillQueue(2);
			}
			isExecuting = false;
		}
	}
}

function storeResources(){
	nearestStorage = getClosestStorage();
	addDestination(nearestStorage.Location, nearestStorage.radius+radius);
	addSkillQueue(1);
	addSkillQueue(3);
	addSkillQueue(2);
	isExecuting = false;
}

function giveResources(){
	local Vector direction;
	direction.X = (nearestStorage.Location.X - Location.X);
	direction.Y = (nearestStorage.Location.Y - Location.Y);
	direction.Z = 0;

	nearestStorage = getClosestStorage();
		
	if(VSize(direction) - (radius+nearestStorage.radius) <= 0){
		
		if(MiningAIOwner == none){
			MiningPlayerOwner.getResources(currentResource.info.resourceIndex, currentHarvest);
		}else{
			MiningAIOwner.getResources(currentResource.info.resourceIndex, currentHarvest);
		}
	
		currentHarvest = 0;
		currentHarvestTime = 0.0f;
	}else{
		addDestination(nearestStorage.Location, nearestStorage.radius+radius, 0);
		skillsQueue.InsertItem(0, 1);
		skillsQueue.InsertItem(1, 3);
	}

	isExecuting = false;
}

defaultproperties
{
	unitName = "Harvester"
	maxHealth = 75
	maxCapacity = 25
	harvestRate = 1.5f
	harvestAmount = 10
	moveSpeed = 175
	radius = 70
	canWalk = true
	spotNBR = 1
	
	preSkills[2] = prepareHarvest
	preSkills[3] = prepareClosestStorage;
	preSkills[4] = prepareBase
	preSkills[5] = prepareSupplyDepot
	preSkills[6] = prepareBarracks
	preSkills[7] = prepareConstructor
	skills[2] = harvest
	skills[3] = giveResources
	skills[4] = buildBase
	skills[5] = buildDepot
	skills[6] = buildBarracks
	skills[7] = buildConstructor
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
	 	ModShadowFadeoutTime=0.25
	 	MinTimeBetweenFullUpdates=0.2
	 	AmbientGlow=(R=.01,G=.01,B=.01,A=1)
	 	AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
	 	bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=TRUE
		bCastDynamicShadow=TRUE
		bOwnerNoSee=FALSE
		LightEnvironment=MyLightEnvironment;
		CollideActors=TRUE
		BlockActors=TRUE
        BlockRigidBody=TRUE
        BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateSkelWhenNotRendered=FALSE
		PhysicsAsset=PhysicsAsset'MineralMiningGameContent.PhysicsAssets.SK_VH_Hoverboard_Physics'
		SkeletalMesh=SkeletalMesh'VH_Hoverboard.Mesh.SK_VH_Hoverboard'
	End Object
	
	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0
		Template=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam_Red'
	End Object
	
	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent1
		Template=ParticleSystem'VH_Hoverboard.Effects.P_VH_Hoverboard_Jet_Red01'
		bAutoActivate = true;
	End Object

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent2
		Template=ParticleSystem'Envy_Effects.Smoke.P_HoverBoard_Ground_Dust'
		bAutoActivate = true;
	End Object

	Components.Add(InitialSkeletalMesh)
	unitMesh=InitialSkeletalMesh
	CollisionComponent=InitialSkeletalMesh
	harvestParticle = ParticleSystemComponent0
	thrusterParticle = ParticleSystemComponent1
	groundDustParticle = ParticleSystemComponent2
}