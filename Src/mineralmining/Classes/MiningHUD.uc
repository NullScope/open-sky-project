class MiningHUD extends HUD;

var MiningHUDNew 					scaleformHUD;

var Box								unitBox;

var LocalPlayer 					mouseController;
var MiningPlayer					MiningPlayerOwner;
var MiningGameInfo					MiningGame;

var bool 							bWindowFocused;
var bool							showSelectionBox;
var bool							squareSelectNext;
var bool							showCollisionBoxes;
var bool							showRadius;
var bool 							bDebugInfo;

var int								edgeScrollDistanceX;
var int								edgeScrollDistanceY;
var int								scrollSpeed;

var int								unitHealthBar;
var int 							buildBar;
var int 							buildSpotBar;

var Vector							unitHealthBarLocation;
var Vector							startTrace;
var Vector							rayDir;
var Vector							minTest;
var Vector							maxTest;

var Vector2D						mousePos;
var Vector2D						selectionStart;
var Vector2D 						lastSelectionUpdate;

var const Texture2D					cursorTexture;
var const Texture2D 				depotTexture;
var const Texture2D 				mineralTexture;

var const Color						cursorColor;
var const Color						selectionColor;
var const Color						insideSelection;

var const Color						unitHealthBarColor;
var const Color						unitHealthBarOuterColor;
var const Color						unitHealthBarInnerColor;
var const Color						buildingBarInnerColor;
var const Color 					buildSpotBarColor;

var const Color						enemyUnitHealthBarColor;

var const Color						selectedUnitHealthBarOuterColor;


simulated function PostBeginPlay(){
	local GFxMoviePlayer tempHUD;
	super.PostBeginPlay();
	
	MiningPlayerOwner = MiningPlayer(PlayerOwner);
	MiningGame = MiningGameInfo(WorldInfo.Game);
	mouseController = LocalPlayer(PlayerOwner.Player);
	
	MiningPlayerOwner.MiningHUD = self;
	tempHUD = new class'MiningHUDNew';
	tempHUD.Start();
	scaleformHUD = MiningHUDNew(tempHUD);
	scaleformHUD.MiningPlayerOwner = MiningPlayerOwner;
	scaleformHUD.MiningGame = MiningGame;
}

function moveMouseX(float Delta){
	//mousePos.X = FMin(FMax(0, mousePos.X+Delta), SizeX);
}

function moveMouseY(float Delta){
	//mousePos.Y = FMin(FMax(0, mousePos.Y+Delta), SizeY);
}

function updateMousePos(){
	mousePos = mouseController.ViewportClient.GetMousePosition();
}

function getUnderMouse(out Vector MouseHitWorldLocation, out Vector MouseHitWorldNormal, out MiningActor TraceActor){
	TraceActor = MiningActor(Trace(MouseHitWorldLocation,MouseHitWorldNormal, startTrace+rayDir*500000000, startTrace,true));
}

exec function enableCollisionHUDBoxes(){
	if(showCollisionBoxes){
		showCollisionBoxes = false;	
	}else{
		showCollisionBoxes = true;	
	}
}
exec function enableUnitRadius(){
	if(showRadius){
		showRadius = false;
	}else{
		showRadius = true;	
	}
}

exec function enableDebugInfo()
{
	if(bDebugInfo){
		bDebugInfo = false;
	}else{
		bDebugInfo = true;
	}
}

function startSelection(){
	selectionStart = mousePos;
	showSelectionBox = true;
}

