using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }



<#

GOAL:
    Add widget to container: AddWidget("MainMenu", mainMenuWidget, store/show)
    Remove widgets from container RemoveWidget("MainMenu") AUTOMATICALLY HIDES
    Show widget to its player ShowWidget(player,"MainMenu")
    Enable/Disable interactability
    Hide all shown widgets
#>


UIMaster:=class(creative_device):
    var UIPerPlayer:[player]PlayerUIHost = map{}
    @editable
    InitialisationMethod:UIinitMethod=InitMethodPlayerFirstSpawn{}

    
    OnBegin<override>()<suspends>:void={
        
        #Add UI host to every player
        Shush:=InitialisationMethod.PlayerAdded.SubscribeEvent(AddPlayerLogic)
        #Setup method of initialising player
        InitialisationMethod.Init(Self)
        #Prepare cleanup
        GetPlayspace().PlayerRemovedEvent().Subscribe(RemovePlayer)

    }
    AddPlayerLogic(Player:player):void={
        if(set UIPerPlayer[Player] = PlayerUIHost{}){Print("Added player to canvas")}
        if(
            UI:=UIPerPlayer[Player])
        {
            UI.RefreshUI(Player, ui_input_mode.None)}
    }
    RemovePlayer(PlayerToRemove:player):void={
        var newMap:[player]PlayerUIHost = map{}
        for:
            Player->Canv:UIPerPlayer
            Player<>PlayerToRemove
            Item:=UIPerPlayer[Player]
        do:
            if(set newMap[Player] = Item){}
        set UIPerPlayer = newMap
    }

    GetPlayerUIHost(Player:player)<decides><transacts>:PlayerUIHost=UIPerPlayer[Player]
    AddWidget(Player:player,Widget:canvas_slot,Name:string,?Override:logic=false):logic={
        if(Host:=GetPlayerUIHost[Player]){
            return Host.AddWidgetToContainer(Widget,Name,?Override:=Override)
        }
        return false
    }
    AddWidget(Player:player,Widget:widget,Name:string,Anchors:anchors,Offsets:margin,?Override:logic=false):logic={
        Slot:=canvas_slot:
            Widget:=Widget
            Anchors:=Anchors
            Offsets:=Offsets
        if(Host:=GetPlayerUIHost[Player]){
            return Host.AddWidgetToContainer(Slot,Name,?Override:=Override)
        }
        return false
    }
    AddWidgetAndShow(Player:player,Widget:widget,Name:string,Anchors:anchors,Offsets:margin,?Override:logic=false):logic={
        AddWidget(Player,Widget,Name,Anchors,Offsets,?Override:=Override)
        return ShowWidget(Player,Name)
    }
    AddWidgetAndShow(Player:player,Widget:canvas_slot,Name:string,?Override:logic=false):logic={
        AddWidget(Player,Widget,Name,?Override:=Override)
        return ShowWidget(Player,Name)
    }

    RemoveWidget(Player:player,Widget:widget):logic={
        if(Host:=GetPlayerUIHost[Player]){
            return Host.RemoveWidgetFromContainer(Widget)
        }
        return false
    }
    RemoveWidget(Player:player,Widget:canvas_slot):logic={
        if(Host:=GetPlayerUIHost[Player]){
            return Host.RemoveWidgetFromContainer(Widget)
        }
        return false
    }
    RemoveWidgetByName(Player:player,Name:string):logic={
        if(Host:=GetPlayerUIHost[Player]){
            return Host.RemoveWidgetFromContainer(Name)
        }
        return false
    }

    ShowWidget(Player:player,Name:string):logic={
        if(Host:=GetPlayerUIHost[Player]){
            return Host.ShowWidget(Name)
        }
        return false
    }
    HideWidget(Player:player,Name:string):logic={
        if(Host:=GetPlayerUIHost[Player]){
            return Host.HideWidget(Name)
        }
        return false
    }
    SetWidgetInteract(Player:player,Toggle:logic):void={
        if(Host:=GetPlayerUIHost[Player]){
            if(Toggle = true){
                Host.RefreshUI(Player, ui_input_mode.All)
            }
            else{
                Host.RefreshUI(Player, ui_input_mode.None)
            }
            
        }
    }
    

UIinitMethod:=interface():
    PlayerAdded:event(player)=event(player){}
    Init(Device:creative_device):void={if(Debug?){Print("initialising UI init method")}}
    @editable Debug:logic=false
InitMethodSpawnPads:=class<final><concrete>(UIinitMethod):
    @editable
    SpawnPads:[]player_spawner_device=array{}

    Init<override>(Device:creative_device):void={
        (super:)Init(Device)
        for:
            Pad:SpawnPads
        do:
            Pad.SpawnedEvent.Subscribe(PlayerSpawned)
    }
    PlayerSpawned(Agent:agent):void={
        if:
            Player:=player[Agent]
        then:
            PlayerAdded.Signal(Player)
    }
