using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { Materials }







CodeInput := class(creative_device):
    @editable
    Combinations:[]Combination=array{}
    @editable
    Channel_OpenUI:channel_device=channel_device{}

    OnBegin<override>()<suspends>:void={
        Channel_OpenUI.ReceivedTransmitEvent.Subscribe(OpenUI)
    }

    OpenUI(Ag:?agent):void={
        if(Agent:=Ag?,Player:=player[Agent]){
            panel:=ButtonPanel{Player:=Player,Combinations:=Combinations}
            panel.Start()
        }
    }


ButtonPanel:=class{
    Button1:button_loud=button_loud{DefaultText:=One}
    Button2:button_loud=button_loud{DefaultText:=Two}
    Button3:button_loud=button_loud{DefaultText:=Three}
    Button4:button_loud=button_loud{DefaultText:=Four}
    Button5:button_loud=button_loud{DefaultText:=Five}
    Button6:button_loud=button_loud{DefaultText:=Six}
    Button7:button_loud=button_loud{DefaultText:=Seven}
    Button8:button_loud=button_loud{DefaultText:=Eight}
    Button9:button_loud=button_loud{DefaultText:=Nine}
    Button0:button_loud=button_loud{DefaultText:=Zero}
    ButtonClear:button_regular=button_regular{DefaultText:=Clear}
    ButtonEnter:button_regular=button_regular{DefaultText:=Enter}

    EnteredCodeTextBlock:text_block=text_block{
        DefaultJustification:=text_justification.Center
        DefaultOverflowPolicy:=text_overflow_policy.Ellipsis
            }

    var Subscribes:[]cancelable=array{}
    var CurrentEnteredCode:string = ""
    var Canvas:?canvas=false
    Player:player
    Combinations:[]Combination

    Start():void={
        set Subscribes += array{Button1.OnClick().WidgetSubscribeData(ClickButton,"1")}
        set Subscribes += array{Button2.OnClick().WidgetSubscribeData(ClickButton,"2")}
        set Subscribes += array{Button3.OnClick().WidgetSubscribeData(ClickButton,"3")}
        set Subscribes += array{Button4.OnClick().WidgetSubscribeData(ClickButton,"4")}
        set Subscribes += array{Button5.OnClick().WidgetSubscribeData(ClickButton,"5")}
        set Subscribes += array{Button6.OnClick().WidgetSubscribeData(ClickButton,"6")}
        set Subscribes += array{Button7.OnClick().WidgetSubscribeData(ClickButton,"7")}
        set Subscribes += array{Button8.OnClick().WidgetSubscribeData(ClickButton,"8")}
        set Subscribes += array{Button9.OnClick().WidgetSubscribeData(ClickButton,"9")}
        set Subscribes += array{Button0.OnClick().WidgetSubscribeData(ClickButton,"0")}
        set Subscribes += array{ButtonClear.OnClick().WidgetSubscribeData(ClickButton,"clear")}
        set Subscribes += array{ButtonEnter.OnClick().WidgetSubscribeData(ClickButton,"enter")}
        set Canvas = option{CreateCanvas()}
        ShowUI()
    }
    End():void={
        for(Cancellable:Subscribes){
            Cancellable.Cancel();
        }
        HideUI()
    }
    ClickButton(widg:widget_message,data:string):void={
        if(data = "enter"){
            for(Comb:Combinations){
                if (CurrentEnteredCode = Comb.code){
                    Comb.successChannel.Transmit(option{Player})
                }
            }
            HideUI()
            return
        }
        if(data = "clear"){
            set CurrentEnteredCode = ""
            EnteredCodeTextBlock.SetText(S2M(CurrentEnteredCode))
            return
        }
        set CurrentEnteredCode += data
        EnteredCodeTextBlock.SetText(S2M(CurrentEnteredCode))
    }
    ShowUI():void={
        if(PlayerUI:=GetPlayerUI[Player], Canv:=Canvas?){
            PlayerUI.AddWidget(Canv,player_ui_slot{InputMode:=ui_input_mode.All})
        }
    }
    HideUI():void={
        if(PlayerUI:=GetPlayerUI[Player], Canv:=Canvas?){
            PlayerUI.RemoveWidget(Canv)
        }
    }
    CreateCanvas()<transacts>:canvas={
        # Scale factor for the keypad
    ScaleFactor : float = 0.45
 
    # Calculate new anchor positions based on scale factor
    CenterX : float = 0.5
    CenterY : float = 0.5
 
    # Calculate width and height for the keypad area
    KeypadWidth : float = 0.2 * ScaleFactor
    KeypadHeight : float = 0.25 * ScaleFactor
 
    # Calculate anchor positions for the keypad
    KeypadMinX : float = CenterX - (KeypadWidth * 1.5)
    KeypadMaxX : float = CenterX + (KeypadWidth * 1.5)
    KeypadMinY : float = CenterY - (KeypadHeight * 2.0)
    KeypadMaxY : float = CenterY + (KeypadHeight * 2.0)
    
    Material:material = ButtonUIBackground_material{}
    MaterialBackgroundBlock:material_block=material_block{DefaultImage:=Material,DefaultDesiredSize:=vector2{X:=780.0,Y:=1400.0}}
    #MaterialBackgroundBlock:text_block=text_block{}
    canvas{
        Slots := array{
            canvas_slot{
                Widget := MaterialBackgroundBlock,
                Anchors := anchors{
                    Minimum := vector2{X := KeypadMinX-0.03, Y := KeypadMinY-0.1},
                    Maximum := vector2{X := KeypadMaxX+0.03, Y := KeypadMaxY+0.03}
                },
                Offsets := margin{
                    Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0
                },
                ZOrder:=1
            },
            # Centered text block at the top (fixed height)
            canvas_slot{
                Widget := EnteredCodeTextBlock,
                Anchors := anchors{
                    Minimum := vector2{X := CenterX - 0.1, Y := KeypadMinY - 0.08},
                    Maximum := vector2{X := CenterX + 0.1, Y := KeypadMinY}
                },
                Offsets := margin{
                    Top := 0.0,
                    Left := 0.0,
                    Right := 0.0,
                    Bottom := 0.0
                },
                ZOrder:=2
            },
 
            # First row (1, 2, 3)
            canvas_slot{Widget := Button1,ZOrder:=2, Anchors := anchors{Minimum := vector2{X := KeypadMinX, Y := KeypadMinY}, Maximum := vector2{X := KeypadMinX + KeypadWidth, Y := KeypadMinY + KeypadHeight}}}, 
            canvas_slot{Widget := Button2,ZOrder:=2, Anchors := anchors{Minimum := vector2{X := KeypadMinX + KeypadWidth, Y := KeypadMinY}, Maximum := vector2{X := KeypadMinX + (KeypadWidth * 2.0), Y := KeypadMinY + KeypadHeight}}}, 
            canvas_slot{Widget := Button3,ZOrder:=2, Anchors := anchors{Minimum := vector2{X := KeypadMinX + (KeypadWidth * 2.0), Y := KeypadMinY}, Maximum := vector2{X := KeypadMaxX, Y := KeypadMinY + KeypadHeight}}}, 
            
            # Second row (4, 5, 6)
            canvas_slot{Widget := Button4,ZOrder:=2, Anchors := anchors{Minimum := vector2{X := KeypadMinX, Y := KeypadMinY + KeypadHeight}, Maximum := vector2{X := KeypadMinX + KeypadWidth, Y := KeypadMinY + (KeypadHeight * 2.0)}}}, 
            canvas_slot{Widget := Button5,ZOrder:=2, Anchors := anchors{Minimum := vector2{X := KeypadMinX + KeypadWidth, Y := KeypadMinY + KeypadHeight}, Maximum := vector2{X := KeypadMinX + (KeypadWidth * 2.0), Y := KeypadMinY + (KeypadHeight * 2.0)}}}, 
            canvas_slot{Widget := Button6,ZOrder:=2, Anchors := anchors{Minimum := vector2{X := KeypadMinX + (KeypadWidth * 2.0), Y := KeypadMinY + KeypadHeight}, Maximum := vector2{X := KeypadMaxX, Y := KeypadMinY + (KeypadHeight * 2.0)}}}, 
            
            # Third row (7, 8, 9)
            canvas_slot{Widget := Button7,ZOrder:=2, Anchors := anchors{Minimum := vector2{X := KeypadMinX, Y := KeypadMinY + (KeypadHeight * 2.0)}, Maximum := vector2{X := KeypadMinX + KeypadWidth, Y := KeypadMinY + (KeypadHeight * 3.0)}}}, 
            canvas_slot{Widget := Button8,ZOrder:=2, Anchors := anchors{Minimum := vector2{X := KeypadMinX + KeypadWidth, Y := KeypadMinY + (KeypadHeight * 2.0)}, Maximum := vector2{X := KeypadMinX + (KeypadWidth * 2.0), Y := KeypadMinY + (KeypadHeight * 3.0)}}}, 
            canvas_slot{Widget := Button9,ZOrder:=2, Anchors := anchors{Minimum := vector2{X := KeypadMinX + (KeypadWidth * 2.0), Y := KeypadMinY + (KeypadHeight * 2.0)}, Maximum := vector2{X := KeypadMaxX, Y := KeypadMinY + (KeypadHeight * 3.0)}}}, 
            
            # Fourth row (Enter, 0, Cancel)
            canvas_slot{Widget := ButtonEnter,ZOrder:=2, Anchors := anchors{Minimum := vector2{X := KeypadMinX, Y := KeypadMinY + (KeypadHeight * 3.0)}, Maximum := vector2{X := KeypadMinX + KeypadWidth, Y := KeypadMaxY}}}, 
            canvas_slot{Widget := Button0,ZOrder:=2, Anchors := anchors{Minimum := vector2{X := KeypadMinX + KeypadWidth, Y := KeypadMinY + (KeypadHeight * 3.0)}, Maximum := vector2{X := KeypadMinX + (KeypadWidth * 2.0), Y := KeypadMaxY}}}, 
            canvas_slot{Widget := ButtonClear,ZOrder:=2, Anchors := anchors{Minimum := vector2{X := KeypadMinX + (KeypadWidth * 2.0), Y := KeypadMinY + (KeypadHeight * 3.0)}, Maximum := vector2{X := KeypadMaxX, Y := KeypadMaxY}}}
        }
    }
    }

}
Combination:=class{
    @editable
    code:string
    @editable
    successChannel:channel_device
}
One<localizes>:message="1"
Two<localizes>:message="2"
Three<localizes>:message="3"
Four<localizes>:message="4"
Five<localizes>:message="5"
Six<localizes>:message="6"
Seven<localizes>:message="7"
Eight<localizes>:message="8"
Nine<localizes>:message="9"
Zero<localizes>:message="0"
Clear<localizes>:message="Clear"
Enter<localizes>:message="Enter"
S2M<localizes>(String:string)<computes>:message = "{String}"

(ListenTo:listenable(widget_message)).WidgetSubscribeData<public>(FuncToRun:tuple(widget_message,t)->void,data:t where t:type):cancelable=
    X:=WidgetDataWrapper2(t){ListenTo:=ListenTo,FuncToRun:=FuncToRun,Data:=data}
    X.ListenTo.Subscribe(X.DoThing)
WidgetDataWrapper2(t:type):=class:
    ListenTo:listenable(widget_message)
    FuncToRun:tuple(widget_message,t)->void
    Data:t
    DoThing(WidgMesg:widget_message):void=
        FuncToRun(WidgMesg,Data)