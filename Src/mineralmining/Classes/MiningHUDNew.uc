class MiningHUDNew extends GFxMoviePlayer;

var MiningPlayer                    MiningPlayerOwner;
var MiningGameInfo                  MiningGame;
var TextureRenderTarget2D           MyRenderTexture;

var GFxCLIKWidget             continueButton;

var GFxCLIKWidget           skill1Button;
var GFxCLIKWidget           skill2Button;
var GFxCLIKWidget           skill3Button;
var GFxCLIKWidget           skill4Button;
var GFxCLIKWidget           skill5Button;
var GFxCLIKWidget           skill6Button;
var GFxCLIKWidget           skill7Button;
var GFxCLIKWidget           skill8Button;
var GFxCLIKWidget           skill9Button;
var GFxClikWidget           skill10Button;
var GFxCLIKWidget           skill11Button;
var GFxCLIKWidget           skill12Button;
var GFxCLIKWidget           skill13Button;
var GFxCLIKWidget           skill14Button;
var GFxCLIKWidget           skill15Button;

var GFxClikWidget           unitBuild1;
var GFxClikWidget           unitBuild2;
var GFxClikWidget           unitBuild3;
var GFxClikWidget           unitBuild4;
var GFxClikWidget           unitBuild5;

var GFxObject               skill1Icon;
var GFxObject               skill2Icon;
var GFxObject               skill3Icon;
var GFxObject               skill4Icon;
var GFxObject               skill5Icon;
var GFxObject               skill6Icon;
var GFxObject               skill7Icon;
var GFxObject               skill8Icon;
var GFxObject               skill9Icon;
var GFxObject               skill10Icon;
var GFxObject               skill11Icon;
var GFxObject               skill12Icon;
var GFxObject               skill13Icon;
var GFxObject               skill14Icon;
var GFxObject               skill15Icon;

var GFxObject               unitProgress;

var GFxObject               unitIcon1;
var GFxObject               unitIcon2;
var GFxObject               unitIcon3;
var GFxObject               unitIcon4;
var GFxObject               unitIcon5;


var array<GFxCLIKWidget>    skillButtons;
var array<int>              skillsInfoIndex;

var GFxObject               unitName;
var GFxObject               unitHealth;
var GFxObject               skillName;
var GFxObject               skillDesc;
var GFxObject               unitInfoMC;

var GFxObject               victoryMC;
var GFxObject               defeatMC;

var String                  strSkillName;
var String                  strSkillDesc;
//dllimport final function UpdateCursor(string text);

// Called when the UI is opened to start the movie
function bool Start(optional bool StartPaused = false)
{
	// Start playing the movie
    Super.Start();
    
    SetViewScaleMode(SM_ExactFit);
    GetGameViewportClient().bDisplayHardwareMouseCursor = true;
	// Initialize all objects in the movie
    Advance(0);

    return true;
}

function Tick()
{
    if(MiningPlayerOwner.MiningHUD.bWindowFocused){
        //UpdateCursor("");
    }

    updateLoopInfo();
}

function gotoMenu(EventData data)
{
    ConsoleCommand("open UDKFrontEndMap");
}

function showDefeat()
{
    ConsoleCommand("pause");
    defeatMC.GotoAndPlayI(2);
}

function showVictory()
{
    ConsoleCommand("pause");
    victoryMC.GotoAndPlayI(2);
}

function int getMousePosX()
{
    return MiningPlayerOwner.MiningHUD.mousePos.X;
}

function int getMousePosY()
{
    return MiningPlayerOwner.MiningHUD.mousePos.Y;
}

function cancelunit(int index) 
{
    local MiningBuilding        tempBuilding;

    if(MiningPlayerOwner.selectedUnits[0].IsA('MiningBuilding') && MiningPlayerOwner.selectedUnits[0].team == MiningPlayerOwner.team){
       tempBuilding = MiningBuilding(MiningPlayerOwner.selectedUnits[0]);
       tempBuilding.cancelUnitQueue(index);
    }
}

