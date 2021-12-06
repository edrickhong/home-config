#common options
set disassemble-next-line on
set confirm off

#custom commands

python
import gdb

class Offsets(gdb.Command):
    def __init__(self):
        super (Offsets, self).__init__ ('offsetsof', gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        argv = gdb.string_to_argv(arg)
        if len(argv) != 1:
            raise gdb.GdbError('offsets-of takes exactly 1 argument.')

        stype = gdb.lookup_type(argv[0])

        print (argv[0], '{')
        for field in stype.fields():
            print ('    %s => %d' % (field.name, field.bitpos//8))
        print ('}')

Offsets()
end






python
import gdb
import sdl2.ext as sdl

class RenderMem(gdb.Command):
    def __init__(self):
        super (RenderMem, self).__init__ ('rendermem', gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        argv = gdb.string_to_argv(arg)

        if len(argv) != 3:
            raise gdb.GdbError('rendermem takes exactly 3 args.')

        #addr = gdb.parse_and_eval(argv[0] +'[0][0]')
        base_addr = argv[0]
        w = int( argv[1] )
        h = int( argv[2] )

        sdl.init()

        window = sdl.Window("Rendermem",size = (w,h))

        window.show()

        surface = window.get_surface()

        for y in range(0,h):
            for x in range(0,w):
                val = int(gdb.parse_and_eval(base_addr + '[' + str(x) + '][' + str(y) + ']'))
                color = sdl.Color(255,255,255)
                sdl.fill(surface,color,(x,y,w,h))


        input('')

        sdl.quit()

RenderMem()


end


python
import gdb

class PrintArr(gdb.Command):
    def __init__(self):
        super (PrintArr, self).__init__ ('printarr', gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        argv = gdb.string_to_argv(arg)

        if len(argv) != 3:
            raise gdb.GdbError('printarr takes exactly 3 args.')

        arr = argv[0]
        el = argv[1]
        count = int(argv[2])

        for i in range(0,count):
            val = gdb.parse_and_eval(arr + '[' + str(i) + '].' + el)
            print(val)


PrintArr()

 end


python
import gdb
from treelib import Node, Tree

class PrintTree(gdb.Command):
    def __init__(self):
        super (PrintTree, self).__init__ ('printtree', gdb.COMMAND_DATA)

    def buildtreeAssimp(self,node,parent,bones,tree):

        name = node['name']
        count = node['children_count']

        tree.create_node(name,name, parent = parent)

        for i in range(0,count):
            index_array = node['childrenindex_array']
            index = index_array[i]
            n = gdb.parse_and_eval(bones + '[' + str(index) +']')

            self.buildtreeAssimp(n,name,bones,tree)


    def invoke(self, arg, from_tty):
        argv = gdb.string_to_argv(arg)

        if len(argv) != 2:
            raise gdb.GdbError('printtree takes exactly 2 args.')

        root = gdb.parse_and_eval(argv[0])
        bones = argv[1]

        tree = Tree()
        self.buildtreeAssimp(root,None,bones,tree)
        tree.show()


PrintTree()

end
