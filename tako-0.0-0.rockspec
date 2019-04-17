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
  type="builtin",
  modules={
    ['oc.adapter']="src/oc/adapter.lua",
    ['oc.arm']="src/oc/arm.lua",
    ['oc.basemeta']="src/oc/basemeta.lua",
    ['oc.bot.call']="src/oc/bot/call.lua",
    ['oc.bot.nano']="src/oc/bot/nano.lua",
    ['oc.bot.get']="src/oc/bot/get.lua",
    ['oc.bot.init']="src/oc/bot/init.lua",
    ['oc.bot.pkg']="src/oc/bot/pkg.lua",
    ["oc.bot.store"]="src/oc/bot/store.lua",
    ['oc.class']="src/oc/class.lua",
    ["oc.coalesce"]="src/oc/coalesce.lua",
    ["oc.const"]="src/oc/const.lua",
    ["oc.data.accessor"]="src/oc/data/accessor.lua",
    ["oc.data.index"]="src/oc/data/index.lua",
    ["oc.data.pkg"]="src/oc/data/pkg.lua",
    ["oc.data.set"]="src/oc/data/set.lua",
    ["oc.data.storage"]="src/oc/data/storage.lua",
    ["oc.data.table"]="src/oc/data/table.lua",
    ["oc.emission"]="src/oc/emission.lua",
    ["oc.flow.diverge"]="src/oc/flow/diverge.lua",
    ["oc.flow.gate"]="src/oc/flow/gate.lua",
    ["oc.flow.init"]="src/oc/flow/init.lua",
    ["oc.flow.merge"]="src/oc/flow/merge.lua",
    ["oc.flow.mergein"]="src/oc/flow/mergein.lua",
    ["oc.flow.multi"]="src/oc/flow/multi.lua",
    ["oc.flow.pkg"]="src/oc/flow/pkg.lua",
    ["oc.flow.repeat"]="src/oc/flow/repeat.lua",
    ["oc.flow.router"]="src/oc/flow/router.lua",
    ["oc.flow.through"]="src/oc/flow/through.lua",
    ["oc.functor"]="src/oc/functor.lua",
    ["oc.init"]="src/oc/init.lua",
    ["oc.iter"]="src/oc/iter.lua",
    ["oc.pkg"]="src/oc/pkg.lua",
    ["oc.machine.factor"]="src/oc/machine/factor.lua",
    ["oc.machine.fsm"]="src/oc/machine/fsm.lua",
    ["oc.machine.init"]="src/oc/machine/init.lua",
    ["oc.machine.pkg"]="src/oc/machine/pkg.lua",
    ["oc.machine.state"]="src/oc/machine/state.lua",
    ["oc.math.arithmetic"]="src/oc/math/arithmetic.lua",
    ["oc.math.boolean"]="src/oc/math/boolean.lua",
    ["oc.math.init"]="src/oc/math/init.lua",
    ["oc.math.pkg"]="src/oc/math/pkg.lua",
    ["oc.math.relation"]="src/oc/math/relation.lua",
    ['oc.nerve']="src/oc/nerve.lua",
    ['oc.nil']="src/oc/nil.lua",
    ['oc.noop']="src/oc/noop.lua",
    ['oc.oc']="src/oc/oc.lua",

    ['oc.ops.init']="src/oc/ops/init.lua",
    ['oc.ops.math']="src/oc/ops/math.lua",
    ['oc.ops.module']="src/oc/ops/module.lua",
    ['oc.ops.pkg']="src/oc/ops/pkg.lua",
    ['oc.ops.string']="src/oc/ops/string.lua",
    ['oc.ops.table']="src/oc/ops/table.lua",
    ['oc.ops.tensor']="src/oc/ops/tensor.lua",
    
    ['oc.pkg']="src/oc/pkg.lua",
    ['oc.receptor']="src/oc/receptor.lua",
    ['oc.ref']="src/oc/ref.lua",
    ['oc.stem']="src/oc/stem.lua",
    ['oc.strand']="src/oc/strand.lua",
    ['oc.sub']="src/oc/sub.lua",
    ['oc.tako']="src/oc/tako.lua",
    ['oc.tube']="src/oc/tube.lua",
    ['oc.undefined.arg']="src/oc/undefined/arg.lua",
    ['oc.undefined.base']="src/oc/undefined/base.lua",
    ['oc.undefined.declaration']="src/oc/undefined/declaration.lua",
    ['oc.undefined.init']="src/oc/undefined/init.lua",
    ['oc.undefined.reverse']="src/oc/undefined/reverse.lua",
    
    ['oc.update']="src/oc/update.lua",
    
    ['ocnn.bot']="src/ocnn/bot.lua",
    ['ocnn.checktensor']="src/ocnn/checktensor.lua",
    ['ocnn.classarray']="src/ocnn/classarray.lua",
    ['ocnn.clone']="src/ocnn/clone.lua",
    ['ocnn.criterion']="src/ocnn/criterion.lua",
    ['ocnn.flow']="src/ocnn/flow.lua",
    ['ocnn.init']="src/ocnn/init.lua",
    ['ocnn.linear']="src/ocnn/linear.lua",
    ['ocnn.matrixop']="src/ocnn/matrixop.lua",
    ['ocnn.module']="src/ocnn/module.lua",
    ['ocnn.ocnn']="src/ocnn/ocnn.lua",
    ['ocnn.optim']="src/ocnn/optim.lua",
    ['ocnn.pkg']="src/ocnn/pkg.lua",
    ['ocnn.reverse']="src/ocnn/reverse.lua",
    ['ocnn.shape']="src/ocnn/shape.lua",
    ['ocnn.sort']="src/ocnn/sort.lua",
    ['ocnn.tensor']="src/ocnn/tensor.lua",
    ['ocnn.tensoremission']="src/ocnn/tensoremission.lua",
    ['ocnn.undefined']="src/ocnn/undefined.lua",
    
    ['ocnn.data.accessor']="src/ocnn/data/accessor.lua",
    ['ocnn.data.index']="src/ocnn/data/index.lua",
    ['ocnn.data.pkg']="src/ocnn/data/pkg.lua",
    ['ocnn.data.set']="src/ocnn/data/set.lua",
    ['ocnn.data.storage']="src/ocnn/data/storage.lua"
  }

   -- We'll start here.
}
