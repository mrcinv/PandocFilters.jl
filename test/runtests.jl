using PandocFilters: walk, Plain, Null, Code
using FactCheck

# write your own tests here
facts("Testing walk with (t,c)->1") do
    action(t,c) = 1
    @fact walk(1,action) --> 1
    @fact walk(["string1","string2"],action) --> ["string1","string2"]
    @fact walk([1,2,3],action) --> [1,2,3]
    @fact walk(Dict("x"=>2,"y"=>3),action) --> Dict("x"=>2,"y"=>3)
    @fact walk([Dict("t"=>2,"c"=>3)],action) --> [1]
end

facts("Testing walk with t=>x -> t=>y") do
    action(t,c) = (t=="x")?Dict("t"=>"y","c"=>c):nothing
    dict_x = Dict("t"=>"x","c"=>"z")
    dict_y = Dict("t"=>"y","c"=>"z")
    dict_z = Dict("t"=>"z","c"=>"w")
    @fact walk([dict_x],action) --> [dict_y]
    @fact walk([dict_x,dict_y,dict_z],action) --> [dict_y,dict_y,dict_z]
    @fact walk(Dict("t"=>"w","c"=>[dict_x]),action) --> Dict("t"=>"w","c"=>[dict_y])
    @fact walk([dict_z,Dict("t"=>"w","c"=>[dict_x])],action) --> [dict_z,Dict("t"=>"w","c"=>[dict_y])]
end
facts("Testing Pandoc elements") do
  @fact Plain("Plain text") --> Dict("t"=>"Plain","c"=>"Plain text")
  @fact Null() --> Dict("t"=>"Null","c"=>[])
  @fact Code(["fun";Any[[],[]]],"1+1") -->  Dict("t"=>"Code","c"=>Any[["fun"; Any[[],[]]],"1+1"])
end