function enableButton(GFxClikWidget skillButton, GFxObject skillIcon, int index, int tempIndex)
{
    skillButton.SetBool("enabled", TRUE);

    skillicon.GotoAndStopI(MiningPlayerOwner.selectedUnits[0].skillsInfo[tempIndex].skillIcon);
    skillsInfoIndex[index]=tempIndex;
}

function updateLoopInfo()
{
    if(MiningPlayerOwner.selectedUnits.Length > 0){
        unitHealth.SetText(MiningPlayerOwner.selectedUnits[0].currentHealth$"/"$MiningPlayerOwner.selectedUnits[0].maxHealth);
    }

    updateBuild();

    if(skillName != none){
        skillName.setText(strSkillName);
        skillDesc.setText(strSkillDesc);
    }
}

function updateBuild()
{
    local MiningBuilding        tempBuilding;
    local int                   queueSize;

    if(unitBuild1 != none){
        unitBuild1.SetBool("enabled", FALSE);
        unitBuild2.SetBool("enabled", FALSE);
        unitBuild3.SetBool("enabled", FALSE);
        unitBuild4.SetBool("enabled", FALSE);
        unitBuild5.SetBool("enabled", FALSE);

        unitIcon1.GotoAndStopI(0);
        unitIcon2.GotoAndStopI(0);
        unitIcon3.GotoAndStopI(0);
        unitIcon4.GotoAndStopI(0);
        unitIcon5.GotoAndStopI(0);
    }

    if(MiningPlayerOwner.selectedUnits.Length > 0){
        if(MiningPlayerOwner.selectedUnits[0].IsA('MiningBuilding')){
            tempBuilding = MiningBuilding(MiningPlayerOwner.selectedUnits[0]);
            queueSize = tempBuilding.buildQueue.length;

            if(queueSize > 0){
                unitProgress.SetFloat("maximum", tempBuilding.readyToSpawnTime);
                unitProgress.SetFloat("value", tempBuilding.currentBuildTime);
                if(queueSize >= 1){
                unitBuild1.SetBool("enabled", TRUE);
                unitIcon1.GotoAndStopI(tempBuilding.skillsInfo[tempBuilding.buildQueue[0]].skillIcon);
                }

                if(queueSize >= 2){
                    unitBuild2.SetBool("enabled", TRUE);
                    unitIcon2.GotoAndStopI(tempBuilding.skillsInfo[tempBuilding.buildQueue[1]].skillIcon);
                }

                if(queueSize >= 3){
                    unitBuild3.SetBool("enabled", TRUE);
                    unitIcon3.GotoAndStopI(tempBuilding.skillsInfo[tempBuilding.buildQueue[2]].skillIcon);
                }

                if(queueSize >= 4){
                    unitBuild4.SetBool("enabled", TRUE);
                    unitIcon4.GotoAndStopI(tempBuilding.skillsInfo[tempBuilding.buildQueue[3]].skillIcon);
                }

                if(queueSize == 5){
                    unitBuild5.SetBool("enabled", TRUE);
                    unitIcon5.GotoAndStopI(tempBuilding.skillsInfo[tempBuilding.buildQueue[4]].skillIcon);
                }
            }else{
                unitProgress.SetFloat("maximum", 0);
                unitProgress.SetFloat("value", 0);
            }
        }
    }
}

function updateInfo(string newName, string newDesc){
    strSkillName = newName;
    strSkillDesc = newDesc;
}

function changeUnitInfoFrame(int frame){
    unitInfoMC.GotoAndStopI(frame);
}

function setHUD_UnitInfo(String newName, String newHealth){
    unitName.SetText(newName);
    unitHealth.SetText(newHealth);
}

