# nim-aho-corasick
Aho–Corasick string matching algorithm

On why, see: http://en.wikipedia.org/wiki/Aho%E2%80%93Corasick_string_matching_algorithm

or read about its use by Cloudflare as explained @nginx-conf 2014, where John Graham Cumming
discusses its use in Cloudflare WAF, together with Lua and Nginx.

http://www.scalescale.com/scaling-cloudflares-massive-waf/

On how:

<b>Create the tree and initialize it</b>
```
  var ac = AhoCorasick(rootValue: "")
  ac.initialize()
```

<b>Create a dictionary of words and build it</b>
```
  for w in @["a", "ab", "bc", "bca", "c", "caa"]:
    ac.add(w)
  ac.build()
```

<b>Search for matches</b>
```
  var matches: seq[string] = ac.match("abccab")
  if matches == @["a", "ab", "bc", "c", "c", "a", "ab"]:
    echo("success")
```