function endSelection(){
 	local MiningActor	tempUnit;
 	
 	local int			j;
 	
	showSelectionBox = false;
	
	if(MiningPlayerOwner.mouseDragged == false){
		if(MiningPlayerOwner.mouseActor.team == MiningPlayerOwner.team && MiningPlayerOwner.mouseActor.isA('MiningActor_Comandable')){
			if(!MiningPlayerOwner.isShiftPressed){
				MiningPlayerOwner.clearSelection();
			}
			MiningPlayerOwner.addSelectedUnit(MiningActor_Comandable(MiningPlayerOwner.mouseActor));
		}
	}else{
		for(j = 0; j<MiningPlayerOwner.tempSelection.Length; j++){
			if(MiningPlayerOwner.tempSelection[j].isA('MiningActor_Comandable')){
				tempUnit = MiningPlayerOwner.tempSelection[j];
				if(MiningPlayerOwner.tempSelection.Length > 1 && (tempUnit.isA('MiningBuilding') || tempUnit.team != MiningPlayerOwner.team)){
					MiningPlayerOwner.removeTempUnit(tempUnit);
				}
			}
		}
		
		if(MiningPlayerOwner.tempSelection.Length > 0){
			if(!MiningPlayerOwner.isShiftPressed){
				MiningPlayerOwner.clearSelection();
			}
			MiningPlayerOwner.selectedUnits = castActorToComandable(MiningPlayerOwner.tempSelection);
		}
		MiningPlayerOwner.clearTempSelection();
	}
	selectionStart = vect2d(0, 0);
	lastSelectionUpdate = vect2d(0, 0);

	if(MiningPlayerOwner.selectedUnits.Length > 0){
		if(MiningPlayerOwner.selectedUnits[0].IsA('MiningBuilding') && !MiningPlayerOwner.selectedUnits[0].IsA('MiningDepot')){
			scaleformHUD.changeUnitInfoFrame(2);
		}else{
			scaleformHUD.changeUnitInfoFrame(1);
		}
		scaleformHUD.setHUD_UnitInfo(MiningPlayerOwner.selectedUnits[0].unitName, MiningPlayerOwner.selectedUnits[0].currentHealth$"/"$MiningPlayerOwner.selectedUnits[0].maxHealth);
	}

	scaleformHUD.updateSkillButtons();
}

function Array<MiningActor_Comandable> castActorToComandable(Array<MiningActor> toCast){
	local Array<MiningActor_Comandable> casted;
	local int j;
	
	for(j = 0; j<toCast.Length; j++){
		casted[j] = MiningActor_Comandable(toCast[j]);
	}
	
	return casted;
}

function squareSelect(){
	local Vector					projectedLoc;
	local MiningActor				tempUnit;
	local int						j;
	
	if(MiningPlayerOwner.mouseDragged && showSelectionBox){
		for(j = 0; j < MiningGame.units.Length; j++){
			tempUnit = MiningGame.units[j];
			projectedLoc = Canvas.Project(tempUnit.Location);
			if(isBetween(projectedLoc, selectionStart, mousePos) && tempUnit.team == MiningPlayerOwner.team){
				MiningPlayerOwner.addTempUnit(tempUnit);
			}else{
				MiningPlayerOwner.removeTempUnit(tempUnit);
					
			}
		}
	}
}

function drawSelectionBox() {
	if (showSelectionBox) {
		Canvas.DrawColor = selectionColor;
		Canvas.SetPos(Min(selectionStart.X, lastSelectionUpdate.X), Min(selectionStart.Y, lastSelectionUpdate.Y));
		Canvas.DrawBox(abs (lastSelectionUpdate.X - selectionStart.X), abs(lastSelectionUpdate.Y - selectionStart.Y));
		
		Canvas.DrawColor = insideSelection;
		Canvas.DrawRect(abs (lastSelectionUpdate.X - selectionStart.X), abs(lastSelectionUpdate.Y - selectionStart.Y));
		
	}
}

function bool isBetween(Vector checkVector, Vector2D vectorA, Vector2D vectorB) {
	if (checkVector.X < fMax(vectorA.X, vectorB.X) && checkVector.X > fMin(vectorA.X, vectorB.X) &&
		checkVector.Y < fMax(vectorA.Y, vectorB.Y) && checkVector.Y > fMin(vectorA.Y, vectorB.Y) ){
			return true;
	} else return false;
}

