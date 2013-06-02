
# vdf.coffee
# serialization/deserialization of VDF files

# heavily based on steamodd's vdf.py

# tokens. luckily, they're just single characters,
# so regexes aren't needed
STRING = '"'
NODE_OPEN = '{'
NODE_CLOSE = '}'
BR_OPEN = '['
BR_CLOSE = ']'
COMMENT = '/'
CR = '\r'
LF = '\n'
SPACE = ' '
TAB = '\t'
WS_RE = /[ \t\r\n]/g

# logdebug = (rest...) -> console.log(rest...)
logdebug = ->

@reIndexOf = reIndexOf = (re, searchElement, fromIndex) ->
  # gotcha: the re MUST be global (/g)
  re.lastIndex = if fromIndex? then fromIndex else 0
  result = re.exec(searchElement)
  return if result? then result.index else -1

# todo: use a streams api
@_parse = _parse = (data, options={}) ->
  # todo: if completely held in memory, use a grammer
  # definition or base on JSON3

  if options.default_namespace is undefined
    # make sure that it doesn't match undefined
    options.default_namespace = {}

  i = if options.i? then options.i else 0
  laststr = null
  lasttok = null
  lastkey = null
  lastval = null
  result = {}

  annt = annotations = {}

  while i < data.length
    c = data[i]

    if c == NODE_OPEN
      logdebug 'open   ', i, c
      options.i = i + 1
      [result[laststr], i, annt] = _parse(data, options)
      if lastbrk?
        # TODO: figure out a more canonical way to decide
        #       bracketed output
        if options.keep_namespaces
          result[laststr + lastbrk] = result[laststr]
        if options.default_namespace is lastbrk
          result[lastbrk] = result[laststr]
    else if c == NODE_CLOSE
      logdebug 'close  ', i, c
      return [result, i, annt]
    else if c == BR_OPEN
      logdebug 'br_open', i, c
      [lastbrk, i] = _brktostr(data, i)
      if lastkey?
        if options.keep_namespaces
          result[lastkey + lastbrk] = lastval
        if options.default_namespace is lastbrk
          result[lastkey] = lastval

        lastkey = lastval = null
    else if c == COMMENT
      logdebug 'comment', i, c
      if (i + 1) < data.length and data[i + 1] == '/'
        startcomment = i
        i = data.indexOf('\n', i)
        annt[laststr] = data.substring(startcomment, i)
    else if c == CR or c == LF
      logdebug 'newline', i, c
      ni = i + 1
      if ni < data.length and data[ni] == LF
        i = ni
      if lasttok != LF
        c = LF
    else if c != SPACE and c != TAB
      if c == STRING
        logdebug 'string ', i, c
        [string, i] = _symtostr(data, i)
      else
        logdebug 'string2', i, c
        [string, i] = _rawsymtostr(data, i)
        c = STRING

      if lasttok == STRING
        if laststr not of result
          result[laststr] = string
        lastkey = laststr
        lastval = string
      laststr = string
    else
      c = lasttok

    lasttok = c
    i += 1

  # return [result, i, annt]
  return [result, i, {}]

@parse = parse = (data, options) -> _parse(data, options)[0]

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

_rawsymtostr = (line, i) ->
  opening = i
  # closing = 0

  closing = reIndexOf(WS_RE, line, opening)
  # console.log(opening, closing, line[closing])

  finalstr = line.substring(opening, closing)
  return [finalstr, i + finalstr.length - 1]

_brktostr = (line, i) ->
  opening = i + 1

  closing = line.indexOf(BR_CLOSE, opening)

  finalstr = line.substring(opening, closing)
  return [finalstr, i + finalstr.length + 1]
