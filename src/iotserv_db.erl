-module(iotserv_db).

-export([create_tables/1, restore_backup/0, close_tables/0, add_iot/1,
         delete_iot/1, change_iot/2, lookup_iot/1]).

-include("iotserv.hrl").

create_tables(FullPath) ->
    ets:new(iotRam, [named_table, {keypos, #iotdevice.id}]),
    dets:open_file(iotDisk, [{file, FullPath}, {keypos, #iotdevice.id}]).

restore_backup() ->
    dets:to_ets(iotDisk, iotRam).

close_tables() ->
    ets:delete(iotRam),
    dets:close(iotDisk).

add_iot(NewDevice) ->
    ets:insert(iotRam, NewDevice),
    dets:insert(iotDisk, NewDevice),
    ok.

delete_iot(Id) ->
    dets:delete(iotDisk, Id),
    ets:delete(iotRam, Id),
    ok.

change_iot(Id, NewParams) ->
    case lookup_iot(Id) of
        {ok, IotDevice} ->
            NewDevice = update_iot(IotDevice, NewParams),
            add_iot(NewDevice);
        {error, not_found} -> {error, not_found}
    end.

lookup_iot(Id) ->
    case ets:lookup(iotRam, Id) of
        [IotDevice] -> {ok, IotDevice};
        [] -> {error, not_found}
    end.

update_iot(IotDevice, [H | T]) ->
    case H of
        {name, Name} -> update_iot(IotDevice#iotdevice{name = Name}, T);
        {address, Address} -> update_iot(IotDevice#iotdevice{address = Address}, T);
        {temp, Temp} -> update_iot(IotDevice#iotdevice{temp = Temp}, T);
        {indicator, Indicator, Value} ->
            NewIndicators = lists:keystore(Indicator, 1,
                        IotDevice#iotdevice.indicators, {Indicator, Value}),
            update_iot(IotDevice#iotdevice{indicators = NewIndicators}, T);
        {indicators, Indicators} -> update_iot(
                                IotDevice#iotdevice{indicators = Indicators}, T)
    end;

update_iot(IotDevice, []) -> IotDevice.