function Box CalculateScreenBoundingBox(HUD HUD, MiningActor Actor)
{
  local Box ComponentsBoundingBox, OutBox;
  local Vector BoundingBoxCoordinates[8];
  local int k;
  
  ComponentsBoundingBox.Min = Actor.unitMesh.Bounds.Origin - Actor.unitMesh.Bounds.BoxExtent;
  ComponentsBoundingBox.Max = Actor.unitMesh.Bounds.Origin + Actor.unitMesh.Bounds.BoxExtent;

  // Z1
  // X1, Y1
  BoundingBoxCoordinates[0].X = ComponentsBoundingBox.Min.X;
  BoundingBoxCoordinates[0].Y = ComponentsBoundingBox.Min.Y;
  BoundingBoxCoordinates[0].Z = ComponentsBoundingBox.Min.Z;
  BoundingBoxCoordinates[0] = HUD.Canvas.Project(BoundingBoxCoordinates[0]);
  // X2, Y1
  BoundingBoxCoordinates[1].X = ComponentsBoundingBox.Max.X;
  BoundingBoxCoordinates[1].Y = ComponentsBoundingBox.Min.Y;
  BoundingBoxCoordinates[1].Z = ComponentsBoundingBox.Min.Z;
  BoundingBoxCoordinates[1] = HUD.Canvas.Project(BoundingBoxCoordinates[1]);
  // X1, Y2
  BoundingBoxCoordinates[2].X = ComponentsBoundingBox.Min.X;
  BoundingBoxCoordinates[2].Y = ComponentsBoundingBox.Max.Y;
  BoundingBoxCoordinates[2].Z = ComponentsBoundingBox.Min.Z;
  BoundingBoxCoordinates[2] = HUD.Canvas.Project(BoundingBoxCoordinates[2]);
  // X2, Y2
  BoundingBoxCoordinates[3].X = ComponentsBoundingBox.Max.X;
  BoundingBoxCoordinates[3].Y = ComponentsBoundingBox.Max.Y;
  BoundingBoxCoordinates[3].Z = ComponentsBoundingBox.Min.Z;
  BoundingBoxCoordinates[3] = HUD.Canvas.Project(BoundingBoxCoordinates[3]);

  // Z2
  // X1, Y1
  BoundingBoxCoordinates[4].X = ComponentsBoundingBox.Min.X;
  BoundingBoxCoordinates[4].Y = ComponentsBoundingBox.Min.Y;
  BoundingBoxCoordinates[4].Z = ComponentsBoundingBox.Max.Z;
  BoundingBoxCoordinates[4] = HUD.Canvas.Project(BoundingBoxCoordinates[4]);
  // X2, Y1
  BoundingBoxCoordinates[5].X = ComponentsBoundingBox.Max.X;
  BoundingBoxCoordinates[5].Y = ComponentsBoundingBox.Min.Y;
  BoundingBoxCoordinates[5].Z = ComponentsBoundingBox.Max.Z;
  BoundingBoxCoordinates[5] = HUD.Canvas.Project(BoundingBoxCoordinates[5]);
  // X1, Y2
  BoundingBoxCoordinates[6].X = ComponentsBoundingBox.Min.X;
  BoundingBoxCoordinates[6].Y = ComponentsBoundingBox.Max.Y;
  BoundingBoxCoordinates[6].Z = ComponentsBoundingBox.Max.Z;
  BoundingBoxCoordinates[6] = HUD.Canvas.Project(BoundingBoxCoordinates[6]);
  // X2, Y2
  BoundingBoxCoordinates[7].X = ComponentsBoundingBox.Max.X;
  BoundingBoxCoordinates[7].Y = ComponentsBoundingBox.Max.Y;
  BoundingBoxCoordinates[7].Z = ComponentsBoundingBox.Max.Z;
  BoundingBoxCoordinates[7] = HUD.Canvas.Project(BoundingBoxCoordinates[7]);

  // Find the left, top, right and bottom coordinates
  OutBox.Min.X = 9999999;
  OutBox.Min.Y = 9999999;
  OutBox.Max.X = -9999999;
  OutBox.Max.Y = -9999999;

  // Iterate though the bounding box coordinates
  for (k = 0; k < ArrayCount(BoundingBoxCoordinates); ++k)
  {
    // Detect the smallest X coordinate
    if (OutBox.Min.X > BoundingBoxCoordinates[k].X)
    {
      OutBox.Min.X = BoundingBoxCoordinates[k].X;
    }

    // Detect the smallest Y coordinate
    if (OutBox.Min.Y > BoundingBoxCoordinates[k].Y)
    {
      OutBox.Min.Y = BoundingBoxCoordinates[k].Y;
    }

    // Detect the largest X coordinate
    if (OutBox.Max.X < BoundingBoxCoordinates[k].X)
    {
      OutBox.Max.X = BoundingBoxCoordinates[k].X;
    }

    // Detect the largest Y coordinate
    if (OutBox.Max.Y < BoundingBoxCoordinates[k].Y)
    {
      OutBox.Max.Y = BoundingBoxCoordinates[k].Y;
    }
  }
  
  return OutBox;
}