function executeSkill(int skillIndex)
{
    local bool isShiftPressed;

    isShiftPressed = !MiningPlayerOwner.isShiftPressed;

    MiningPlayerOwner.executeSkill(MiningPlayerOwner.selectedUnits[0], skillIndex,isShiftPressed, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillIndex].requiresTarget);
}

function updateSkillButtons()
{
    local skillInfo tempInfo;
    local int       tempIndex;

    skill1Button.SetBool("enabled", FALSE);
    skill2Button.SetBool("enabled", FALSE);
    skill3Button.SetBool("enabled", FALSE);
    skill4Button.SetBool("enabled", FALSE);
    skill5Button.SetBool("enabled", FALSE);
    skill6Button.SetBool("enabled", FALSE);
    skill7Button.SetBool("enabled", FALSE);
    skill8Button.SetBool("enabled", FALSE);
    skill9Button.SetBool("enabled", FALSE);
    skill10Button.SetBool("enabled", FALSE);
    skill11Button.SetBool("enabled", FALSE);
    skill12Button.SetBool("enabled", FALSE);
    skill13Button.SetBool("enabled", FALSE);
    skill14Button.SetBool("enabled", FALSE);
    skill15Button.SetBool("enabled", FALSE);

    skill1Icon.GotoAndStopI(0);
    skill2Icon.GotoAndStopI(0);
    skill3Icon.GotoAndStopI(0);
    skill4Icon.GotoAndStopI(0);
    skill5Icon.GotoAndStopI(0);
    skill6Icon.GotoAndStopI(0);
    skill7Icon.GotoAndStopI(0);
    skill8Icon.GotoAndStopI(0);
    skill9Icon.GotoAndStopI(0);
    skill10Icon.GotoAndStopI(0);
    skill11Icon.GotoAndStopI(0);
    skill12Icon.GotoAndStopI(0);
    skill13Icon.GotoAndStopI(0);
    skill14Icon.GotoAndStopI(0);
    skill15Icon.GotoAndStopI(0);

    foreach MiningPlayerOwner.selectedUnits[0].skillsInfo(tempInfo, tempIndex)
    {
        skillsInfoIndex.AddItem(tempIndex);

        switch (tempInfo.skillButtonIndex)
        {
            case 1:
                enableButton(skill1Button, skill1Icon, 1, tempIndex);
                break;
            case 2:
                enableButton(skill2Button, skill2Icon, 2, tempIndex);
                break;
            case 3:
                enableButton(skill3Button, skill3Icon, 3, tempIndex);
                break;
            case 4:
                enableButton(skill4Button, skill4Icon, 4, tempIndex);
                break;
            case 5:
                enableButton(skill5Button, skill5Icon, 5, tempIndex);
                break;
            case 6:
                enableButton(skill6Button, skill6Icon, 6, tempIndex);
                break;
            case 7:
                enableButton(skill7Button, skill7Icon, 7, tempIndex);
                break;
            case 8:
                enableButton(skill8Button, skill8Icon, 8, tempIndex);
                break;
            case 9:
                enableButton(skill9Button, skill9Icon, 9, tempIndex);
                break;
            case 10:
                enableButton(skill10Button, skill10Icon, 10, tempIndex);
                break;
            case 11:
                enableButton(skill11Button, skill11Icon, 11, tempIndex);
                break;
            case 12:
                enableButton(skill12Button, skill12Icon, 12, tempIndex);
                break;
            case 13:
                enableButton(skill13Button, skill13Icon, 13, tempIndex);
                break;
            case 14:
                enableButton(skill14Button, skill14Icon, 14, tempIndex);
                break;
            case 15:
                enableButton(skill15Button, skill15Icon, 15, tempIndex);
                break;
        }
    }
}

