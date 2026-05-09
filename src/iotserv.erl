-module(iotserv).

-export([start_link/0, start_link/1, stop/0]).
-export([add_iot/5, add_iot/3, delete_iot/1, change_iot/2, lookup_iot/1]).
-export([init/1, terminate/2, handle_call/3, handle_cast/2]).

-include("iotserv.hrl").

%% Exported client functions

-spec start_link() -> gen_server:start_ret() | {error, Reason}
            when Reason :: file:posix() | badarg | terminated | system_limit.
start_link() ->
    {ok, ConfigName} = application:get_env(iotserv, config_name),
    PrivDir = code:priv_dir(iotserv),
    ConfigPath = filename:join(PrivDir, ConfigName),
    case file:read_file(ConfigPath) of
        {ok, Binary} ->
            Map = jsx:decode(Binary, []),
            Path = maps:get(<<"dets_path">>, Map),
            FullPath = filename:join(PrivDir, binary_to_list(Path)),
            start_link(FullPath);
        {error, Reason} -> {error, Reason}
    end.

-spec start_link(FileName :: file:filename_all()) -> gen_server:start_ret().
start_link(FileName) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, FileName, []).

-spec stop() -> ok.
stop() ->
    gen_server:cast(?MODULE, stop).

%% Customer Services API

-spec add_iot(Id, Name, Address, Temp, Indicators) -> Reply
            when Id :: id(),
                 Name :: name(),
                 Address :: address(),
                 Temp :: temp(),
                 Indicators :: indicators(),
                 Reply :: term().
add_iot(Id, Name, Address, Temp, Indicators) ->
    gen_server:call(?MODULE, {add, Id, Name, Address, Temp, Indicators}).

-spec add_iot(Id, Name, Address) -> Reply
            when Id :: id(),
                 Name :: name(),
                 Address :: address(),
                 Reply :: term().
add_iot(Id, Name, Address) ->
    gen_server:call(?MODULE, {add, Id, Name, Address}).

-spec delete_iot(Id :: id()) -> Reply :: term().
delete_iot(Id) ->
    gen_server:call(?MODULE, {delete, Id}).

-spec change_iot(Id, NewParams) -> Reply
            when Id :: id(),
                 NewParams :: [NewParam | NewIndicator],
                NewParam :: {atom(), name() | address() |
                                temp() | indicators()},
                NewIndicator :: {atom(), atom(), float()},
                Reply :: term().
change_iot(Id, NewParams) ->
    gen_server:call(?MODULE, {change, Id, NewParams}).

-spec lookup_iot(Id :: id()) -> Reply :: term().
lookup_iot(Id) ->
    gen_server:call(?MODULE, {lookup, Id}).


%% Callback functions

init(FileName) ->
    iotserv_db:create_tables(FileName),
    iotserv_db:restore_backup(),
    {ok, null}.

terminate(_Reason, _State) ->
    iotserv_db:close_tables(),
    ok.

handle_cast(stop, State) ->
    {stop, normal, State}.

handle_call({add, Id, Name, Address}, _From, State) ->
    Reply = iotserv_db:add_iot(#iotdevice{id = Id,
                                      name = Name,
                                      address = Address}),
    {reply, Reply, State};

handle_call({add, Id, Name, Address, Temp, Indicators}, _From, State) ->
    Reply = iotserv_db:add_iot(#iotdevice{id = Id,
                                      name = Name,
                                      address = Address,
                                      temp = Temp,
                                      indicators = Indicators}),
    {reply, Reply, State};

handle_call({delete, Id}, _From, State) ->
    Reply = iotserv_db:delete_iot(Id),
    {reply, Reply, State};

handle_call({change, Id, NewParams}, _From, State) ->
    Reply = case iotserv_db:change_iot(Id, NewParams) of
                ok-> ok;
                {error, not_found} -> {error, not_found}
            end,
    {reply, Reply, State};

handle_call({lookup, Id}, _From, State) ->
    Reply = case iotserv_db:lookup_iot(Id) of
                {ok, IotDevice} -> IotDevice;
                {error, not_found} -> {error, not_found}
            end,
    {reply, Reply, State}.