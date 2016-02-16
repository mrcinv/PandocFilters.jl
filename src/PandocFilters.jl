
module PandocFilters

export walk

using JSON

"""
Type representing Pandoc elements.
"""
type PandocElement
end

"""
Function walk will walk `Pandoc` document abstract source tree (AST) and apply filter function on each elemnet of the document AST. 
"""
function walk(x :: Any, action :: Function)
    return x
end

function walk(array :: Array, action :: Function)
    [walk(elt,action) for elt in array] 
end

function walk(dict :: Dict, action :: Function)
    if haskey(dict,"t") & haskey(dict, "c")
        result = action(dict["t"],dict["c"])
        if result == nothing
            Dict("t"=>dict["t"], "c" => walk(dict["c"],action))
        elseif (typeof(result) <: Dict) && haskey(result,"t") && haskey(result,"c")
            Dict("t"=>result["t"], "c"=>walk(result["c"],action))
        else
            walk(result,action)
        end
    else
        [key=>walk(value,action) for (key,value) in dict]
    end
end

function filter(action :: Function)
    return () -> JSON.print(STDOUT,walk(JSON.parse(STDIN),action))
end

end # module
