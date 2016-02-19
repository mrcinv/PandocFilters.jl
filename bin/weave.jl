#!/usr/bin/env julia

using PandocFilters: Str

const defaults = Dict(
                      "Code" => Dict(
                                     "hide"=>false,
                                     "display"=>true
                                     ),
                      "CodeBlock" => Dict(
                                          "hide"=>false,
                                          "display"=>false
                                          )
                      )

function proccess_code(t,c,format,meta)
    if t=="Code" || t=="CodeBlock"
        #defaults for Code and CodeBlock
        options = defaults[t]
        (name,classes,keywords),code = c
        keywords = [k[1]=>k[2] for k in keywords]
        option = merge(options,keywords)
        response = []
        if !options["hide"]
            append!(response, [Dict("t"=>t,"c"=>c)])
        end
        if options["display"]
            append!(response, [Str(string(eval(parse(code))))])
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


PandocFilters.filter(proccess_code)
