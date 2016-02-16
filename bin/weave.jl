#!/usr/bin/env julia

using PandocFilters

const defaults = Dict(
                      "Code" => Dict(
                                     "hide"=>true,
                                     "display"=>true
                                     ),
                      "CodeBlock" => Dict(
                                          "hide"=>true,
                                          "display"=>false
                                          )
                      )

function proccess_code(t,c)
    if t=="Code" || t=="CodeBlock"
        #defaults for Code and CodeBlock
        options = defaults[t]
        (name,classes,keywords),code = c
        response = []
        if !options["hide"]
            append!(response, [Dict("t"=>t,"c"=>c)])
        end
        if options["display"]
            append!(response, [eval(parse(code))])
        end
        n = length(response)
        if n==1
            response = response[1]
        end
        response
    else
        nothing
    end
end
weave = PandocFilters.filter(proccess_code)

weave()