function RenderThreeDeeCircle(MiningActor Actor, HUD myHUD)
{
  local Rotator Angle;
  local Vector Radius, Offsets[16];
  local float Width, Height;
  local int j;

  if (Actor == None)
  {
    return;
  }

  Width = Actor.radius;
  Height = Actor.Location.Z;

  Radius.X = (Width > Height) ? Width : Height;
  j = 0;

  for (Angle.Yaw = 0; Angle.Yaw < 65536; Angle.Yaw += 4096)
  {
    // Calculate the offset
    Offsets[j] = Actor.Location + (Radius >> Angle) + Vect(0.f, 0.f, 16.f);
    j++;
  }
      
  // Draw all of the lines
  for (j = 0; j < ArrayCount(Offsets); ++j)
  {
    if (j == ArrayCount(Offsets) - 1)
    {
      Draw3DLine(Offsets[j], Offsets[0], myHUD.default.WhiteColor);
    }
    else
    {
      Draw3DLine(Offsets[j], Offsets[j + 1], myHUD.default.WhiteColor);
    }
  }
}

exec function openScaleform(){
	scaleformHUD.Start();
}

exec function closeScaleform(){
	scaleformHUD.Close();
}

event PostRender(){
	local int		i, k;
  	super.PostRender();

	if(scaleformHUD != none){
		scaleformHUD.Tick();
	}

	updateMousePos();

	if(!(mousePos.X <= SizeX && mousePos.X >= 0) || !(mousePos.Y <= SizeY && mousePos.Y >= 0)){
		bWindowFocused = false;
	}else{
		bWindowFocused = true;
	}
	if(!showSelectionBox){
		if(bWindowFocused){
			if(mousePos.X < edgeScrollDistanceX){
				MiningPlayerOwner.moveDirection.Y = -scrollSpeed;
			}else{
				if (mousePos.X > SizeX-edgeScrollDistanceX){
					MiningPlayerOwner.moveDirection.Y = scrollSpeed;
				}else{
					MiningPlayerOwner.moveDirection.Y = 0;
				}
			}
	
			if(mousePos.Y < edgeScrollDistanceY){
				MiningPlayerOwner.moveDirection.X = scrollSpeed;
			}else{
				if(mousePos.Y > SizeY-edgeScrollDistanceY){
					MiningPlayerOwner.moveDirection.X = -scrollSpeed;
				}else{
					MiningPlayerOwner.moveDirection.X = 0;
				}
			}
		}
	}
	
	Canvas.DeProject(mousePos, startTrace, rayDir);
	
	for(i = 0; i < MiningGame.units.Length; i++){
		if(showRadius){
			RenderThreeDeeCircle(MiningGame.units[i], self);
		}
		
		if(showCollisionBoxes){	
			Canvas.SetPos(unitBox.Min.X, unitBox.Min.Y);
			
			Canvas.DrawBox(unitBox.Max.X - unitBox.Min.X, unitBox.Max.Y - unitBox.Min.Y);
		}
		
		unitBox = CalculateScreenBoundingBox(self, MiningGame.units[i]);
		unitHealthBarLocation.X = unitBox.Min.X + ((unitBox.Max.X - unitBox.Min.X)/2) - MiningGame.units[i].radius/2;
		unitHealthBarLocation.Y = unitBox.Min.Y;
		unitHealthBar = (MiningGame.units[i].currentHealth * MiningGame.units[i].radius)/MiningGame.units[i].maxHealth;
		
		Canvas.SetPos(unitHealthBarLocation.X, unitHealthBarLocation.Y-7);
		Canvas.DrawColor = unitHealthBarInnerColor;
		Canvas.DrawRect(MiningGame.units[i].radius, 7);
		
		Canvas.SetPos(unitHealthBarLocation.X, unitHealthBarLocation.Y-7);
		
		if(MiningGame.units[i].team == MiningPlayerOwner.team){
			Canvas.DrawColor =  unitHealthBarColor;
		}else{
			Canvas.DrawColor =  enemyUnitHealthBarColor;
		}
		
		Canvas.DrawRect(unitHealthBar, 7);
		
		Canvas.SetPos(unitHealthBarLocation.X-1, unitHealthBarLocation.Y-8);
		Canvas.DrawColor = unitHealthBarOuterColor;
		Canvas.DrawBox(MiningGame.units[i].radius+2, 9);

		if(MiningGame.units[i].team == MiningPlayerOwner.team && MiningGame.units[i].IsA('MiningBuilding')){
			buildSpotBar = MiningGame.units[i].radius/5;
			if(MiningBuilding(MiningGame.units[i]).readyToSpawnTime != 0){
				buildBar = (MiningBuilding(MiningGame.units[i]).currentBuildTime * MiningGame.units[i].radius)/MiningBuilding(MiningGame.units[i]).readyToSpawnTime;
			}else{
				buildBar = 0;
			}
			
			for (k=0; k<5; k++)
			{
				Canvas.SetPos(unitHealthBarLocation.X+(buildSpotBar*k),  unitHealthBarLocation.Y-14);
				Canvas.DrawColor = unitHealthBarInnerColor;
				Canvas.DrawRect(buildSpotBar, 7);
			}

			for (k = 0; k<MiningBuilding(MiningGame.units[i]).buildQueue.length; k++)
			{
				Canvas.SetPos(unitHealthBarLocation.X+(buildSpotBar*(4-k)),  unitHealthBarLocation.Y-14);
				Canvas.DrawColor = buildSpotBarColor;
				Canvas.DrawRect(buildSpotBar, 7);
			}

			for (k=0; k<5; k++){
				Canvas.SetPos(unitHealthBarLocation.X+(buildSpotBar*k)-1, unitHealthBarLocation.Y-15);
				Canvas.DrawColor = unitHealthBarOuterColor;
				Canvas.DrawBox(buildSpotBar+2, 9);
				
			}

			Canvas.SetPos(unitHealthBarLocation.X,  unitHealthBarLocation.Y-21);
			Canvas.DrawColor = unitHealthBarInnerColor;
			Canvas.DrawRect(MiningGame.units[i].radius, 7);

			Canvas.SetPos(unitHealthBarLocation.X, unitHealthBarLocation.Y-21);
			Canvas.DrawColor = buildingBarInnerColor;
			Canvas.DrawRect(buildBar, 7);

			Canvas.SetPos(unitHealthBarLocation.X-1, unitHealthBarLocation.Y-22);
			Canvas.DrawColor = unitHealthBarOuterColor;
			Canvas.DrawBox(MiningGame.units[i].radius+2, 9);
		}
	}
	
	/*for(i = 0; i < MiningPlayerOwner.selectedUnits.Length; i++){
		
		unitBox = CalculateScreenBoundingBox(self, MiningPlayerOwner.selectedUnits[i]);
		
		unitHealthBarLocation.X = unitBox.Min.X + ((unitBox.Max.X - unitBox.Min.X)/2) - 25;
		unitHealthBarLocation.Y = unitBox.Min.Y;

		unitHealthBar = (MiningPlayerOwner.selectedUnits[i].currentHealth * 50)/MiningPlayerOwner.selectedUnits[i].maxHealth;
		
		Canvas.SetPos(unitHealthBarLocation.X, unitHealthBarLocation.Y);
		Canvas.DrawColor = unitHealthBarInnerColor;
		Canvas.DrawRect(50, 7);
		
		Canvas.SetPos(unitHealthBarLocation.X, unitHealthBarLocation.Y);
		
		if(MiningPlayerOwner.selectedUnits[i].team == MiningPlayerOwner.team){
			Canvas.DrawColor =  unitHealthBarColor;
		}else{
			Canvas.DrawColor =  enemyUnitHealthBarColor;
		}
		
		Canvas.DrawRect(unitHealthBar, 7);
		
		Canvas.SetPos(unitHealthBarLocation.X-1, unitHealthBarLocation.Y-1);
		Canvas.DrawColor = selectedUnitHealthBarOuterColor;
		Canvas.DrawBox(52, 9);
	}
	
	for(i=0; i < MiningPlayerOwner.tempSelection.Length; i++){
		unitBox = CalculateScreenBoundingBox(self, MiningPlayerOwner.tempSelection[i]);
			
		unitHealthBarLocation.X = unitBox.Min.X + ((unitBox.Max.X - unitBox.Min.X)/2) - 25;
		unitHealthBarLocation.Y = unitBox.Min.Y;
		
		unitHealthBar = (MiningPlayerOwner.tempSelection[i].currentHealth * 50)/MiningPlayerOwner.tempSelection[i].maxHealth;
		
		Canvas.SetPos(unitHealthBarLocation.X, unitHealthBarLocation.Y);
		Canvas.DrawColor = unitHealthBarInnerColor;
		Canvas.DrawRect(50, 7);
		
		Canvas.SetPos(unitHealthBarLocation.X, unitHealthBarLocation.Y);
		
		if(MiningPlayerOwner.tempSelection[i].team == MiningPlayerOwner.team){
			Canvas.DrawColor =  unitHealthBarColor;
		}else{
			Canvas.DrawColor =  enemyUnitHealthBarColor;
		}
		
		Canvas.DrawRect(unitHealthBar, 7);
		
		Canvas.SetPos(unitHealthBarLocation.X-1, unitHealthBarLocation.Y-1);
		Canvas.DrawColor = selectedUnitHealthBarOuterColor;
		Canvas.DrawBox(52, 9);
		
	}*/
	
	Canvas.DrawColor = cursorColor;
	if(MiningPlayerOwner.bMouseActions && bWindowFocused){
		lastSelectionUpdate = mousePos;
	}
	drawDebugInfo();
	drawSelectionBox();

    //Canvas.SetPos(mousePos.X, mousePos.Y); 
    Canvas.DrawColor = cursorColor;
	//Canvas.DrawTile(cursorTexture, cursorTexture.SizeX, cursorTexture.SizeY, 0.f, 0.f, cursorTexture.SizeX, cursorTexture.SizeY,, true);
	
	squareSelect();

	Canvas.SetPos(SizeX-32, 10);
	Canvas.DrawTile(depotTexture, 24, 24, 0.f, 0.f, depotTexture.SizeX, depotTexture.SizeY,, true);
	Canvas.DrawColor = unitHealthBarOuterColor;
	Canvas.SetPos(SizeX-75, 15);
	Canvas.DrawText(MiningPlayerOwner.currentUnitCapacity$"/"$MiningPlayerOwner.maxUnitCapacity);

	Canvas.DrawColor = cursorColor;

	Canvas.SetPos(SizeX-32, 41);
	Canvas.DrawTile(mineralTexture, 24, 24, 0.f, 0.f, mineralTexture.SizeX, mineralTexture.SizeY,, true);
	Canvas.DrawColor = unitHealthBarOuterColor;
	Canvas.SetPos(SizeX-75, 46);
	Canvas.DrawText(MiningPlayerOwner.resources[0]);
	
}

