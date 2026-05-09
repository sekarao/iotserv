%%IoT-устройство
-type id() :: integer().
-type name() :: atom().
-type address() :: {City :: binary(), Street :: binary(), House :: integer()}.
-type temp() :: float() | undefined.
-type indicators() :: [{Name :: atom(), Value :: float()}].

-record(iotdevice, {id :: id(),
                    name :: name(),
                    address :: address(),
                    temp :: temp(),
                    indicators = [] :: indicators()}).