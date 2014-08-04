class MiningMenu extends GFxMoviePlayer;

var GFxCLIKWidget PlayButton;
var GFxCLIKWidget SettingsButton;
var GFxCLIKWidget ExitButton;
var GFxCLIKWidget confirmationButton;

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

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    // Determine which widget is being initialized and handle it accordingly
    switch(Widgetname)
    {	
    	case 'play_btn':
    		PlayButton = GFxCLIKWidget(Widget);
    		PlayButton.AddEventListener('CLIK_click', playGame);
    		break;
        case 'exit_btn':
            ExitButton = GFxCLIKWidget(Widget);
            //ExitButton.AddEventListener('CLIK_click', closeGame);
            break;
        case 'ok_btn':
            confirmationButton = GFxCLIKWidget(Widget);
            confirmationButton.AddEventListener('CLIK_click', closeGame);
            break;
        default:
        	// Pass on if not a widget we are looking for
            return Super.WidgetInitialized(Widgetname, WidgetPath, Widget);
    }
}

function playGame(EventData data)
{
	// Only on left mouse button
    if(data.mouseIndex == 0)
    {
    	ConsoleCommand("Open NewRise");
        Close();
    }
}

// Delegate added to close the movie
function closeGame(EventData data)
{
    // Only on left mouse button
    if(data.mouseIndex == 0)
    {
		ConsoleCommand("Exit");
        Close();
    }
}

defaultproperties
{
    MovieInfo=SwfMovie'MiningHUDPack.Menu2'
    WidgetBindings.Add((WidgetName="play_btn",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="exit_btn",WidgetClass=class'GFxCLIKWidget'))
    WidgetBindings.Add((WidgetName="ok_btn",WidgetClass=class'GFxCLIKWidget'))
}