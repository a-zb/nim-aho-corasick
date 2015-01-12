#
#
#  aho-corasick search algorithm for nim-lang
#  (c) Copyright 2015 Arek Bochinski
#
#  See the LICENSE file for MIT license details.
#

import tables

type 
  AhoNode = object
    hit: string
    word: bool
    to: Table[int, string]
    fail: string
type 
  AhoCorasick* = object
    tree*: Table[string, AhoNode]
    rootValue: string

proc makeNode*(fail: string): AhoNode = 
  result        = AhoNode()
  result.hit    = ""
  result.word   = false
  result.to     = initTable[int, string]()
  result.fail   = fail

proc add*(a: var AhoCorasick, s: string) = 
  ## on first letter .fail goes to root
  ## each letter passes path, path = letter + next letter
  ## last letter of string is marked .word = true
  var current    = a.rootValue
  for c in s:
    let asInt = ord(c)
    let path = current & c

    if a.tree[current].to.hasKey(asInt) == false:
      a.tree.mget(current).to[asInt] = path
      a.tree[path] = makeNode(a.rootValue)
    current = path
      
  a.tree.mget(s).word = true

proc build*(a: var AhoCorasick) =
  var q : seq[string]
  q = @[""]

  while q.len > 0:
    var path = q[0]
    q.del(0)

    for asInt, asString in a.tree[path].to:
      q.add(asString)
      
      var fail = if substr(asString, 1).len == 0: "" else: substr(asString, 1)
      while fail != "" and a.tree.hasKey(fail) == false:
        fail = if substr(fail, 1).len == 0: "" else: substr(fail, 1)

      if fail == "":
        fail = a.rootValue
      a.tree.mget(asString).fail = fail

      var hit = if substr(asString, 1).len == 0: "" else: substr(asString, 1)
      while hit != "" and (a.tree.hasKey(hit) == false or a.tree[hit].word == false):
        hit = if substr(hit, 1).len == 0: "" else: substr(hit, 1)

      if hit == "":
        hit = a.rootValue
      a.tree.mget(asString).hit = hit      

proc match*(a: var AhoCorasick, s: string): seq[string] =
  result = @[]
  var path = a.rootValue
  var hitsIdx = 0

  for idx, ch in s:
    var asInt = ord(s[idx])

    while a.tree[path].to.hasKey(asInt) == false and path != a.rootValue:
      path = a.tree[path].fail

    var n: string = ""
    if a.tree[path].to.hasKey(asInt):
      n = a.tree[path].to[asInt]

    if n != "":
      path = n
      if a.tree[n].word == true:
        hitsIdx = hitsIdx + 1
        result.add(n)

      while a.tree[n].hit != a.rootValue:
        n = a.tree[n].hit
        hitsIdx = hitsIdx + 1
        result.add(n)

proc initialize*(a: var AhoCorasick) =
  ## adds root node, as first/only letter
  a.tree = initTable[string, AhoNode]()
  a.tree[""] = makeNode(a.rootValue)

when isMainModule:
  proc test(dictionary: seq[string], expected: seq[string], phrase: string) =
    var ac = AhoCorasick(rootValue: "")
    ac.initialize()
    for w in dictionary:
      ac.add(w)
    ac.build()
    var matches: seq[string] = ac.match(phrase)

    if matches != expected:
      echo("Failed")
    else:
      echo("Success")


  #test validity of pattern search
  test(@["a", "ab", "bc", "bca", "c", "caa"], @["a", "ab", "bc", "c", "c", "a", "ab"], "abccab")
  test(@["poto"], @[], "The pot had a handle")
  test(@["andle"], @["andle"], "The pot had a handle")
  test(@["h"], @["h", "h", "h"], "The pot had a handle")
  test(@["The", "pot", "had", "hod", "andle"], @["The", "pot", "had", "andle"],"The pot had a handle")
  test(@["Th", "he pot", "The", "pot h"],@["Th", "The", "he pot", "pot h"], "The pot had a handle")
  test(@["handle", "hand", "and", "andle"],@["hand", "and", "handle", "andle"], "The pot had a handle")
  test(@["say", "she", "shr", "he", "her"],@["she", "he", "her"], "yasherhs")
  test(@["dlf", "l"], @["l"], "The pot had a handle")
  test(@["handle", "andle", "ndle", "dle", "le", "e"],@["e", "handle", "andle", "ndle", "dle", "le", "e"], "The pot had a handle")
  test(@["acintosh", "in", "tosh"], @["in", "acintosh", "tosh"], "macintosh")
  test(@["monkey", "was", "time", "lava"], @["time", "was", "monkey"], "In the time of chimpanzees I was a monkey.")











