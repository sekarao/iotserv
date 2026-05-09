# iotserv
OTP-приложение для управления сервером IoT-устройств
## Описание IoT-устройств
У устройства есть идентификатор `id`, название `name`, адрес установки `address`, температура `temp` и список показателей `indicators`
## API
* `add_iot/5` - добавление устройства (все поля заданы)
* `add_iot/3` - добавление устройства (не задана температура и список показателей)
* `delete_iot/1` - удаление устройства по `id`
* `change_iot/2` - изменение параметров устройства по `id`
* `lookup_iot/1` - поиск устройства по `id`
## Пример вызовов клиентских функций
```erl
1> rr("include/iotserv.hrl").
[iotdevice]
2> iotserv:add_iot(1, termostat, {<<"Moscow">>, <<"Lenina">>, 21}, 20.0, []).
ok
3> iotserv:lookup_iot(1).
#iotdevice{id = 1,name = termostat,
           address = {<<"Moscow">>,<<"Lenina">>,21},
           temp = 20.0,indicators = []}
4> iotserv:lookup_iot(2).
{error,not_found}
5> iotserv:change_iot(1, [{name, changed_termostat}, {temp, 25.0}, {indicator, power, 100.0}]).
ok
6> iotserv:lookup_iot(1).
#iotdevice{id = 1,name = changed_termostat,
           address = {<<"Moscow">>,<<"Lenina">>,21},
           temp = 25.0,
           indicators = [{power,100.0}]}
7> iotserv:change_iot(4, [{name, changed_termostat}, {temp, 25.0}, {indicator, power, 100.0}]).
{error,not_found}
8> iotserv:add_iot(2, hygrometer, {<<"Novosibirsk">>, <<"Lenina">>, 5}).
ok
9> iotserv:lookup_iot(2).
#iotdevice{id = 2,name = hygrometer,
           address = {<<"Novosibirsk">>,<<"Lenina">>,5},
           temp = undefined,indicators = []}
10> iotserv:delete_iot(2).
ok
11> iotserv:lookup_iot(2).
{error,not_found}
12> whereis(iotserv).
<0.207.0>
13> exit(whereis(iotserv), kill).
true
=SUPERVISOR REPORT==== 9-May-2026::15:46:33.064712 ===
    supervisor: {local,iotserv_sup}
    errorContext: child_terminated
    reason: killed
    offender: [{pid,<0.207.0>},
               {id,iotserv},
               {mfargs,{iotserv,start_link,[]}},
               {restart_type,permanent},
               {significant,false},
               {shutdown,2000},
               {child_type,worker}]

14> whereis(iotserv).
<0.234.0>
15> 
User switch command (type h for help)
sekarao@sekarao-pc:~/Документы/erlang_eltex/dz9/iotserv$ rebar3 shell
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling iotserv
Erlang/OTP 26 [erts-14.2.5.13] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [jit:ns]

Eshell V14.2.5.13 (press Ctrl+G to abort, type help(). for help)
===> Booted jsx
===> Booted iotserv
1> iotserv:lookup_iot(1).
{iotdevice,1,changed_termostat,
           {<<"Moscow">>,<<"Lenina">>,21},
           25.0,
           [{power,100.0}]}
```
