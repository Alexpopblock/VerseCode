using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

(ListenTo:listenable(?agent)).SubscribeAgentWithData(FuncToRun:tuple(agent,t)->void,data:t where t:type):void=
    X:=OAgentWrapper(t){ListenTo:=ListenTo,FuncToRun:=FuncToRun,data:=data}
    X.ListenTo.Subscribe(X.DoThing)
OAgentWrapper(t:type):=class:
    ListenTo:listenable(?agent)
    FuncToRun:tuple(agent,t)->void
    data:t
    DoThing(A:?agent):void=
        if(Ag:=A?):
            FuncToRun(Ag,data)
        else:
            Print("No Agent")
    
(ListenTo:listenable(agent)).SubscribeWithData(FuncToRun:tuple(agent,t)->void,data:t where t:type):void=
    X:=AgentWrapper(t){ListenTo:=ListenTo,FuncToRun:=FuncToRun,data:=data}
    X.ListenTo.Subscribe(X.DoThing)
AgentWrapper(t:type):=class:
    ListenTo:listenable(agent)
    FuncToRun:tuple(agent,t)->void
    data:t
    DoThing(A:agent):void=
        FuncToRun(A,data)

(ListenTo:listenable(?agent)).SubscribeWithAgent(FuncToRun:agent->void):void=
    X:=O2AgentWrapper(){ListenTo:=ListenTo,FuncToRun:=FuncToRun}
    X.ListenTo.Subscribe(X.DoThing)
O2AgentWrapper():=class:
    ListenTo:listenable(?agent)
    FuncToRun:agent->void
    DoThing(A:?agent):void=
        if(Ag:agent=A?):
            FuncToRun(Ag)
        else:
            Print("No Agent")