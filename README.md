erlang-bertrpc-server
=====================

# Erlang BERT-RPC server

really simple implementation of BERT-RPC server in Erlang supports only function call.


[bert-rpc](http://bert-rpc.org/)


## instruction

### export all modules

bertrpc_server:start( Port )

    % export all modules
    bertrpc_server:start(9999).

### export only specified modules

bertrpc_server:start( Port , ExportModuleList )

    % export only lists and io module
    bertrpc_server:start(9999,[lists,io]).

#author,homepage
- http://throben.org/
- http://zed-throben.hateblo.jp/entry/2014/07/13/TopPage
- twitter: @zed_throben https://twitter.com/zed_throben
