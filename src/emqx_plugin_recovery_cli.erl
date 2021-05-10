%%--------------------------------------------------------------------
%% Copyright (c) 2020 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emqx_plugin_recovery_cli).

-behaviour(ecpool_worker).

-include("emqx_plugin_recovery.hrl").

-include_lib("emqx/include/emqx.hrl").
-include_lib("emqx/include/logger.hrl").

-import(proplists, [get_value/2, get_value/3]).

-export([ connect/1
        , q/2
        ]).

%%--------------------------------------------------------------------
%% Redis Connect/Query
%%--------------------------------------------------------------------

connect(Opts) ->
    Host = get_value(redis_host, Opts),
    Port = get_value(redis_port, Opts, 6379),
    Database = get_value(redis_database, Opts),
    Password = get_value(redis_password, Opts),
    io:format("Opts:~p~n", [Opts]),
    io:format("Host:~s, Port:~s~n", [Host, Port]),
    io:format("Database:(~w), Password:(~s)~n", [Database, Password]),
    Res = eredis:start_link(
        Host,
        Port,
        Database,
        Password,
        no_reconnect
    ),
    io:format("Res:~p~n", [Res]),
    Res.
%%    Res = case eredis:start_link(
%%                    Host,
%%                    Port,
%%                    Database,
%%                    Password,
%%                    no_reconnect
%%                ) of
%%            {ok, Pid} -> {ok, Pid};
%%            {error, Reason = {connection_error, _}} ->
%%                ?LOG(error, "[Redis] Can't connect to Redis server: Connection refused."),
%%                {error, Reason};
%%            {error, Reason = {authentication_error, _}} ->
%%                ?LOG(error, "[Redis] Can't connect to Redis server: Authentication failed."),
%%                {error, Reason};
%%            {error, Reason} ->
%%                ?LOG(error, "[Redis] Can't connect to Redis server: ~p", [Reason]),
%%                {error, Reason}
%%    end,
%%    io:format("Res:~p~n", [Res]),
%%    Res.

%% Redis Query.
q(Cmd, Timeout) ->
    ecpool:with_client(?APP, fun(C) -> eredis:q(C, Cmd, Timeout) end).