function drawDebugInfo()
{
	if (bDebugInfo)
	{
		Canvas.SetPos(0,0);
		Canvas.DrawColor = unitHealthBarColor;
		Canvas.DrawBox(sizeX, 80);
		Canvas.SetPos(1, 1);
		Canvas.DrawColor = unitHealthBarOuterColor;
		Canvas.DrawRect(SizeX-2, 78);

		Canvas.DrawColor = selectionColor;
		Canvas.SetPos(5,0);
		Canvas.DrawText("X: "$MiningPlayerOwner.mouseWorldLocation.X$" Y: "$MiningPlayerOwner.mouseWorldLocation.Y$" Z: "$MiningPlayerOwner.mouseWorldLocation.Z);
		Canvas.SetPos(5,12);
		Canvas.DrawText("Screen Mouse X: "$mousePos.X$" Y: "$mousePos.Y$" | DRAGGED: "$MiningPlayerOwner.mouseDragged);
		Canvas.SetPos(5,24);
		Canvas.DrawText("LAST ADD X: "$MiningGame.units[MiningGame.units.Length-1].Location.X$" Y: "$MiningGame.units[MiningGame.units.Length-1].Location.Y$" Z: "$MiningGame.units[MiningGame.units.Length-1].Location.Z);
		Canvas.SetPos(5,36);
		Canvas.DrawText("TOTAL: "$MiningGame.units.Length$" | SELECTED: "$MiningPlayerOwner.selectedUnits.Length$" | TEMP: "$MiningPlayerOwner.tempSelection.Length);
		Canvas.SetPos(5, 48);
		Canvas.DrawText("SizeX: "$SizeX$" | SizeY:"$SizeY);
		
		//if(MiningPlayerOwner.selectedUnits.Length > 0){
			Canvas.SetPos(5,60);
			Canvas.DrawText("Mouse Actor: "$MiningPlayerOwner.mouseActor$" | MATERIAL: "$MiningGame.units[MiningGame.units.Length-1].unitMesh.GetMaterial(0)$" | castTime: "$MiningGame.units[MiningGame.units.Length-1].skillsInfo[2].castTime$" | selected Queue:"$MiningGame.units[MiningGame.units.Length-1].skillsQueue.Length$" | STATE: "$MiningGame.units[MiningGame.units.Length-1].GetStateName());
		//}
	}
}
defaultproperties
{
	bDebugInfo = false
	scrollSpeed=5000
	edgeScrollDistanceX=5
	edgeScrollDistanceY=5
	cursorColor=(R=255,G=255,B=255,A=255)
	cursorTexture= Texture2D'EngineResources.Cursors.Arrow'
	depotTexture= Texture2D'MineralMiningGameContent.Icons.Depot_Icon'
	mineralTexture= Texture2D'MineralMiningGameContent.Icons.Mineral_Icon'
	selectionColor=(R=0, G=255, B=0, A=255)
	insideSelection=(R=0, G=200, B=0, A=100)
	unitHealthBarColor=(R=50, G=200, B=0, A=255)
	unitHealthBarOuterColor=(R=0,G=0,B=0,A=255)
	unitHealthBarInnerColor=(R=85,G=85,B=85,A=255)
	buildingBarInnerColor=(R=19,G=191,B=169,A=255)
	buildSpotBarColor=(R=191,G=193,B=6,A=255)
	selectedUnitHealthBarOuterColor=(R=200,G=150,B=0,A=255)
	enemyUnitHealthBarColor=(R=230,G=0,B=0,A=255)
}