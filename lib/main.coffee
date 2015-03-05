{ EOL } = require 'os'

{ resolve } = require 'path'

{ existsSync } = require 'fs'

Mixto = require 'mixto'

N = []

T = []

class ACliUsage extends Mixto

  @options: commandName: "!"

  USAGE = {}

  FORMAT =

    N: { char: EOL, count: 0 },

    T: { char: "\t", count: 0 },

    S: { char: " ", count: 0 }

  Object.keys(FORMAT).map (key) =>

    Object.defineProperty @, key,

      get: () ->

        stack = []

        if FORMAT[key].count > 0

          for n in [0...FORMAT[key].count] then stack.push FORMAT[key].char

        return stack

      set: (n) ->

        if not n = Number(n) then return FORMAT[key].count = 0

        if n is 1 or n is -1

          FORMAT[key].count += n

        FORMAT[key].count = n

  @register: (command) ->

    {

      name,

      version,

      description,

      usage,

      options

    } = command

    if usage then return @usage[name] = usage.join ''

    usage = []

    synopsys = []

    @N=2

    @T=2

    @S=2

    name ?= ""

    version ?= ""

    description ?= ""

    title = []

    title = title.concat @T, name

    if version

      title = title.concat "@", version

    if description

      title = title.concat " - ", description,

    title = title.join ''

    usage = usage.concat @N, title, @N

    usage = usage.concat @T, "OPTIONS", @N

    @N=1

    _synopsys = []

    for option, def of options

      flag = []

      flag = flag.concat "--", option

      if def.alias

        flag = flag.concat ",-", def.alias

      if def.usage

        _syn = flag.concat " ", def.usage

      else _syn = flag

      _synopsys.push _syn.join('')

      synopsys = synopsys.concat @T, _syn

      flag = flag.concat @N

      synopsys = synopsys.concat @N

      usage = usage.concat @T, flag

      if def.description

        if not Array.isArray(def.description)

          def.description = [def.description]

        def.description = def.description.join(
          "#{@N.join('')}#{@T.join('')}  "
        )

        usage = usage.concat @T, @S, def.description, @N, @N

      if not def.description then usage = usage.concat @N

    @N=2

    usage = usage.concat @T, "SYNOPSYS", @N

    usage = usage.concat synopsys

    USAGE[name] =

      name: name

      version: version

      description: description

      title: title

      synopsys: _synopsys

      usage: usage.join ''

  @usage: (command) =>

    commands = ''

    if command isnt @options.commandName

      return USAGE[command]?.usage or USAGE[@options.commandName]?.usage

    if Object.keys(USAGE).length > 1

      @N=1

      @T=2

      commands = []

      commands = commands.concat @N, @T, "COMMANDS"

      @N=2

      commands = commands.concat @N

      for name, def of USAGE

        if name is command then continue

        commands = commands.concat def.title, @N

        @N=1

        for usage in def.synopsys

          commands = commands.concat @T, @S,  usage, @N

        @N=2

        commands = commands.concat @N

      commands = commands.join ''

      USAGE[command].commands = commands

    return USAGE[command].usage + commands

module.exports = ACliUsage