InitMethodPlayerFirstSpawn:=class<final>(UIinitMethod):
    Init<override>(Device:creative_device):void={
        (super:)Init(Device)
        Playspace:=Device.GetPlayspace()
        Playspace.PlayerAddedEvent().Subscribe(PlayerFirstAdded)
        for:
            Player:Playspace.GetPlayers()
        do:
            PlayerFirstAdded(Player)
            if(Debug?){Print("Signalled player")}
    }
    PlayerFirstAdded(Player:player):void={
        PlayerAdded.Signal(Player)
    }


InitMethodTrigger:=class<final>(UIinitMethod):
    @editable
        Tigger:trigger_device=trigger_device{}
    Init<override>(Device:creative_device):void={
        (super:)Init(Device)
        Tigger.TriggeredEvent.Subscribe(AddPlayer)
    }
    AddPlayer(OAgent:?agent):void={
        if(Player:=player[OAgent?]){
            PlayerAdded.Signal(Player)
        }
    }
#UI classes
PlayerUIHost:=class<unique>(){
    var Canvas:canvas = canvas{}
    Container:PlayerWidgetContainer=PlayerWidgetContainer{}

    RefreshUI(Player:player, input_mode:ui_input_mode):void={
        if:
            PlayerUI_:=GetPlayerUI[Player]
        then:
            PlayerUI_.RemoveWidget(Canvas)
            PlayerUI_.AddWidget(Canvas,player_ui_slot{InputMode:=input_mode})
    }
    AddWidgetToContainer(Slot:canvas_slot,Name:string,?Override:logic=false):logic={
        var Result:logic = false
        if(Override = true){set Result = Container.Set(Name,Slot)}
        else{set Result = Container.Add(Name,Slot)}
       
        if(Result = false){Print("A problem occured trying to add/set widget to container")}
        return Result
    }
    RemoveWidgetFromContainer(Name:string):logic={
        Result:logic=Container.DeleteByName(Name)
        return Result
    }
    RemoveWidgetFromContainer(Widget:widget):logic={
        Result:logic=Container.DeleteByWidget(Widget)
        return Result
    }
    RemoveWidgetFromContainer(Slot:canvas_slot):logic={
        Result:logic=Container.DeleteBySlot(Slot)
        return Result
    }
    ShowWidget(Name:string):logic={
        if:
            Widget:=Container.Get[Name]
        then:
            Canvas.AddWidget(Widget)
            Print("Success in adding widget to canvas")
            return true
        return false
    }
    HideWidget(Name:string):logic={
        if:
            Slot:=Container.Get[Name]
        then:
            Canvas.RemoveWidget(Slot.Widget)
            return true
        return false
    }

}
PlayerWidgetContainer:=class(){
    var WidgetIdentities:[string]canvas_slot=map{}
    Get(Name:string)<decides><transacts>:canvas_slot=WidgetIdentities[Name]
    Set(Name:string,Widg:canvas_slot):logic=if(set WidgetIdentities[Name] = Widg){true} else{false}
    Add(Name:string,InputWidg:canvas_slot):logic={
        var Present:logic = false
        for:
            String->Widg:WidgetIdentities
            String = Name
        do:
            return false #Name is present so fails
        Set(Name,InputWidg)
        return true
    }
    DeleteByName(Name:string):logic={
        var Removed:logic=false
        var newMap:[string]canvas_slot = map{}
        for:
            String->Widg:WidgetIdentities
            Item:=WidgetIdentities[String]
        do:
            if(String<>Name){if(set newMap[String] = Item){}}
            else{set Removed = true}
            
        set WidgetIdentities = newMap
        return Removed
    }
    DeleteByWidget(Widget:widget):logic={
        var Removed:logic=false
        var newMap:[string]canvas_slot = map{}
        for:
            String->Slot:WidgetIdentities
            Item:=WidgetIdentities[String]
        do:
            if(Slot.Widget<>Widget){if(set newMap[String] = Item){}}
            else{set Removed = true}
            
        set WidgetIdentities = newMap
        return Removed
    }
    DeleteBySlot(Slot:canvas_slot):logic={
        var Removed:logic=false
        var newMap:[string]canvas_slot = map{}
        for:
            String->containerSlot:WidgetIdentities
            Item:=WidgetIdentities[String]
        do:
            if(containerSlot<>Slot){if(set newMap[String] = Item){}}
            else{set Removed = true}
            
        set WidgetIdentities = newMap
        return Removed
    }
    Replace(Name:string,Widg:canvas_slot):void=if(set WidgetIdentities[Name] = Widg){}
}