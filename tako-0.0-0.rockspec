package = "Tako"
version = "0.0-0"
source = {
   url = "https://github.com/short-greg/tako" -- We don't have one yet
}
description = {
   summary = "An extension to Torch for more flexible creation of neural/ai systems.",
   detailed = [[
      Tako provides an interface for Lua Torch in order to flexibly
      create AI systems with a graph structure built on top of the
      Torch modules including a variety of control structures to control
      how information flows through the graph. 
   ]],
   homepage = "https://github.com/short-greg/tako/wiki", -- We don't have one yet
   license = "MIT/X11" -- or whatever you like
}
dependencies = {
   "lua >= 5.1, < 5.4",
   -- "torch >= 7"
   -- depends on Torch7
   -- If you depend on other rocks, add them here
}
build = {
   -- We'll start here.
}