// Callback automatically called for each object in the movie with enableInitCallback enabled
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    // Determine which widget is being initialized and handle it accordingly
    switch(Widgetname)
    {
        case 'skillName_mc':
            skillName = Widget;
            break;
        case 'skillDesc_mc':
            skillDesc = Widget;
            break;
        case 'unitName_mc':

            unitName = Widget;
            break;
        case 'unitHealth_mc':
            unitHealth = Widget;
            break;
        case 'unitInfo_mc':
            unitInfoMC = Widget;
            break;
        case 'unitProgress_mc':
            unitProgress = Widget;
            break;
        
        case 'defeat_mc':
            defeatMC = Widget;
            break;
        case 'victory_mc':
            victoryMC = Widget;
            break;

        case'continue_btn':
            continueButton = GFxCLIKWidget(Widget);
            continueButton.AddEventListener('CLIK_click', gotoMenu);
            break;
        case'skill1_mc':
            skill1Button = GFxCLIKWidget(Widget);
            skill1Button.AddEventListener('CLIK_click', executeSkill1);
            skill1Button.AddEventListener('CLIK_rollOver', updateInfo1);
            break;
        case'skill2_mc':
            skill2Button = GFxCLIKWidget(Widget);
            skill2Button.AddEventListener('CLIK_click', executeSkill2);
            skill2Button.AddEventListener('CLIK_rollOver', updateInfo2);
            break;
        case'skill3_mc':
            skill3Button = GFxCLIKWidget(Widget);
            skill3Button.AddEventListener('CLIK_click', executeSkill3);
            skill3Button.AddEventListener('CLIK_rollOver', updateInfo3);
            break;
        case'skill4_mc':
            skill4Button = GFxCLIKWidget(Widget);
            skill4Button.AddEventListener('CLIK_click', executeSkill4);
            skill4Button.AddEventListener('CLIK_rollOver', updateInfo4);
            break;
        case'skill5_mc':
            skill5Button = GFxCLIKWidget(Widget);
            skill5Button.AddEventListener('CLIK_click', executeSkill5);
            skill5Button.AddEventListener('CLIK_rollOver', updateInfo5);
            break;
        case'skill6_mc':
            skill6Button = GFxCLIKWidget(Widget);
            skill6Button.AddEventListener('CLIK_click', executeSkill6);
            skill6Button.AddEventListener('CLIK_rollOver', updateInfo6);
            break;
        case'skill7_mc':
            skill7Button = GFxCLIKWidget(Widget);
            skill7Button.AddEventListener('CLIK_click', executeSkill7);
            skill7Button.AddEventListener('CLIK_rollOver', updateInfo7);
            break;
        case'skill8_mc':
            skill8Button = GFxCLIKWidget(Widget);
            skill8Button.AddEventListener('CLIK_click', executeSkill8);
            skill8Button.AddEventListener('CLIK_rollOver', updateInfo8);
            break;
        case'skill9_mc':
            skill9Button = GFxCLIKWidget(Widget);
            skill9Button.AddEventListener('CLIK_click', executeSkill9);
            skill9Button.AddEventListener('CLIK_rollOver', updateInfo9);
            break;
        case'skill10_mc':
            skill10Button = GFxCLIKWidget(Widget);
            skill10Button.AddEventListener('CLIK_click', executeSkill10);
            skill10Button.AddEventListener('CLIK_rollOver', updateInfo10);
            break;
        case'skill11_mc':
            skill11Button = GFxCLIKWidget(Widget);
            skill11Button.AddEventListener('CLIK_click', executeSkill11);
            skill11Button.AddEventListener('CLIK_rollOver', updateInfo11);
            break;
        case'skill12_mc':
            skill12Button = GFxCLIKWidget(Widget);
            skill12Button.AddEventListener('CLIK_click', executeSkill12);
            skill12Button.AddEventListener('CLIK_rollOver', updateInfo12);
            break;
        case'skill13_mc':
            skill13Button = GFxCLIKWidget(Widget);
            skill13Button.AddEventListener('CLIK_click', executeSkill13);
            skill13Button.AddEventListener('CLIK_rollOver', updateInfo13);
            break;
        case'skill14_mc':
            skill14Button = GFxCLIKWidget(Widget);
            skill14Button.AddEventListener('CLIK_click', executeSkill14);
            skill14Button.AddEventListener('CLIK_rollOver', updateInfo14);
            break;
        case'skill15_mc':
            skill15Button = GFxCLIKWidget(Widget);
            skill15Button.AddEventListener('CLIK_click', executeSkill15);
            skill15Button.AddEventListener('CLIK_rollOver', updateInfo14);
            break;

        case'unitBuild1_mc':
            unitBuild1 = GFxCLIKWidget(Widget);
            unitBuild1.AddEventListener('CLIK_click', cancelunit1);
            break;
        case'unitBuild2_mc':
            unitBuild2 = GFxCLIKWidget(Widget);
            unitBuild2.AddEventListener('CLIK_click', cancelunit2);
            break;
        case'unitBuild3_mc':
            unitBuild3 = GFxCLIKWidget(Widget);
            unitBuild3.AddEventListener('CLIK_click', cancelunit3);
            break;
        case'unitBuild4_mc':
            unitBuild4 = GFxCLIKWidget(Widget);
            unitBuild4.AddEventListener('CLIK_click', cancelunit4);
            break;
        case'unitBuild5_mc':
            unitBuild5 = GFxCLIKWidget(Widget);
            unitBuild5.AddEventListener('CLIK_click', cancelunit5);
            break;

        case'unitIcon1_mc':
            unitIcon1 = Widget;
            break;
        case'unitIcon2_mc':
            unitIcon2 = Widget;
            break;
        case'unitIcon3_mc':
            unitIcon3 = Widget;
            break;
        case'unitIcon4_mc':
            unitIcon4 = Widget;
            break;
        case'unitIcon5_mc':
            unitIcon5 = Widget;
            break;

        case'skillIcon1_mc':
            skill1Icon = Widget;
            break;
        case'skillIcon2_mc':
            skill2Icon = Widget;
            break;
        case'skillIcon3_mc':
            skill3Icon = Widget;
            break;
        case'skillIcon4_mc':
            skill4Icon = Widget;
            break;
        case'skillIcon5_mc':
            skill5Icon = Widget;
            break;
        case'skillIcon6_mc':
            skill6Icon = Widget;
            break;
        case'skillIcon7_mc':
            skill7Icon = Widget;
            break;
        case'skillIcon8_mc':
            skill8Icon = Widget;
            break;
        case'skillIcon9_mc':
            skill9Icon = Widget;
            break;
        case'skillIcon10_mc':
            skill10Icon = Widget;
            break;
        case'skillIcon11_mc':
            skill11Icon = Widget;
            break;
        case'skillIcon12_mc':
            skill12Icon = Widget;
            break;
        case'skillIcon13_mc':
            skill13Icon = Widget;
            break;
        case'skillIcon14_mc':
            skill14Icon = Widget;
            break;
        case'skillIcon15_mc':
            skill15Icon = Widget;
            break;

        default:
        	// Pass on if not a widget we are looking for
            return Super.WidgetInitialized(Widgetname, WidgetPath, Widget);
    }
    
    return false;
}

