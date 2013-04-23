# vdf.coffee
# serialization/deserialization of VDF files

# at this point, it's basically a ripoff of steamodd's vdf.py

# tokens. luckily, they're just single characters,
# so regexes aren't needed
STRING = '"'
NODE_OPEN = '{'
NODE_CLOSE = '}'
COMMENT = '/'
CR = '\r'
LF = '\n'

# todo: use a streams api
_parse = (data, i) ->
  # todo: if completely held in memory, use a grammer
  # definition or base on JSON3

  laststr = null
  lasttok = null
  result = {}
  i = i or 0
  while i < data.length
    c = data[i]

    if c == STRING
      [string, i] = _symtostr(data, i)
      if lasttok == STRING
        result[laststr] = string
      laststr = string
    else if c == NODE_OPEN
      [result[laststr], i] = _parse(data, i + 1)
    else if c == NODE_CLOSE
      return [result, i]
    else if c == COMMENT
      if (i + 1) < data.length and data[i + 1] == '/'
        i = data.indexOf('\n', i)
    else if c == CR or c == LF
      ni = i + 1
      if ni < data.length and data[ni] == LF
        i = ni
      if lasttok != LF
        c = LF
    else
      c = lasttok

    lasttok = c
    i += 1

  return [result, i]

@parse = parse = (data) -> _parse(data)[0]

_symtostr = (line, i) ->
  opening = i + 1
  closing = 0

  ci = line.indexOf('"', opening)
  while ci != -1
    if line[ci - 1] != '\\'
      closing = ci
      break
    ci = line.indexOf('"', ci + i)

  finalstr = line.substring(opening, closing)
  return [finalstr, i + finalstr.length + 1]

if require
  # running in node -- todo: better testing
  'const'; fs = require 'fs'
  # 'const'; process = require 'process'

  if process.argv[0] == 'node'
    process.argv.shift()
  data = fs.readFileSync process.argv[1]

  console.log parse data.toString()
