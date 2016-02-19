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

function proccess_code(t,c,format,meta)
    if t=="Code" || t=="CodeBlock"
        #defaults for Code and CodeBlock
        options = defaults[t]
        (name,classes,keywords),code = c
        keywords = [k[1]=>k[2] for k in keywords]
        option = merge(options,keywords)
        response = []
        if !options["hide"]
          #append!(response, [Dict("t"=>t,"c"=>c)])
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


PandocFilters.filter(proccess_code)