function enableGameActions()
{
    MiningPlayerOwner.bMouseActions = true;
}

function disableGameActions()
{
    MiningPlayerOwner.bMouseActions = false;
}

function SetRenderTexture()
{
    //SetExternalTexture("portrait",MyRenderTexture);
}

function UpdatePortrait(TextureRenderTarget2D newTexture)
{
    SetExternalTexture("portrait",newTexture);
}

function executeSkill1(EventData data)
{
    executeSkill(skillsInfoIndex[1]);
}

function executeSkill2(EventData data)
{
    executeSkill(skillsInfoIndex[2]);
}

function executeSkill3(EventData data)
{
    executeSkill(skillsInfoIndex[3]);   
}

function executeSkill4(EventData data)
{
    executeSkill(skillsInfoIndex[4]);   
}

function executeSkill5(EventData data)
{
    executeSkill(skillsInfoIndex[5]);   
}

function executeSkill6(EventData data)
{
    executeSkill(skillsInfoIndex[6]);   
}

function executeSkill7(EventData data)
{
    executeSkill(skillsInfoIndex[7]);   
}

function executeSkill8(EventData data)
{
    executeSkill(skillsInfoIndex[8]);   
}

function executeSkill9(EventData data)
{
    executeSkill(skillsInfoIndex[9]);   
}

