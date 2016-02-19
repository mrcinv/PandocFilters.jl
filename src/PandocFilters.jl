# Author: Martin Vuk <martin.vuk@fri.uni-lj.si>
# Copyright: (C) 2016 Martin Vuk
# License: BSD 3-clause


"""
Functions to aid writing python scripts that process the pandoc
AST serialized as JSON.
"""
module PandocFilters

export walk, toJSONFilter

using JSON

"""
Type representing Pandoc elements.
"""
type PandocElement
  t::ASCIIString
  c::Union{AbstractString,Array,Dict}
end

"""
Function walk will walk `Pandoc` document abstract source tree (AST) and apply filter function on each elemnet of the document AST.
Returns a modified tree.
"""

function walk(x :: Any, action :: Function)
    return x
end

function walk(x :: Array, action :: Function)
  array = []
    for item in x
      if (typeof(item)<:Dict) && haskey(item,"t")
        res = action(item["t"], item["c"])
        if res == nothing
          append!(array, [walk(item, action)])
        elseif typeof(res)<:Array
          append!(array, walk(res, action))
        else
          append!(array, [walk(res, action)])
        end
      else
        append!(array, [walk(item, action)])
      end #if
    end #for
  return array
end

function walk(dict :: Dict, action :: Function)
    [key=>walk(value,action) for (key,value) in dict]
end

"""
Converts an action or a list of actions into a filter that reads a JSON-formatted
pandoc document from stdin, transforms it by walking the tree
with the actions, and returns a new JSON-formatted pandoc document
to stdout.  The argument is a list of functions action(key, value, format, meta),
where key is the type of the pandoc object (e.g. "Str", "Para"),
value is the contents of the object (e.g. a string for "Str",
a list of inline elements for "Para"), format is the target
output format (which will be taken for the first command line
argument if present), and meta is the document's metadata.
If the function returns None, the object to which it applies
will remain unchanged.  If it returns an object, the object will
be replaced.    If it returns a list, the list will be spliced in to
the list to which the target object belongs.    (So, returning an
empty list deletes the object.)
"""
function filter(action::Function)
  filter([action])
end

function filter(actions::Array{Function})
  doc = JSON.parse(STDIN)
  format = (length(ARGS) <= 0)? "" : ARGS[1]
  meta = doc[1]["unMeta"]
  for action in actions
    doc = walk(doc, (t,c)->action(t,c,format,meta))
  end
  JSON.print(STDOUT, doc)
end


function elt(eltType, numargs)
    function fun(args...)
        lenargs = length(args)
        if lenargs != numargs
            error("$eltType expects $numargs arguments, but given $lenargs")
        end
        if numargs == 0
            xs = []
        elseif numargs == 1
            xs = args[1]
        else
            xs = collect(args)
        end
        return Dict("t" => eltType, "c" => xs)
      end
    return fun
end
# Constructors for block elements

Plain = elt("Plain", 1)
Para = elt("Para", 1)
CodeBlock = elt("CodeBlock", 2)
RawBlock = elt("RawBlock", 2)
BlockQuote = elt("BlockQuote", 1)
OrderedList = elt("OrderedList", 2)
BulletList = elt("BulletList", 1)
DefinitionList = elt("DefinitionList", 1)
Header = elt("Header", 3)
HorizontalRule = elt("HorizontalRule", 0)
Table = elt("Table", 5)
Div = elt("Div", 2)
Null = elt("Null", 0)

# Constructors for inline elements

Str = elt("Str", 1)
Emph = elt("Emph", 1)
Strong = elt("Strong", 1)
Strikeout = elt("Strikeout", 1)
Superscript = elt("Superscript", 1)
Subscript = elt("Subscript", 1)
SmallCaps = elt("SmallCaps", 1)
Quoted = elt("Quoted", 2)
Cite = elt("Cite", 2)
Code = elt("Code", 2)
Space = elt("Space", 0)
LineBreak = elt("LineBreak", 0)
Math = elt("Math", 2)
RawInline = elt("RawInline", 2)
Link = elt("Link", 3)
Image = elt("Image", 3)
Note = elt("Note", 1)
SoftBreak = elt("SoftBreak", 0)

end # module
