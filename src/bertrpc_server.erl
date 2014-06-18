- module(bertrpc_server).
- compile(export_all).
- define(TCP_OPTIONS,[binary,{packet,raw},{active,false},{reuseaddr,true}]).
- record(state,{exported_modules}).

start(Port) ->
    listen(Port,[]).

start(Port,Export) ->
    listen(Port,[{exported_modules, Export}]).

listen(Port,Option) ->
    {ok,LSocket} = gen_tcp:listen(Port,?TCP_OPTIONS),
    accept(LSocket,Option).

accept(LSocket,Option) ->
    {ok,Socket} = gen_tcp:accept(LSocket),
    State = #state{exported_modules = proplists:get_value(exported_modules,Option)},
    spawn(fun () -> 
        loop(Socket,State) end),
    accept(LSocket,Option).

loop(Socket,State) ->
    read_len(Socket,State).

read_len(Socket,State) ->
    case gen_tcp:recv(Socket,4) of
        {ok, Data} -> 
            <<Len:32>> = Data,
            read_term(Socket,Len,State);
        {error, closed}=Err -> 
            Err
        
    end.

exec_term(Socket,State,Term) ->
    case Term of
        {call, Module, Function, Param} -> 
            case do_apply(Module,Function,Param,State) of
                {ok, Res, NewState} -> 
                    send_term(Socket,{reply,Res}),
                    loop(Socket,NewState);
                {error, Reason, NewState} -> 
                    send_term(Socket,Reason),
                    loop(Socket,NewState)
                
            end;
        UnknownMsg -> 
            io:format("unknown message ~p\n",[UnknownMsg]),
            send_error(Socket,unknown),
            loop(Socket,State)
        
    end.

send_error(Socket,Reason) ->
    Code = 0,
    Class = Reason,
    Detail = Class,
    Backtrace = <<"">>,
    send_term(Socket,{error,{server,Code,Class,Detail,Backtrace}}).

read_term(Socket,Len,State) ->
    case gen_tcp:recv(Socket,Len) of
        {ok, Data} -> 
            Term = decode(Data),
            exec_term(Socket,State,Term);
        {error, closed}=Err -> 
            Err
        
    end.

send_term(Socket,Term) ->
    BinTerm = encode(Term),
    Len = byte_size(BinTerm),
    BinLen = <<A0:8,A1:8,A2:8,A3:8>> = <<Len:32>>,
    gen_tcp:send(Socket,BinLen),
    gen_tcp:send(Socket,BinTerm).

do_apply(Module,Function,Param,State) ->
    TargetModule = case (State#state.exported_modules) of
        undefined -> 
            Module;
        Modules -> 
            case lists:member(Module,Modules) of
                true -> 
                    Module;
                _ -> 
                    undefined
                
            end
        
    end,
    case TargetModule of
        undefined -> 
            {error,not_exported_module,State};
        _ -> 
            Res = apply(Module,Function,Param),
            {ok,Res,State}
        
    end.

decode(X) ->
    bert:decode(X).

encode(X) ->
    bert:encode(X).