function executeSkill10(EventData data)
{
    executeSkill(skillsInfoIndex[10]);   
}

function executeSkill11(EventData data)
{
    executeSkill(skillsInfoIndex[11]);   
}

function executeSkill12(EventData data)
{
    executeSkill(skillsInfoIndex[12]);   
}

function executeSkill13(EventData data)
{
    executeSkill(skillsInfoIndex[13]);   
}

function executeSkill14(EventData data)
{
    executeSkill(skillsInfoIndex[14]);   
}

function executeSkill15(EventData data)
{   
    executeSkill(skillsInfoIndex[15]);
}

function updateInfo1(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[1]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[1]].skillDescription);
}

function updateInfo2(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[2]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[2]].skillDescription);
}

function updateInfo3(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[3]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[3]].skillDescription);
}

function updateInfo4(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[4]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[4]].skillDescription);
}

function updateInfo5(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[5]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[5]].skillDescription);
}

function updateInfo6(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[6]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[6]].skillDescription);
}

function updateInfo7(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[7]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[7]].skillDescription);
}

function updateInfo8(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[8]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[8]].skillDescription);
}

function updateInfo9(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[9]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[9]].skillDescription);
}

function updateInfo10(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[10]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[10]].skillDescription);
}

function updateInfo11(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[11]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[11]].skillDescription);
}

function updateInfo12(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[12]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[12]].skillDescription);
}

function updateInfo13(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[13]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[13]].skillDescription);
}

function updateInfo14(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[14]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[14]].skillDescription);
}

function updateInfo15(EventData data)
{
    updateInfo(MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[15]].skillName, MiningPlayerOwner.selectedUnits[0].skillsInfo[skillsInfoIndex[15]].skillDescription);
}

function cancelunit1(EventData data){
    cancelunit(0);
}

function cancelunit2(EventData data){
    cancelunit(1);
}

function cancelunit3(EventData data){
    cancelunit(2);
}

function cancelunit4(EventData data){
    cancelunit(3);
}

function cancelunit5(EventData data){
    cancelunit(4);
}

defaultproperties
{

    // The imported SWF to use
	MovieInfo=SwfMovie'MiningHUDPack.HUD'
    MyRenderTexture=TextureRenderTarget2D'MiningHUDPack.portraitTextureTarget2D'
    // Set widget bindings so the Widget passed to
    // WidgetInitialized for the buttons is a GFxCLICKWidget
    WidgetBindings.Add((WidgetName="continue_btn",WidgetClass=class'GFxCLIKWidget'))

    WidgetBindings.Add((WidgetName="settings_btn",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="exit_btn",WidgetClass=class'GFxCLIKWidget'))

    WidgetBindings.Add((WidgetName="skill1_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill2_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill3_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill4_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill5_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill6_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill7_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill8_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill9_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill10_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill11_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill12_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill13_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill14_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="skill15_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="unitBuild1_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="unitBuild2_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="unitBuild3_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="unitBuild4_mc",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="unitBuild5_mc",WidgetClass=class'GFxCLIKWidget'))
    // Set properties for the movie
    // TimingMode=TM_Real makes the menu run while the game is paused
    bDisplayWithHudOff=TRUE
    TimingMode=TM_Real
	bPauseGameWhileActive=FALSE
	bCaptureInput=FALSE
}